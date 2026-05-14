#!/bin/bash
set -e

echo "Adding UNIC.ai super AI systems..."

mkdir -p app/{brain,triggers,realtime,rag,workflows,swarm,admin/security,legal/ownership}
mkdir -p app/api/{composio-link,tool-execute,trigger-event,memory-sync,embed-text,rag-search,dataset-upload,marketplace-buy,buy-credits,team-accept,workflow-run,swarm-run,audit-log}
mkdir -p lib/{composio,billing,memory,rag,security,workflow,swarm}
mkdir -p workers

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json","utf8"));
pkg.dependencies = pkg.dependencies || {};
pkg.dependencies.stripe = "latest";
pkg.dependencies.zod = "latest";
fs.writeFileSync("package.json", JSON.stringify(pkg,null,2));
NODE

cat > lib/composio/client.ts <<'TS'
export async function createComposioAuthLink({
  userId,
  toolkit,
  redirectUrl
}: {
  userId: string;
  toolkit: string;
  redirectUrl?: string;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;
  if (!apiKey) throw new Error("COMPOSIO_API_KEY missing.");

  const res = await fetch("https://backend.composio.dev/api/v3.1/connected_accounts/link", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      redirect_url: redirectUrl || process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000/connectors"
    })
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.message || "Composio auth link failed.");
  return data;
}

export async function executeComposioTool({
  userId,
  toolkit,
  toolSlug,
  argumentsJson
}: {
  userId: string;
  toolkit: string;
  toolSlug: string;
  argumentsJson: any;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;
  if (!apiKey) throw new Error("COMPOSIO_API_KEY missing.");

  const res = await fetch("https://backend.composio.dev/api/v3/tools/execute", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      tool_slug: toolSlug,
      arguments: argumentsJson || {}
    })
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.message || "Composio tool execution failed.");
  return data;
}
TS

cat > lib/billing/credits.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function deductCredits(companyId: string, amount: number, metadata: any = {}) {
  const { data: wallet } = await supabaseAdmin
    .from("company_credit_wallets")
    .select("*")
    .eq("company_id", companyId)
    .single();

  if (!wallet) throw new Error("Credit wallet missing.");
  if (Number(wallet.balance) < amount) throw new Error("Insufficient credits.");

  const newBalance = Number(wallet.balance) - amount;

  await supabaseAdmin
    .from("company_credit_wallets")
    .update({
      balance: newBalance,
      lifetime_used: Number(wallet.lifetime_used || 0) + amount
    })
    .eq("company_id", companyId);

  await supabaseAdmin.from("credit_ledger").insert({
    company_id: companyId,
    event_type: "usage_deduction",
    amount: -amount,
    balance_after: newBalance,
    metadata
  });

  return newBalance;
}
TS

cat > lib/memory/embedding.ts <<'TS'
import OpenAI from "openai";

export async function createEmbedding(text: string) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY required for embeddings.");

  const openai = new OpenAI({ apiKey });

  const result = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: text.slice(0, 8000)
  });

  return result.data[0].embedding;
}
TS

cat > lib/rag/search.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createEmbedding } from "@/lib/memory/embedding";

export async function ragSearch(companyId: string, query: string) {
  const embedding = await createEmbedding(query);

  const { data, error } = await supabaseAdmin.rpc("match_memory", {
    query_embedding: embedding,
    match_company_id: companyId,
    match_count: 10
  });

  if (error) throw error;

  return data || [];
}
TS

cat > lib/security/audit.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function auditLog({
  companyId,
  actorId,
  eventType,
  riskLevel = "low",
  entityType,
  entityId,
  metadata = {}
}: any) {
  await supabaseAdmin.from("audit_events").insert({
    company_id: companyId,
    actor_id: actorId || null,
    event_type: eventType,
    risk_level: riskLevel,
    entity_type: entityType || null,
    entity_id: entityId || null,
    metadata
  });
}
TS

