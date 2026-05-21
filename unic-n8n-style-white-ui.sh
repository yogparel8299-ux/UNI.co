#!/bin/bash
set -e

echo "Building UNIC.ai n8n-style white operational UI..."

mkdir -p components/ops
mkdir -p app/{dashboard,workflow-studio,agents,skills,datasets,approval-inbox,realtime-dashboard,marketplace-explore,billing-center,settings,agent-evolution}

cat > components/ops/OpsShell.tsx <<'TSX'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const nav = [
  ["Overview", "/dashboard"],
  ["Agents", "/agents"],
  ["Skills", "/skills"],
  ["Workflows", "/workflow-studio"],
  ["Datasets", "/datasets"],
  ["Approvals", "/approval-inbox"],
  ["Realtime", "/realtime-dashboard"],
  ["Marketplace", "/marketplace-explore"],
  ["Billing", "/billing-center"],
  ["Agent Evolution", "/agent-evolution"],
  ["Settings", "/settings"]
];

export default function OpsShell({
  title,
  subtitle,
  rightPanel,
  children
}: {
  title: string;
  subtitle?: string;
  rightPanel?: React.ReactNode;
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <main className="min-h-screen bg-[#f7f7f8] text-[#111111]">
      <aside className="fixed left-0 top-0 hidden h-screen w-[260px] border-r border-neutral-200 bg-white lg:block">
        <div className="border-b border-neutral-200 p-5">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-9 w-9 place-items-center rounded-xl bg-black text-white font-black">U</div>
            <div>
              <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-neutral-500">Operations workspace</p>
            </div>
          </Link>
        </div>

        <div className="p-3">
          {nav.map(([label, href]) => {
            const active = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                className={
                  active
                    ? "mb-1 flex rounded-xl bg-black px-3 py-2.5 text-sm font-bold text-white"
                    : "mb-1 flex rounded-xl px-3 py-2.5 text-sm font-semibold text-neutral-600 hover:bg-neutral-100 hover:text-black"
                }
              >
                {label}
              </Link>
            );
          })}
        </div>
      </aside>

      <section className={rightPanel ? "lg:ml-[260px] lg:mr-[320px]" : "lg:ml-[260px]"}>
        <header className="sticky top-0 z-20 border-b border-neutral-200 bg-white/85 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-4">
            <div>
              <h1 className="text-2xl font-black tracking-[-0.04em]">{title}</h1>
              {subtitle && <p className="mt-1 text-sm text-neutral-500">{subtitle}</p>}
            </div>

            <div className="flex items-center gap-2">
              <Link href="/signup" className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">
                Invite
              </Link>
              <Link href="/settings" className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">
                Settings
              </Link>
            </div>
          </div>
        </header>

        <div className="p-6">{children}</div>
      </section>

      {rightPanel && (
        <aside className="fixed right-0 top-0 hidden h-screen w-[320px] border-l border-neutral-200 bg-white lg:block">
          {rightPanel}
        </aside>
      )}
    </main>
  );
}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import OpsShell from "@/components/ops/OpsShell";

const nodes = [
  ["Trigger", "User command", "left-[70px] top-[120px]"],
  ["Agent", "Research Agent", "left-[360px] top-[190px]"],
  ["Memory", "Company Brain", "left-[650px] top-[95px]"],
  ["Approval", "Human Review", "left-[650px] top-[330px]"],
  ["Tool", "Gmail Draft", "left-[930px] top-[210px]"]
];

export default function WorkflowStudioPage() {
  return (
    <OpsShell
      title="Workflow Studio"
      subtitle="Drag-and-drop AI workflows with agents, tools, memory and approvals."
      rightPanel={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-neutral-400">Properties</p>
          <h2 className="mt-3 text-xl font-black">Selected Node</h2>
          <div className="mt-5 space-y-4">
            <input className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Node name" />
            <select className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm">
              <option>Agent</option>
              <option>Skill</option>
              <option>Tool</option>
              <option>Approval</option>
              <option>Memory</option>
            </select>
            <textarea className="min-h-[130px] w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Instructions" />
            <button className="w-full rounded-lg bg-black px-4 py-3 text-sm font-bold text-white">Save Node</button>
          </div>
        </div>
      }
    >
      <div className="mb-4 flex items-center justify-between">
        <div className="flex gap-2">
          {["Trigger", "Agent", "Skill", "Tool", "Memory", "Approval", "Condition"].map((x) => (
            <button key={x} className="rounded-lg border border-neutral-200 bg-white px-3 py-2 text-sm font-bold">
              + {x}
            </button>
          ))}
        </div>

        <button className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">
          Run Workflow
        </button>
      </div>

      <div className="relative h-[720px] overflow-hidden rounded-2xl border border-neutral-200 bg-white">
        <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />

        <svg className="absolute inset-0 h-full w-full">
          <path d="M250 170 C330 170 300 235 360 235" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M550 235 C620 235 595 150 650 150" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M550 235 C620 235 595 385 650 385" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M835 385 C900 385 870 265 930 265" fill="none" stroke="#111" strokeWidth="2" />
        </svg>

        {nodes.map(([type, label, pos]) => (
          <div key={label} className={`absolute ${pos} w-[190px] rounded-xl border border-neutral-300 bg-white p-4 shadow-lg`}>
            <p className="text-[11px] font-black uppercase tracking-[0.14em] text-neutral-400">{type}</p>
            <h3 className="mt-2 font-black">{label}</h3>
            <p className="mt-2 text-xs text-neutral-500">Click to configure</p>
          </div>
        ))}
      </div>
    </OpsShell>
  );
}
TSX

