#!/bin/bash
set -e

echo "Adding final UNIC.ai product layer..."

mkdir -p app/{workflow-studio,marketplace-explore,billing-center,admin-console,command-history,brain-search,swarm-visualizer,live-runtime,final-onboarding}
mkdir -p app/api/{rate-limit-check,command-save,company-settings,workflow-template-use,brain-query}
mkdir -p components/{workflow,marketplace,billing,admin,common}
mkdir -p lib/{auth,rate-limit,company}

cat > .gitignore <<'GIT'
node_modules/
.next/
.env
.env.local
.env.production
.vercel/
dist/
build/
.DS_Store
GIT

cat > lib/auth/require-company.ts <<'TS'
import { NextRequest } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function requireCompanyAccess(req: NextRequest, companyId: string) {
  const userId = req.headers.get("x-unic-user-id");

  if (!companyId) {
    return {
      ok: false,
      error: "company_id is required."
    };
  }

  if (!userId) {
    return {
      ok: false,
      error: "Missing x-unic-user-id header. Add real auth session middleware before production."
    };
  }

  const { data } = await supabaseAdmin
    .from("company_members")
    .select("*")
    .eq("company_id", companyId)
    .eq("user_id", userId)
    .limit(1)
    .single();

  if (!data) {
    return {
      ok: false,
      error: "User does not have access to this company."
    };
  }

  return {
    ok: true,
    userId
  };
}
TS

cat > lib/rate-limit/check.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function checkRateLimit({
  companyId,
  route,
  identifier,
  limit = 100,
  windowMinutes = 60
}: {
  companyId: string;
  route: string;
  identifier: string;
  limit?: number;
  windowMinutes?: number;
}) {
  const since = new Date(Date.now() - windowMinutes * 60 * 1000).toISOString();

  const { count } = await supabaseAdmin
    .from("rate_limit_events")
    .select("*", { count: "exact", head: true })
    .eq("company_id", companyId)
    .eq("route", route)
    .eq("identifier", identifier)
    .gte("created_at", since);

  const requestCount = Number(count || 0) + 1;
  const allowed = requestCount <= limit;

  await supabaseAdmin.from("rate_limit_events").insert({
    company_id: companyId,
    route,
    identifier,
    allowed,
    request_count: requestCount,
    limit_count: limit
  });

  return {
    allowed,
    requestCount,
    limit,
    remaining: Math.max(0, limit - requestCount)
  };
}
TS