cat > lib/workflow/engine.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function startWorkflowRun(companyId: string, workflowId: string, input: any) {
  const { data: workflow, error } = await supabaseAdmin
    .from("workflow_builders")
    .select("*")
    .eq("id", workflowId)
    .single();

  if (error) throw error;

  const { data: run, error: runError } = await supabaseAdmin
    .from("workflow_runs")
    .insert({
      company_id: companyId,
      workflow_id: workflowId,
      status: "running",
      input,
      current_node: workflow.graph?.nodes?.[0]?.id || null
    })
    .select()
    .single();

  if (runError) throw runError;

  for (const node of workflow.graph?.nodes || []) {
    if (node.type === "agent" && node.agent_id) {
      await supabaseAdmin.from("execution_queue").insert({
        company_id: companyId,
        agent_id: node.agent_id,
        payload: {
          prompt: input.prompt || JSON.stringify(input),
          workflow_run_id: run.id,
          node_id: node.id
        },
        status: "pending"
      });
    }
  }

  return run;
}
TS

cat > lib/swarm/engine.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function runSwarm(companyId: string, swarmId: string, prompt: string) {
  const { data: members } = await supabaseAdmin
    .from("swarm_agents")
    .select("*, agents(*)")
    .eq("swarm_id", swarmId);

  const queued = [];

  for (const member of members || []) {
    const agent = member.agents;
    if (!agent) continue;

    await supabaseAdmin.from("swarm_messages").insert({
      company_id: companyId,
      swarm_id: swarmId,
      to_agent_id: agent.id,
      message: prompt,
      metadata: { role: member.role }
    });

    const { data: job } = await supabaseAdmin
      .from("execution_queue")
      .insert({
        company_id: companyId,
        agent_id: agent.id,
        swarm_id: swarmId,
        payload: {
          prompt,
          swarm_id: swarmId,
          swarm_role: member.role
        },
        status: "pending"
      })
      .select()
      .single();

    if (job) queued.push(job);
  }

  return queued;
}
TS