cat > app/dashboard/page.tsx <<'TSX'
import OpsShell from "@/components/ops/OpsShell";

export default function DashboardPage() {
  return (
    <OpsShell title="Overview" subtitle="Operational view of agents, workflows and live execution.">
      <div className="grid gap-4 md:grid-cols-4">
        {[
          ["Agents", "12"],
          ["Workflows", "28"],
          ["Pending approvals", "4"],
          ["Worker status", "Online"]
        ].map(([label, value]) => (
          <div key={label} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <p className="text-sm font-semibold text-neutral-500">{label}</p>
            <p className="mt-3 text-3xl font-black tracking-[-0.04em]">{value}</p>
          </div>
        ))}
      </div>

      <div className="mt-5 grid gap-5 lg:grid-cols-[1.4fr_.6fr]">
        <div className="rounded-2xl border border-neutral-200 bg-white p-5">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-black">Recent executions</h2>
            <button className="rounded-lg border border-neutral-200 px-3 py-2 text-sm font-bold">View all</button>
          </div>
          <div className="mt-5 space-y-2">
            {["Research workflow completed", "Gmail draft created", "Dataset indexed", "Approval requested"].map((x) => (
              <div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4">
                <span className="font-semibold">{x}</span>
                <span className="text-sm text-neutral-500">live</span>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-2xl border border-neutral-200 bg-white p-5">
          <h2 className="text-xl font-black">Quick start</h2>
          <div className="mt-5 grid gap-2">
            {["Create agent", "Add skill", "Build workflow", "Connect Gmail"].map((x) => (
              <button key={x} className="rounded-xl bg-neutral-100 p-4 text-left text-sm font-bold">{x}</button>
            ))}
          </div>
        </div>
      </div>
    </OpsShell>
  );
}
TSX

cat > app/agents/page.tsx <<'TSX'
import OpsShell from "@/components/ops/OpsShell";

export default function AgentsPage() {
  return (
    <OpsShell
      title="Agents"
      subtitle="Persistent AI workers with skills, tools, memory, budgets and version history."
      rightPanel={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-neutral-400">Agent Config</p>
          <h2 className="mt-3 text-xl font-black">Create Agent</h2>
          <div className="mt-5 space-y-4">
            <input className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Agent name" />
            <input className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Role" />
            <textarea className="min-h-[120px] w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="System instructions" />
            <button className="w-full rounded-lg bg-black px-4 py-3 text-sm font-bold text-white">Create Agent</button>
          </div>
        </div>
      }
    >
      <div className="grid gap-4 md:grid-cols-3">
        {["Research Analyst", "Sales Operator", "Support Agent", "Finance Reviewer", "Ops Manager", "Content Strategist"].map((agent) => (
          <div key={agent} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <div className="mb-5 h-20 rounded-xl bg-neutral-100" />
            <h2 className="text-xl font-black">{agent}</h2>
            <p className="mt-2 text-sm text-neutral-500">Active AI worker with skills, memory and tool access.</p>
            <div className="mt-5 flex gap-2">
              <button className="rounded-lg bg-black px-3 py-2 text-xs font-bold text-white">Open</button>
              <button className="rounded-lg border border-neutral-200 px-3 py-2 text-xs font-bold">Skills</button>
            </div>
          </div>
        ))}
      </div>
    </OpsShell>
  );
}
TSX

cat > app/agent-evolution/page.tsx <<'TSX'
import OpsShell from "@/components/ops/OpsShell";

export default function AgentEvolutionPage() {
  return (
    <OpsShell
      title="Agent Evolution"
      subtitle="Review agent performance and approve self-improvement suggestions."
      rightPanel={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-neutral-400">Policy</p>
          <h2 className="mt-3 text-xl font-black">Evolution Guardrails</h2>
          <div className="mt-5 space-y-3 text-sm text-neutral-600">
            <p>Agents can suggest prompt, skill and workflow improvements.</p>
            <p>Self-updates require approval before being applied.</p>
            <p>Every improvement creates a version snapshot.</p>
          </div>
        </div>
      }
    >
      <div className="grid gap-4">
        {[
          ["Research Analyst", "Improve source-ranking logic", "Pending approval"],
          ["Support Operator", "Add escalation rule for refunds", "Pending approval"],
          ["Sales Builder", "Rewrite outreach tone based on response data", "Suggested"]
        ].map(([agent, change, status]) => (
          <div key={agent} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-black">{agent}</h2>
                <p className="mt-2 text-neutral-500">{change}</p>
              </div>
              <span className="rounded-full bg-neutral-100 px-3 py-1 text-xs font-bold">{status}</span>
            </div>
            <div className="mt-5 flex gap-2">
              <button className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">Approve</button>
              <button className="rounded-lg border border-neutral-200 px-4 py-2 text-sm font-bold">Reject</button>
            </div>
          </div>
        ))}
      </div>
    </OpsShell>
  );
}
TSX

npm run build
git add app components/ops
git commit -m "Add n8n-style white operational UI and workflow canvas" || true
git push origin main
