#!/bin/bash
set -e

echo "Building hardpart runtime: draggable workflow canvas, Composio router, dataset ingestion, agent evolution..."

mkdir -p components/workflow lib/composio lib/runtime app/api/{workflow-save,workflow-execute,composio-execute,dataset-ingest-run,agent-evolution-run}

cat > lib/composio/tool-map.ts <<'TS'
export const COMPOSIO_TOOL_MAP: Record<string, string> = {
  gmail_search: "GMAIL_SEARCH_EMAILS",
  gmail_fetch: "GMAIL_FETCH_EMAILS",
  gmail_draft: "GMAIL_CREATE_EMAIL_DRAFT",
  gmail_send: "GMAIL_SEND_EMAIL",
  slack_message: "SLACK_SENDS_A_MESSAGE_TO_A_SLACK_CHANNEL",
  notion_search: "NOTION_SEARCH_NOTION_PAGE",
  notion_create: "NOTION_CREATE_NOTION_PAGE",
  github_issue: "GITHUB_CREATE_AN_ISSUE",
  google_drive_search: "GOOGLEDRIVE_FIND_FILE",
  calendar_create: "GOOGLECALENDAR_CREATE_EVENT"
};

export function resolveComposioTool(action: string) {
  return COMPOSIO_TOOL_MAP[action] || action;
}
TS

cat > lib/composio/client.ts <<'TS'
import { resolveComposioTool } from "./tool-map";

export async function callComposioTool({
  connectedAccountId,
  action,
  payload
}: {
  connectedAccountId?: string;
  action: string;
  payload: any;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;

  if (!apiKey) {
    throw new Error("COMPOSIO_API_KEY is missing. Tool execution is disabled.");
  }

  const toolSlug = resolveComposioTool(action);

  const res = await fetch("https://backend.composio.dev/api/v3/tools/execute", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      connected_account_id: connectedAccountId,
      tool_slug: toolSlug,
      arguments: payload || {}
    })
  });

  const text = await res.text();

  let json: any;
  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }

  if (!res.ok) {
    throw new Error(json?.message || json?.error || "Composio tool execution failed.");
  }

  return json;
}
TS

cat > app/api/composio-execute/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { callComposioTool } from "@/lib/composio/client";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.action) {
      return NextResponse.json(
        { ok: false, error: "company_id and action are required." },
        { status: 400 }
      );
    }

    const result = await callComposioTool({
      connectedAccountId: body.connected_account_id,
      action: body.action,
      payload: body.payload || {}
    });

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      event_type: "composio_tool_executed",
      message: `${body.action} executed through Composio.`,
      metadata: { action: body.action, result }
    }).then(() => {});

    return NextResponse.json({ ok: true, result });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > lib/runtime/workflow-engine.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";
import { callComposioTool } from "@/lib/composio/client";

type NodeItem = {
  id: string;
  type: string;
  label?: string;
  action?: string;
  payload?: any;
};

type EdgeItem = {
  from: string;
  to: string;
};

function orderNodes(nodes: NodeItem[], edges: EdgeItem[]) {
  const start = nodes.find((n) => n.type === "trigger") || nodes[0];
  if (!start) return [];

  const ordered: NodeItem[] = [];
  const visited = new Set<string>();

  function walk(node: NodeItem) {
    if (!node || visited.has(node.id)) return;
    visited.add(node.id);
    ordered.push(node);

    const nextEdges = edges.filter((e) => e.from === node.id);
    for (const edge of nextEdges) {
      const next = nodes.find((n) => n.id === edge.to);
      if (next) walk(next);
    }
  }

  walk(start);
  return ordered;
}

export async function executeWorkflowGraph({
  companyId,
  workflowId,
  graph,
  input
}: {
  companyId: string;
  workflowId?: string;
  graph: any;
  input?: any;
}) {
  const nodes: NodeItem[] = graph?.nodes || [];
  const edges: EdgeItem[] = graph?.edges || [];
  const ordered = orderNodes(nodes, edges);

  const run = await supabaseAdmin
    .from("workflow_runs")
    .insert({
      company_id: companyId,
      workflow_id: workflowId || null,
      status: "running",
      input: input || {},
      metadata: { node_count: ordered.length }
    })
    .select()
    .single();

  if (run.error) throw run.error;

  const outputs: any[] = [];

  for (const node of ordered) {
    const startedAt = new Date().toISOString();

    try {
      let output: any = { ok: true, type: node.type };

      if (node.type === "tool" && node.action) {
        output = await callComposioTool({
          connectedAccountId: node.payload?.connected_account_id,
          action: node.action,
          payload: node.payload || {}
        });
      }

      if (node.type === "approval") {
        await supabaseAdmin.from("human_approval_inbox").insert({
          company_id: companyId,
          approval_type: "workflow_node",
          title: node.label || "Workflow approval",
          description: "Workflow requested human approval.",
          payload: { workflow_run_id: run.data.id, node },
          status: "pending"
        });
        output = { pending_approval: true };
      }

      await supabaseAdmin.from("runtime_events").insert({
        company_id: companyId,
        event_type: "workflow_node_completed",
        message: `${node.label || node.type} completed.`,
        metadata: { workflow_run_id: run.data.id, node_id: node.id, output, started_at: startedAt }
      });

      outputs.push({ node, output });
    } catch (error: any) {
      await supabaseAdmin.from("runtime_events").insert({
        company_id: companyId,
        event_type: "workflow_node_failed",
        message: `${node.label || node.type} failed.`,
        metadata: { workflow_run_id: run.data.id, node_id: node.id, error: error.message }
      });

      await supabaseAdmin
        .from("workflow_runs")
        .update({ status: "failed", error: error.message })
        .eq("id", run.data.id);

      throw error;
    }
  }

  await supabaseAdmin
    .from("workflow_runs")
    .update({
      status: "completed",
      output: { nodes: outputs }
    })
    .eq("id", run.data.id);

  return { run: run.data, outputs };
}
TS

