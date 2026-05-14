#!/bin/bash
set -e

echo "Adding UNIC.ai Connection Layer..."

mkdir -p app/{connection-layer,mcp-gateway}
mkdir -p app/api/{connection-link,connection-callback,connection-tools,connection-tool-call,connection-sync}
mkdir -p app/api/mcp/{tools,call}
mkdir -p lib/connection workers

cat > lib/connection/composio.ts <<'TS'
export async function createConnectionLink({
  userId,
  toolkit,
  redirectUrl
}: {
  userId: string;
  toolkit: string;
  redirectUrl: string;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;

  if (!apiKey) {
    throw new Error("COMPOSIO_API_KEY is missing.");
  }

  const response = await fetch("https://backend.composio.dev/api/v3.1/connected_accounts/link", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      redirect_url: redirectUrl
    })
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to create Composio connection link.");
  }

  return data;
}

export async function executeTool({
  userId,
  toolkit,
  toolSlug,
  args
}: {
  userId: string;
  toolkit: string;
  toolSlug: string;
  args: any;
}) {
  const apiKey = process.env.COMPOSIO_API_KEY;

  if (!apiKey) {
    throw new Error("COMPOSIO_API_KEY is missing.");
  }

  const response = await fetch("https://backend.composio.dev/api/v3/tools/execute", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      toolkit,
      tool_slug: toolSlug,
      arguments: args || {}
    })
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Tool execution failed.");
  }

  return data;
}
TS

cat > app/connection-layer/page.tsx <<'TSX'
"use client";

import { useState } from "react";

const providers = [
  ["slack", "Slack", "Messages, alerts, approvals, team updates"],
  ["gmail", "Gmail", "Email search, send, classify, reply"],
  ["google_drive", "Google Drive", "Files, documents, datasets"],
  ["notion", "Notion", "Docs, knowledge base, memory sync"],
  ["github", "GitHub", "Issues, repos, code tasks"],
  ["hubspot", "HubSpot", "CRM, leads, contacts"],
  ["zapier", "Zapier", "Webhook automation layer"],
  ["stripe", "Stripe", "Charges, invoices, financial events"]
];