cat > app/api/composio-link/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { createComposioAuthLink } from "@/lib/composio/client";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const link = await createComposioAuthLink({
      userId: body.user_id,
      toolkit: body.toolkit,
      redirectUrl: body.redirect_url
    });

    await supabaseAdmin.from("connector_accounts").insert({
      company_id: body.company_id,
      provider: body.toolkit,
      connection_id: link.connected_account_id || link.connection_id || null,
      auth_provider: "composio",
      status: "pending",
      metadata: link
    });

    return NextResponse.json({ ok: true, link });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/tool-execute/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { executeComposioTool } from "@/lib/composio/client";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { deductCredits } from "@/lib/billing/credits";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: execution } = await supabaseAdmin
      .from("tool_executions")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        provider: body.toolkit,
        tool_slug: body.tool_slug,
        input: body.arguments || {},
        status: "running"
      })
      .select()
      .single();

    const output = await executeComposioTool({
      userId: body.user_id,
      toolkit: body.toolkit,
      toolSlug: body.tool_slug,
      argumentsJson: body.arguments || {}
    });

    await supabaseAdmin
      .from("tool_executions")
      .update({
        output,
        status: "completed",
        completed_at: new Date().toISOString()
      })
      .eq("id", execution.id);

    await deductCredits(body.company_id, 1, {
      type: "tool_execution",
      tool_slug: body.tool_slug
    });

    return NextResponse.json({ ok: true, output });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/trigger-event/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: trigger } = await supabaseAdmin
      .from("triggers")
      .select("*")
      .eq("company_id", body.company_id)
      .eq("source_provider", body.source_provider)
      .eq("event_type", body.event_type)
      .eq("enabled", true)
      .limit(1)
      .single();

    const { data: event } = await supabaseAdmin
      .from("trigger_events")
      .insert({
        company_id: body.company_id,
        trigger_id: trigger?.id || null,
        source_provider: body.source_provider,
        event_type: body.event_type,
        payload: body.payload || {},
        status: "received"
      })
      .select()
      .single();

    if (trigger?.agent_id) {
      await supabaseAdmin.from("execution_queue").insert({
        company_id: body.company_id,
        agent_id: trigger.agent_id,
        payload: {
          prompt: `A trigger fired: ${body.event_type}. Handle this event: ${JSON.stringify(body.payload || {})}`,
          trigger_event_id: event.id
        },
        status: "pending"
      });
    }

    return NextResponse.json({ ok: true, event });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/embed-text/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createEmbedding } from "@/lib/memory/embedding";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const embedding = await createEmbedding(body.content);

    const { data, error } = await supabaseAdmin
      .from("memory_tree")
      .insert({
        company_id: body.company_id,
        source_type: body.source_type || "manual",
        source_provider: body.source_provider || "unic",
        source_id: body.source_id || null,
        title: body.title || "Memory",
        content: body.content,
        embedding,
        synced_at: new Date().toISOString(),
        metadata: body.metadata || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, memory: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/rag-search/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { ragSearch } from "@/lib/rag/search";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const results = await ragSearch(body.company_id, body.query);
    return NextResponse.json({ ok: true, results });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/dataset-upload/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const form = await req.formData();
    const companyId = String(form.get("company_id"));
    const datasetId = String(form.get("dataset_id"));
    const file = form.get("file") as File;

    if (!companyId || !datasetId || !file) {
      return NextResponse.json({ ok: false, error: "company_id, dataset_id and file required." }, { status: 400 });
    }

    const path = `${companyId}/${datasetId}/${Date.now()}-${file.name}`;
    const arrayBuffer = await file.arrayBuffer();

    const { error } = await supabaseAdmin.storage
      .from("datasets")
      .upload(path, Buffer.from(arrayBuffer), {
        contentType: file.type,
        upsert: true
      });

    if (error) throw error;

    const { data } = await supabaseAdmin.from("dataset_files").insert({
      company_id: companyId,
      dataset_id: datasetId,
      file_name: file.name,
      file_url: path,
      file_type: file.type,
      status: "uploaded"
    }).select().single();

    await supabaseAdmin.from("storage_files").insert({
      company_id: companyId,
      bucket: "datasets",
      path,
      file_name: file.name,
      file_type: file.type,
      size_bytes: file.size
    });

    return NextResponse.json({ ok: true, file: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/marketplace-buy/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { deductCredits } from "@/lib/billing/credits";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: listing, error } = await supabaseAdmin
      .from("marketplace_listings")
      .select("*")
      .eq("id", body.listing_id)
      .single();

    if (error) throw error;

    await deductCredits(body.buyer_company_id, Number(listing.price || 0), {
      type: "marketplace_purchase",
      listing_id: listing.id
    });

    const { data: order } = await supabaseAdmin.from("marketplace_orders").insert({
      buyer_company_id: body.buyer_company_id,
      seller_company_id: listing.company_id,
      listing_id: listing.id,
      amount: listing.price || 0,
      status: "completed"
    }).select().single();

    const { data: entitlement } = await supabaseAdmin.from("marketplace_entitlements").insert({
      company_id: body.buyer_company_id,
      listing_id: listing.id,
      order_id: order.id,
      entitlement_type: body.entitlement_type || "license",
      status: "active"
    }).select().single();

    return NextResponse.json({ ok: true, order, entitlement });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/buy-credits/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const stripeKey = process.env.STRIPE_SECRET_KEY;

    if (!stripeKey) {
      return NextResponse.json({
        ok: false,
        error: "STRIPE_SECRET_KEY missing. Add Stripe key to enable checkout."
      }, { status: 400 });
    }

    const stripe = new Stripe(stripeKey);

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      success_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?success=true`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?canceled=true`,
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: body.name || "UNIC.ai Credit Pack"
            },
            unit_amount: Math.round(Number(body.amount || 1000) * 100)
          },
          quantity: 1
        }
      ],
      metadata: {
        company_id: body.company_id,
        pack_id: body.pack_id || ""
      }
    });

    return NextResponse.json({ ok: true, url: session.url });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/team-accept/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: invite, error } = await supabaseAdmin
      .from("team_invites")
      .select("*")
      .eq("id", body.invite_id)
      .eq("status", "pending")
      .single();

    if (error) throw error;

    await supabaseAdmin.from("company_members").insert({
      company_id: invite.company_id,
      user_id: body.user_id,
      role: invite.role || "member"
    });

    await supabaseAdmin.from("team_invites").update({ status: "accepted" }).eq("id", invite.id);

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/workflow-run/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { startWorkflowRun } from "@/lib/workflow/engine";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const run = await startWorkflowRun(body.company_id, body.workflow_id, body.input || {});
    return NextResponse.json({ ok: true, run });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/swarm-run/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { runSwarm } from "@/lib/swarm/engine";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const jobs = await runSwarm(body.company_id, body.swarm_id, body.prompt);
    return NextResponse.json({ ok: true, jobs });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/audit-log/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { auditLog } from "@/lib/security/audit";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    await auditLog({
      companyId: body.company_id,
      actorId: body.actor_id,
      eventType: body.event_type,
      riskLevel: body.risk_level,
      entityType: body.entity_type,
      entityId: body.entity_id,
      metadata: body.metadata || {}
    });

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > workers/super-worker.js <<'JS'
const { createClient } = require("@supabase/supabase-js");
const OpenAI = require("openai");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const openai = process.env.OPENAI_API_KEY ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY }) : null;