cat > app/api/workflow-save/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.title || !body.graph) {
      return NextResponse.json({ ok: false, error: "company_id, title and graph required." }, { status: 400 });
    }

    const payload = {
      company_id: body.company_id,
      title: body.title,
      graph: body.graph,
      status: body.status || "draft",
      updated_at: new Date().toISOString()
    };

    const result = body.id
      ? await supabaseAdmin.from("workflow_graphs").update(payload).eq("id", body.id).select().single()
      : await supabaseAdmin.from("workflow_graphs").insert(payload).select().single();

    if (result.error) throw result.error;

    return NextResponse.json({ ok: true, workflow: result.data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/workflow-execute/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { executeWorkflowGraph } from "@/lib/runtime/workflow-engine";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.graph) {
      return NextResponse.json({ ok: false, error: "company_id and graph required." }, { status: 400 });
    }

    const result = await executeWorkflowGraph({
      companyId: body.company_id,
      workflowId: body.workflow_id,
      graph: body.graph,
      input: body.input || {}
    });

    return NextResponse.json({ ok: true, result });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > components/workflow/DraggableWorkflowCanvas.tsx <<'TSX'
"use client";

import { useMemo, useState } from "react";

type NodeItem = {
  id: string;
  type: string;
  label: string;
  x: number;
  y: number;
  action?: string;
  payload?: any;
};

type EdgeItem = {
  from: string;
  to: string;
};

const initialNodes: NodeItem[] = [
  { id: "trigger", type: "trigger", label: "Command Trigger", x: 70, y: 120 },
  { id: "agent", type: "agent", label: "AI Agent", x: 365, y: 190 },
  { id: "memory", type: "memory", label: "Company Brain", x: 665, y: 95 },
  { id: "approval", type: "approval", label: "Human Review", x: 665, y: 330 },
  { id: "tool", type: "tool", label: "Gmail Draft", x: 960, y: 210, action: "gmail_draft" }
];

const initialEdges: EdgeItem[] = [
  { from: "trigger", to: "agent" },
  { from: "agent", to: "memory" },
  { from: "agent", to: "approval" },
  { from: "approval", to: "tool" }
];

export default function DraggableWorkflowCanvas({
  companyId
}: {
  companyId?: string | null;
}) {
  const [nodes, setNodes] = useState<NodeItem[]>(initialNodes);
  const [edges] = useState<EdgeItem[]>(initialEdges);
  const [drag, setDrag] = useState<{ id: string; dx: number; dy: number } | null>(null);
  const [title, setTitle] = useState("AI Operations Workflow");
  const [msg, setMsg] = useState("");

  const nodeMap = useMemo(() => {
    const map = new Map<string, NodeItem>();
    nodes.forEach((n) => map.set(n.id, n));
    return map;
  }, [nodes]);

  function onMove(e: React.MouseEvent<HTMLDivElement>) {
    if (!drag) return;

    const box = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - box.left - drag.dx;
    const y = e.clientY - box.top - drag.dy;

    setNodes((prev) =>
      prev.map((n) =>
        n.id === drag.id
          ? { ...n, x: Math.max(20, x), y: Math.max(20, y) }
          : n
      )
    );
  }

  async function save() {
    if (!companyId) {
      setMsg("Create/login to a workspace before saving.");
      return;
    }

    setMsg("Saving workflow...");

    const res = await fetch("/api/workflow-save", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        company_id: companyId,
        title,
        graph: { nodes, edges }
      })
    });

    const json = await res.json();
    setMsg(json.ok ? "Workflow saved." : json.error || "Save failed.");
  }

  async function run() {
    if (!companyId) {
      setMsg("Create/login to a workspace before running.");
      return;
    }

    setMsg("Running workflow...");

    const res = await fetch("/api/workflow-execute", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        company_id: companyId,
        graph: { nodes, edges },
        input: { source: "canvas" }
      })
    });

    const json = await res.json();
    setMsg(json.ok ? "Workflow run started/completed." : json.error || "Run failed.");
  }

  return (
    <div>
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="w-[320px] rounded-lg border border-neutral-200 bg-white px-3 py-2 text-sm font-bold"
        />

        <div className="flex gap-2">
          <button onClick={save} className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">
            Save Graph
          </button>
          <button onClick={run} className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">
            Run Workflow
          </button>
        </div>
      </div>

      {msg && <p className="mb-3 rounded-xl bg-neutral-100 p-3 text-sm font-bold text-neutral-700">{msg}</p>}

      <div
        className="relative h-[720px] overflow-hidden rounded-2xl border border-neutral-200 bg-white"
        onMouseMove={onMove}
        onMouseUp={() => setDrag(null)}
        onMouseLeave={() => setDrag(null)}
      >
        <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />

        <svg className="absolute inset-0 h-full w-full">
          {edges.map((edge) => {
            const a = nodeMap.get(edge.from);
            const b = nodeMap.get(edge.to);
            if (!a || !b) return null;

            const ax = a.x + 190;
            const ay = a.y + 50;
            const bx = b.x;
            const by = b.y + 50;

            return (
              <path
                key={`${edge.from}-${edge.to}`}
                d={`M${ax} ${ay} C${ax + 80} ${ay} ${bx - 80} ${by} ${bx} ${by}`}
                fill="none"
                stroke="#111"
                strokeWidth="2"
              />
            );
          })}
        </svg>

        {nodes.map((node) => (
          <div
            key={node.id}
            className="absolute w-[190px] cursor-grab rounded-xl border border-neutral-300 bg-white p-4 shadow-lg active:cursor-grabbing"
            style={{ left: node.x, top: node.y }}
            onMouseDown={(e) => {
              const rect = e.currentTarget.getBoundingClientRect();
              setDrag({
                id: node.id,
                dx: e.clientX - rect.left,
                dy: e.clientY - rect.top
              });
            }}
          >
            <p className="text-[11px] font-black uppercase tracking-[.14em] text-neutral-400">
              {node.type}
            </p>
            <h3 className="mt-2 font-black">{node.label}</h3>
            <p className="mt-2 text-xs text-neutral-500">Drag to move</p>
          </div>
        ))}
      </div>
    </div>
  );
}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import DraggableWorkflowCanvas from "@/components/workflow/DraggableWorkflowCanvas";
import { getWorkspace } from "@/lib/server/workspace";