cat > app/api/rate-limit-check/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { checkRateLimit } from "@/lib/rate-limit/check";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const result = await checkRateLimit({
      companyId: body.company_id,
      route: body.route || "unknown",
      identifier: body.identifier || "anonymous",
      limit: body.limit || 100,
      windowMinutes: body.window_minutes || 60
    });

    return NextResponse.json({
      ok: true,
      result
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/command-save/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("command_history")
      .insert({
        company_id: body.company_id,
        user_id: body.user_id || null,
        command: body.command,
        response: body.response || {},
        status: body.status || "completed"
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      command: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/company-settings/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("company_settings")
      .upsert({
        company_id: body.company_id,
        brand_name: body.brand_name || "UNIC.ai",
        theme: body.theme || "light",
        default_model_provider: body.default_model_provider || "openai",
        default_model: body.default_model || "gpt-4o-mini",
        enable_marketplace: body.enable_marketplace ?? true,
        enable_connectors: body.enable_connectors ?? true,
        enable_swarm_mode: body.enable_swarm_mode ?? true,
        enable_billing: body.enable_billing ?? true,
        settings: body.settings || {}
      }, { onConflict: "company_id" })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      settings: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/workflow-template-use/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: template, error: templateError } = await supabaseAdmin
      .from("workflow_templates")
      .select("*")
      .eq("id", body.template_id)
      .single();

    if (templateError) throw templateError;

    const { data: workflow, error: workflowError } = await supabaseAdmin
      .from("workflow_builders")
      .insert({
        company_id: body.company_id,
        name: template.title,
        graph: template.template_graph,
        status: "draft"
      })
      .select()
      .single();

    if (workflowError) throw workflowError;

    return NextResponse.json({
      ok: true,
      workflow
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/brain-query/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { embedText } from "@/lib/datasets/embed";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const embedding = await embedText(body.query);

    const memory = await supabaseAdmin.rpc("match_memory", {
      query_embedding: embedding,
      match_company_id: body.company_id,
      match_count: body.match_count || 8
    });

    const datasets = await supabaseAdmin.rpc("match_dataset_chunks", {
      query_embedding: embedding,
      match_company_id: body.company_id,
      match_count: body.match_count || 8
    });

    return NextResponse.json({
      ok: true,
      memory: memory.data || [],
      datasets: datasets.data || []
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      { status: 500 }
    );
  }
}
TS

cat > components/common/SectionHeader.tsx <<'TSX'
export default function SectionHeader({
  label,
  title,
  subtitle
}: {
  label?: string;
  title: string;
  subtitle?: string;
}) {
  return (
    <div className="mb-8">
      {label && (
        <p className="text-green-600 font-bold mb-3">
          {label}
        </p>
      )}

      <h1 className="page-title">
        {title}
      </h1>

      {subtitle && (
        <p className="page-subtitle">
          {subtitle}
        </p>
      )}
    </div>
  );
}
TSX

cat > components/workflow/VisualWorkflowEditor.tsx <<'TSX'
"use client";

import { useState } from "react";

type Node = {
  id: string;
  type: string;
  label: string;
  x: number;
  y: number;
};

type Edge = {
  from: string;
  to: string;
};

export default function VisualWorkflowEditor() {
  const [nodes, setNodes] = useState<Node[]>([
    { id: "input", type: "trigger", label: "Trigger", x: 60, y: 110 },
    { id: "agent", type: "agent", label: "AI Agent", x: 340, y: 110 },
    { id: "tool", type: "tool", label: "Tool Action", x: 620, y: 110 }
  ]);

  const [edges, setEdges] = useState<Edge[]>([
    { from: "input", to: "agent" },
    { from: "agent", to: "tool" }
  ]);

  const [selected, setSelected] = useState<Node | null>(null);

  function addNode(type: string) {
    const id = `${type}-${Date.now()}`;

    setNodes([
      ...nodes,
      {
        id,
        type,
        label: type === "agent" ? "New Agent" : type === "tool" ? "New Tool" : "New Step",
        x: 120 + nodes.length * 80,
        y: 250
      }
    ]);
  }

  function exportGraph() {
    alert(JSON.stringify({ nodes, edges }, null, 2));
  }

  return (
    <div className="glass-card p-8">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-black tracking-[-0.04em]">
            Visual Workflow Builder
          </h2>
          <p className="text-gray-500 mt-2">
            Design agent workflows with triggers, agents, tools, memory and approvals.
          </p>
        </div>

        <div className="flex gap-3">
          <button className="secondary-button" onClick={() => addNode("agent")}>
            Add Agent
          </button>
          <button className="secondary-button" onClick={() => addNode("tool")}>
            Add Tool
          </button>
          <button className="primary-button" onClick={exportGraph}>
            Export Graph
          </button>
        </div>
      </div>

      <div className="relative mt-8 h-[560px] rounded-[32px] border border-black/10 bg-gradient-to-br from-white to-gray-50 overflow-hidden">
        <svg className="absolute inset-0 w-full h-full">
          {edges.map((edge, index) => {
            const from = nodes.find((n) => n.id === edge.from);
            const to = nodes.find((n) => n.id === edge.to);

            if (!from || !to) return null;

            return (
              <line
                key={index}
                x1={from.x + 90}
                y1={from.y + 40}
                x2={to.x}
                y2={to.y + 40}
                stroke="#22c55e"
                strokeWidth="3"
                strokeDasharray="8 8"
              />
            );
          })}
        </svg>

        {nodes.map((node) => (
          <button
            key={node.id}
            onClick={() => setSelected(node)}
            className="absolute w-[180px] h-[88px] rounded-[24px] bg-white border border-black/10 shadow-xl text-left p-4 hover:border-green-400 transition"
            style={{ left: node.x, top: node.y }}
          >
            <p className="text-xs text-green-600 font-bold uppercase">
              {node.type}
            </p>
            <p className="font-black mt-1">
              {node.label}
            </p>
          </button>
        ))}
      </div>

      {selected && (
        <div className="mt-6 rounded-[28px] border border-black/10 p-6 bg-white">
          <p className="font-black">
            Selected Node
          </p>
          <p className="text-gray-500 mt-2">
            {selected.label} — {selected.type}
          </p>
        </div>
      )}
    </div>
  );
}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import VisualWorkflowEditor from "@/components/workflow/VisualWorkflowEditor";

export default function WorkflowStudio() {
  return (
    <Shell
      title="Workflow Studio"
      subtitle="Drag-and-drop AI workflows, tool calls, approvals, memory and runtime execution."
    >
      <VisualWorkflowEditor />
    </Shell>
  );
}
TSX

cat > app/marketplace-explore/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function MarketplaceExplore() {
  const { data: listings } = await supabaseAdmin
    .from("marketplace_listings")
    .select("*")
    .eq("status", "active")
    .order("created_at", { ascending: false })
    .limit(60);

  const { data: categories } = await supabaseAdmin
    .from("marketplace_categories")
    .select("*")
    .eq("active", true);

  return (
    <Shell
      title="Marketplace Explore"
      subtitle="Buy, rent and license AI employees, workflows, datasets, prompt systems and memory packs."
    >
      <div className="flex gap-3 mb-8 flex-wrap">
        {(categories || []).map((cat) => (
          <span key={cat.id} className="status-pill">
            {cat.name}
          </span>
        ))}
      </div>

      <div className="grid grid-cols-3 gap-6">
        {(listings || []).map((item) => (
          <div key={item.id} className="glass-card p-6">
            <p className="text-green-600 font-bold uppercase text-xs">
              {item.listing_type}
            </p>

            <h2 className="text-2xl font-black tracking-[-0.03em] mt-3">
              {item.title}
            </h2>

            <p className="text-gray-500 mt-3 leading-7">
              {item.description || "Premium UNIC.ai marketplace asset."}
            </p>

            <p className="text-4xl font-black mt-6">
              {item.price || 0} credits
            </p>

            <div className="flex gap-3 mt-6">
              <button className="primary-button">
                Rent
              </button>
              <button className="secondary-button">
                Details
              </button>
            </div>
          </div>
        ))}

        {(!listings || listings.length === 0) && (
          <div className="glass-card p-10 text-gray-500 col-span-3">
            No marketplace listings yet.
          </div>
        )}
      </div>
    </Shell>
  );
}
TSX

cat > app/billing-center/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function BillingCenter() {
  const { data: plans } = await supabaseAdmin
    .from("platform_pricing_plans")
    .select("*")
    .order("monthly_price");

  const { data: packs } = await supabaseAdmin
    .from("credit_packs")
    .select("*")
    .eq("active", true)
    .order("price");

  return (
    <Shell
      title="Billing Center"
      subtitle="Affordable plans, credit packs and user-paid model routing."
    >
      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">
        Plans
      </h2>

      <div className="grid grid-cols-4 gap-6 mb-12">
        {(plans || []).map((plan) => (
          <div key={plan.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">
              {plan.name}
            </h3>

            <p className="text-4xl font-black mt-4">
              ${plan.monthly_price}
            </p>

            <p className="text-gray-500 mt-4">
              {plan.included_credits} credits included
            </p>

            <p className="text-green-600 font-bold mt-4">
              {plan.ownership_model}
            </p>

            <button className="primary-button mt-6">
              Choose Plan
            </button>
          </div>
        ))}
      </div>

      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">
        Credit Packs
      </h2>

      <div className="grid grid-cols-4 gap-6">
        {(packs || []).map((pack) => (
          <div key={pack.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">
              {pack.name}
            </h3>

            <p className="text-4xl font-black mt-4">
              ${pack.price}
            </p>

            <p className="text-gray-500 mt-4">
              {pack.credits} credits
            </p>

            <p className="text-green-600 font-bold mt-2">
              +{pack.bonus_credits} bonus
            </p>

            <button className="primary-button mt-6">
              Buy Credits
            </button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
TSX

cat > app/admin-console/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import Card from "@/components/Card";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function AdminConsole() {
  const tables = [
    "companies",
    "agents",
    "agent_runs",
    "tool_executions",
    "marketplace_orders",
    "payment_checkouts",
    "audit_events",
    "worker_health"
  ];

  const counts: any = {};

  for (const table of tables) {
    const { count } = await supabaseAdmin
      .from(table)
      .select("*", { count: "exact", head: true });

    counts[table] = count || 0;
  }

  return (
    <Shell
      title="Admin Console"
      subtitle="System-wide command center for platform health, usage and governance."
    >
      <div className="grid grid-cols-4 gap-6">
        <Card title="Companies" value={counts.companies} />
        <Card title="Agents" value={counts.agents} />
        <Card title="Agent Runs" value={counts.agent_runs} />
        <Card title="Tool Executions" value={counts.tool_executions} />
        <Card title="Orders" value={counts.marketplace_orders} />
        <Card title="Payments" value={counts.payment_checkouts} />
        <Card title="Audit Events" value={counts.audit_events} />
        <Card title="Workers" value={counts.worker_health} />
      </div>
    </Shell>
  );
}
TSX

cat > app/command-history/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function CommandHistory() {
  const { data } = await supabaseAdmin
    .from("command_history")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(100);

  return (
    <Shell
      title="Command History"
      subtitle="Every major AI command, response and generated structure."
    >
      <DataTable rows={data || []} />
    </Shell>
  );
}
TSX

cat > app/brain-search/page.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function BrainSearch() {
  const [companyId, setCompanyId] = useState("");
  const [query, setQuery] = useState("");
  const [result, setResult] = useState("");

  async function search() {
    const res = await fetch("/api/brain-query", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        query
      })
    });

    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Brain Search
        </h1>

        <p className="page-subtitle">
          Ask your company brain across memories, datasets and embeddings.
        </p>

        <div className="glass-card p-8 mt-10 max-w-4xl">
          <input
            className="input-box"
            placeholder="Company ID"
            value={companyId}
            onChange={(e) => setCompanyId(e.target.value)}
          />

          <textarea
            className="input-box mt-4 min-h-[160px]"
            placeholder="Ask your company brain..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />

          <button className="primary-button mt-6" onClick={search}>
            Search Brain
          </button>

          {result && (
            <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">
              {result}
            </pre>
          )}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/swarm-visualizer/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function SwarmVisualizer() {
  const { data: swarms } = await supabaseAdmin
    .from("swarms")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(20);

  const { data: messages } = await supabaseAdmin
    .from("swarm_messages")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(50);

  return (
    <Shell
      title="Swarm Visualizer"
      subtitle="Visualize AI teams, messages, delegation and agent-to-agent collaboration."
    >
      <div className="grid grid-cols-3 gap-6">
        {(swarms || []).map((swarm) => (
          <div key={swarm.id} className="glass-card p-6">
            <h2 className="text-2xl font-black">
              {swarm.name}
            </h2>

            <p className="text-gray-500 mt-3">
              {swarm.goal || "No goal set."}
            </p>

            <p className="status-pill mt-6">
              {swarm.status}
            </p>
          </div>
        ))}
      </div>

      <div className="glass-card p-8 mt-10">
        <h2 className="text-3xl font-black tracking-[-0.04em] mb-5">
          Swarm Messages
        </h2>

        <div className="space-y-4">
          {(messages || []).map((msg) => (
            <div key={msg.id} className="rounded-2xl border border-black/10 p-4">
              <p className="font-bold">
                {msg.message}
              </p>
              <p className="text-gray-500 text-sm mt-2">
                {new Date(msg.created_at).toLocaleString()}
              </p>
            </div>
          ))}
        </div>
      </div>
    </Shell>
  );
}
TSX

cat > app/live-runtime/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function LiveRuntime() {
  const { data } = await supabaseAdmin
    .from("realtime_streams")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(150);

  return (
    <Shell
      title="Live Runtime"
      subtitle="Realtime execution stream for agents, workflows, tools and swarms."
    >
      <DataTable rows={data || []} />
    </Shell>
  );
}
TSX

cat > app/final-onboarding/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function FinalOnboarding() {
  const { data } = await supabaseAdmin
    .from("onboarding_checklist")
    .select("*")
    .limit(100);

  return (
    <Shell
      title="Onboarding Progress"
      subtitle="Track every workspace setup step from first agent to first paid workflow."
    >
      <DataTable rows={data || []} />
    </Shell>
  );
}
TSX

cat > workers/all-workers.js <<'JS'
const { spawn } = require("child_process");

const workers = [
  ["runtime-worker", "workers/runtime-worker.js"],
  ["super-worker", "workers/super-worker.js"],
  ["connection-sync-worker", "workers/connection-sync-worker.js"],
  ["launch-worker", "workers/launch-worker.js"]
];

for (const [name, file] of workers) {
  const child = spawn("node", [file], {
    stdio: "inherit",
    env: process.env
  });

  child.on("exit", (code) => {
    console.log(`${name} exited with code ${code}`);
  });
}

console.log("UNIC.ai all workers started.");
JS

cat > scripts/digitalocean-all-workers.sh <<'SH'
#!/bin/bash
set -e

apt update && apt upgrade -y
apt install -y nodejs npm git curl
npm install -g pm2

npm install

pm2 start workers/runtime-worker.js --name unic-runtime-worker
pm2 start workers/super-worker.js --name unic-super-worker
pm2 start workers/connection-sync-worker.js --name unic-connection-worker
pm2 start workers/launch-worker.js --name unic-launch-worker

pm2 save
pm2 startup

echo "UNIC.ai workers started with PM2."
SH

python3 - <<'PY'
from pathlib import Path

p = Path("components/Nav.tsx")
s = p.read_text()

items = [
  '["Workflow Studio", "/workflow-studio"],',
  '["Marketplace Explore", "/marketplace-explore"],',
  '["Billing Center", "/billing-center"],',
  '["Admin Console", "/admin-console"],',
  '["Command History", "/command-history"],',
  '["Brain Search", "/brain-search"],',
  '["Swarm Visualizer", "/swarm-visualizer"],',
  '["Live Runtime", "/live-runtime"],',
  '["Final Onboarding", "/final-onboarding"],'
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
pkg.scripts["all-workers"] = "node workers/all-workers.js";
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
NODE

npm install

git add .
git commit -m "Add final UNIC.ai product UI security and workflow layer" || true

echo "DONE: final UNIC.ai product layer added."