async function embedMemory(companyId, title, content, sourceProvider = "worker") {
  if (!openai || !content) return;

  const emb = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: content.slice(0, 8000)
  });

  await supabase.from("memory_tree").insert({
    company_id: companyId,
    source_type: "worker_output",
    source_provider: sourceProvider,
    title,
    content,
    embedding: emb.data[0].embedding,
    synced_at: new Date().toISOString()
  });
}

async function syncMemory() {
  const { data: rows } = await supabase
    .from("runtime_events")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(20);

  for (const row of rows || []) {
    if (row.message) {
      await embedMemory(row.company_id, row.event_type, row.message, "runtime_events");
    }
  }
}

async function processTriggers() {
  const { data: events } = await supabase
    .from("trigger_events")
    .select("*")
    .eq("status", "received")
    .limit(10);

  for (const ev of events || []) {
    await supabase.from("trigger_events").update({ status: "processed" }).eq("id", ev.id);
  }
}

async function tick() {
  try {
    await processTriggers();
    await syncMemory();
    console.log("Super worker tick", new Date().toISOString());
  } catch (e) {
    console.error(e.message);
  }
}

setInterval(tick, 20 * 60 * 1000);
tick();
JS

cat > app/brain/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function BrainPage() {
  const { data } = await supabaseAdmin
    .from("memory_tree")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(100);

  return (
    <Shell title="Company Brain" subtitle="Long-term memory, synced knowledge and personalization signals.">
      <DataTable rows={data || []} />
    </Shell>
  );
}
TSX

cat > app/triggers/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function TriggersPage() {
  const { data } = await supabaseAdmin.from("triggers").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Triggers" subtitle="Live events that fire agent actions automatically."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > app/realtime/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function RealtimePage() {
  const { data } = await supabaseAdmin.from("runtime_events").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Realtime Runtime" subtitle="Live execution stream and runtime event feed."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > app/rag/page.tsx <<'TSX'
"use client";
import { useState } from "react";

export default function RAGPage() {
  const [companyId, setCompanyId] = useState("");
  const [query, setQuery] = useState("");
  const [result, setResult] = useState("");

  async function search() {
    const res = await fetch("/api/rag-search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ company_id: companyId, query })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Vector Search / RAG</h1>
        <p className="page-subtitle">Search company memory using embeddings and pgvector.</p>
        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={e => setCompanyId(e.target.value)} />
          <textarea className="input-box mt-4 min-h-[140px]" placeholder="Ask your company brain..." value={query} onChange={e => setQuery(e.target.value)} />
          <button className="primary-button mt-6" onClick={search}>Search Memory</button>
          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/admin/security/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function SecurityPage() {
  const { data } = await supabaseAdmin.from("audit_events").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Security & Audit" subtitle="Enterprise logs for governance, risk and compliance."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > app/legal/ownership/page.tsx <<'TSX'
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function OwnershipTerms() {
  const { data } = await supabaseAdmin.from("legal_terms").select("*").eq("slug", "ownership").single();

  return (
    <main className="min-h-screen bg-white p-10">
      <h1 className="text-5xl font-black tracking-[-0.05em]">{data?.title || "Ownership Terms"}</h1>
      <p className="text-gray-600 mt-8 max-w-3xl leading-8 whitespace-pre-wrap">{data?.content}</p>
    </main>
  );
}
TSX

python3 - <<'PY'
from pathlib import Path
p = Path("components/Nav.tsx")
s = p.read_text()
items = [
  '["Brain", "/brain"],',
  '["Triggers", "/triggers"],',
  '["Realtime", "/realtime"],',
  '["RAG", "/rag"],',
  '["Security", "/admin/security"],'
]
for item in items:
    if item not in s:
        s = s.replace('["Settings", "/settings"]', item + '\n  ["Settings", "/settings"]')
p.write_text(s)
PY

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json","utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts["super-worker"] = "node workers/super-worker.js";
fs.writeFileSync("package.json", JSON.stringify(pkg,null,2));
NODE

npm install

git add .
git commit -m "Add UNIC.ai super AI systems" || true

echo "DONE: Super AI systems added."