export default async function WorkflowStudioPage() {
  const { user, companyId } = await getWorkspace();

  if (!user) {
    return (
      <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6">
        <div className="rounded-3xl border border-neutral-200 bg-white p-10 text-center">
          <h1 className="text-4xl font-black">Login required</h1>
          <p className="mt-3 text-neutral-500">Login to access Workflow Studio.</p>
        </div>
      </main>
    );
  }

  return (
    <AppShell
      title="Workflow Studio"
      subtitle="Drag, save and execute workflow graphs."
      right={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[.16em] text-neutral-400">Canvas</p>
          <h2 className="mt-3 text-xl font-black">Drag + Save Enabled</h2>
          <p className="mt-4 text-sm leading-6 text-neutral-500">
            Nodes can be moved with the mouse. Save Graph persists node positions to Supabase.
          </p>
          <p className="mt-4 break-all text-xs text-neutral-400">
            company_id: {companyId || "missing"}
          </p>
        </div>
      }
    >
      <DraggableWorkflowCanvas companyId={companyId} />
    </AppShell>
  );
}
TSX

cat > app/api/dataset-ingest-run/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

function chunkText(text: string, size = 1200) {
  const chunks: string[] = [];
  for (let i = 0; i < text.length; i += size) {
    chunks.push(text.slice(i, i + size));
  }
  return chunks;
}

async function embed(text: string) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) return null;

  const res = await fetch("https://api.openai.com/v1/embeddings", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: "text-embedding-3-small",
      input: text
    })
  });

  const json = await res.json();
  return json?.data?.[0]?.embedding || null;
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.dataset_id || !body.text) {
      return NextResponse.json(
        { ok: false, error: "company_id, dataset_id and text are required." },
        { status: 400 }
      );
    }

    const chunks = chunkText(body.text);

    for (let i = 0; i < chunks.length; i++) {
      const content = chunks[i];
      const embedding = await embed(content);

      await supabaseAdmin.from("dataset_chunks").insert({
        company_id: body.company_id,
        dataset_id: body.dataset_id,
        chunk_index: i,
        content,
        embedding,
        metadata: { embedding_created: !!embedding }
      });
    }

    await supabaseAdmin
      .from("datasets")
      .update({ status: process.env.OPENAI_API_KEY ? "embedded" : "chunked_no_embedding_key" })
      .eq("id", body.dataset_id)
      .eq("company_id", body.company_id);

    return NextResponse.json({ ok: true, chunks: chunks.length, embedded: !!process.env.OPENAI_API_KEY });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

npm run build
git add .
git commit -m "Add true draggable workflow canvas composio runtime and ingestion" || true
git push origin main

echo "DONE: hardpart runtime layer added."