export default function ConnectionLayerPage() {
  const [companyId, setCompanyId] = useState("");
  const [userId, setUserId] = useState("");
  const [result, setResult] = useState("");

  async function connect(provider: string) {
    const res = await fetch("/api/connection-link", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        user_id: userId,
        provider,
        redirect_url: `${window.location.origin}/connection-layer`
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));

    const url = data?.link?.redirect_url || data?.link?.url || data?.link?.link;

    if (url) {
      window.open(url, "_blank");
    }
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Connection Layer</h1>
        <p className="page-subtitle">
          One-click OAuth-style connections for Slack, Gmail, Notion, GitHub, Drive, HubSpot, Zapier and Stripe.
          Connected apps become agent tools, memory sources, profile signals and trigger sources.
        </p>

        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input
            className="input-box"
            placeholder="Company ID"
            value={companyId}
            onChange={(e) => setCompanyId(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="User ID"
            value={userId}
            onChange={(e) => setUserId(e.target.value)}
          />
        </div>

        <div className="grid grid-cols-4 gap-6 mt-10">
          {providers.map(([provider, name, text]) => (
            <div key={provider} className="glass-card p-6">
              <h2 className="text-2xl font-black tracking-[-0.03em]">{name}</h2>
              <p className="text-gray-500 mt-3 leading-7">{text}</p>
              <button className="primary-button mt-6" onClick={() => connect(provider)}>
                Connect
              </button>
            </div>
          ))}
        </div>

        {result && (
          <pre className="mt-10 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">
            {result}
          </pre>
        )}
      </section>
    </main>
  );
}
TSX

cat > app/mcp-gateway/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function MCPGatewayPage() {
  const { data: tools } = await supabaseAdmin
    .from("tool_registry")
    .select("*")
    .order("provider", { ascending: true });

  return (
    <Shell
      title="MCP Gateway"
      subtitle="Expose connected tools to AI agents through a universal MCP-style gateway."
    >
      <DataTable rows={tools || []} />
    </Shell>
  );
}
TSX

cat > app/api/connection-link/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createConnectionLink } from "@/lib/connection/composio";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.user_id || !body.provider) {
      return NextResponse.json(
        { ok: false, error: "company_id, user_id and provider are required." },
        { status: 400 }
      );
    }

    const link = await createConnectionLink({
      userId: body.user_id,
      toolkit: body.provider,
      redirectUrl: body.redirect_url || `${process.env.NEXT_PUBLIC_APP_URL}/connection-layer`
    });

    const { data: session, error } = await supabaseAdmin
      .from("connector_sessions")
      .insert({
        company_id: body.company_id,
        user_id: body.user_id,
        provider: body.provider,
        auth_provider: "composio",
        external_connection_id: link.connected_account_id || link.connection_id || null,
        status: "pending",
        metadata: link
      })
      .select()
      .single();

    if (error) throw error;

    await supabaseAdmin.from("connector_sync_jobs").insert({
      company_id: body.company_id,
      connector_session_id: session.id,
      provider: body.provider,
      sync_type: "memory",
      status: "pending",
      next_sync_at: new Date().toISOString()
    });

    return NextResponse.json({
      ok: true,
      session,
      link
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
TS

cat > app/api/connection-callback/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.session_id) {
      return NextResponse.json(
        { ok: false, error: "session_id is required." },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("connector_sessions")
      .update({
        status: "connected",
        external_connection_id: body.external_connection_id || null,
        scopes: body.scopes || [],
        metadata: body.metadata || {},
        connected_at: new Date().toISOString()
      })
      .eq("id", body.session_id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      session: data
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
TS

cat > app/api/connection-tools/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    let query = supabaseAdmin
      .from("tool_registry")
      .select("*")
      .eq("enabled", true);

    if (body.provider) {
      query = query.eq("provider", body.provider);
    }

    const { data, error } = await query.order("provider", { ascending: true });

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      tools: data || []
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
TS

cat > app/api/connection-tool-call/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { executeTool } from "@/lib/connection/composio";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.user_id || !body.provider || !body.tool_slug) {
      return NextResponse.json(
        { ok: false, error: "company_id, user_id, provider and tool_slug are required." },
        { status: 400 }
      );
    }

    const { data: execution, error: insertError } = await supabaseAdmin
      .from("tool_executions")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        provider: body.provider,
        tool_slug: body.tool_slug,
        input: body.arguments || {},
        status: "running"
      })
      .select()
      .single();

    if (insertError) throw insertError;

    const output = await executeTool({
      userId: body.user_id,
      toolkit: body.provider,
      toolSlug: body.tool_slug,
      args: body.arguments || {}
    });

    await supabaseAdmin
      .from("tool_executions")
      .update({
        output,
        status: "completed",
        completed_at: new Date().toISOString()
      })
      .eq("id", execution.id);

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      run_id: null,
      event_type: "tool_executed",
      message: `${body.provider}.${body.tool_slug} executed.`,
      metadata: {
        execution_id: execution.id
      }
    });

    return NextResponse.json({
      ok: true,
      execution_id: execution.id,
      output
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
TS

cat > app/api/connection-sync/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: sessions, error } = await supabaseAdmin
      .from("connector_sessions")
      .select("*")
      .eq("company_id", body.company_id)
      .eq("status", "connected");

    if (error) throw error;

    for (const session of sessions || []) {
      await supabaseAdmin.from("memory_tree").insert({
        company_id: session.company_id,
        source_type: "connector_sync",
        source_provider: session.provider,
        source_id: session.external_connection_id,
        title: `${session.provider} sync`,
        content: `Synced connection metadata for ${session.provider}. Real content sync requires provider-specific Composio tools.`,
        metadata: session.metadata || {},
        synced_at: new Date().toISOString()
      });

      await supabaseAdmin
        .from("connector_sync_jobs")
        .update({
          status: "completed",
          last_synced_at: new Date().toISOString(),
          next_sync_at: new Date(Date.now() + 20 * 60 * 1000).toISOString()
        })
        .eq("connector_session_id", session.id);
    }

    return NextResponse.json({
      ok: true,
      synced: sessions?.length || 0
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
TS

cat > app/api/mcp/tools/route.ts <<'TS'
import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function GET() {
  const { data, error } = await supabaseAdmin
    .from("tool_registry")
    .select("*")
    .eq("enabled", true)
    .order("provider", { ascending: true });

  if (error) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }

  return NextResponse.json({
    ok: true,
    tools: (data || []).map((tool) => ({
      name: `${tool.provider}.${tool.tool_slug}`,
      description: tool.description,
      input_schema: tool.input_schema || {}
    }))
  });
}
TS

cat > app/api/mcp/call/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { executeTool } from "@/lib/connection/composio";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const [provider, toolSlug] = String(body.name || "").split(".");

    if (!provider || !toolSlug) {
      return NextResponse.json(
        { ok: false, error: "Tool name must be provider.tool_slug." },
        { status: 400 }
      );
    }

    const output = await executeTool({
      userId: body.user_id,
      toolkit: provider,
      toolSlug,
      args: body.arguments || {}
    });

    return NextResponse.json({
      ok: true,
      output
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
TS

cat > workers/connection-sync-worker.js <<'JS'
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function runConnectionSync() {
  const { data: jobs, error } = await supabase
    .from("connector_sync_jobs")
    .select("*")
    .eq("status", "pending")
    .lte("next_sync_at", new Date().toISOString())
    .limit(25);

  if (error) {
    console.error("Sync job error:", error.message);
    return;
  }

  for (const job of jobs || []) {
    await supabase.from("memory_tree").insert({
      company_id: job.company_id,
      source_type: "connector_auto_sync",
      source_provider: job.provider,
      title: `${job.provider} auto sync`,
      content: `Auto-sync placeholder for ${job.provider}. Replace with provider-specific Composio tool fetch.`,
      metadata: {
        sync_job_id: job.id
      },
      synced_at: new Date().toISOString()
    });

    await supabase
      .from("connector_sync_jobs")
      .update({
        status: "pending",
        last_synced_at: new Date().toISOString(),
        next_sync_at: new Date(Date.now() + 20 * 60 * 1000).toISOString()
      })
      .eq("id", job.id);

    console.log("Synced connector job", job.id);
  }
}

console.log("UNIC.ai connection sync worker running...");
setInterval(runConnectionSync, 20 * 60 * 1000);
runConnectionSync();
JS

python3 - <<'PY'
from pathlib import Path

p = Path("components/Nav.tsx")
s = p.read_text()

items = [
  '["Connection Layer", "/connection-layer"],',
  '["MCP Gateway", "/mcp-gateway"],'
]

for item in items:
    if item not in s:
        s = s.replace('["Settings", "/settings"]', item + '\n  ["Settings", "/settings"]')

p.write_text(s)
PY

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts["connection-worker"] = "node workers/connection-sync-worker.js";
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
NODE

git add .
git commit -m "Add UNIC.ai connection layer and MCP gateway" || true

echo "DONE: UNIC.ai Connection Layer added."
