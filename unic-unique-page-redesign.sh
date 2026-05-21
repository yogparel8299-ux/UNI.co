#!/bin/bash
set -e

echo "Creating unique premium page designs..."

mkdir -p components/layout components/ui

cat > components/layout/AppShell.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Agents", "/agents"],
  ["Skills", "/skills"],
  ["Workflow Studio", "/workflow-studio"],
  ["Datasets", "/datasets"],
  ["Marketplace", "/marketplace-explore"],
  ["Approvals", "/approval-inbox"],
  ["Realtime", "/realtime-dashboard"],
  ["Billing", "/billing-center"],
  ["Settings", "/settings"]
];

export default function AppShell({
  children
}: {
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);

  return (
    <main className="min-h-screen bg-[#f6f8fb] text-slate-950">
      <aside className="fixed left-0 top-0 z-40 hidden h-screen w-[280px] border-r border-slate-200 bg-white lg:block">
        <div className="p-6">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-full bg-slate-950 text-white font-black">U</div>
            <div>
              <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-slate-500">AI company OS</p>
            </div>
          </Link>
        </div>

        <div className="px-4">
          {nav.map(([label, href]) => (
            <Link
              key={href}
              href={href}
              className="mb-1 block rounded-2xl px-4 py-3 text-sm font-bold text-slate-600 hover:bg-slate-100 hover:text-slate-950"
            >
              {label}
            </Link>
          ))}
        </div>
      </aside>

      <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/80 backdrop-blur-xl lg:hidden">
        <div className="flex items-center justify-between p-5">
          <Link href="/" className="font-black">UNIC.ai</Link>
          <button onClick={() => setOpen(!open)} className="rounded-xl border px-4 py-2 font-bold">Menu</button>
        </div>
        {open && (
          <div className="border-t bg-white p-4">
            {nav.map(([label, href]) => (
              <Link key={href} href={href} className="block rounded-xl px-4 py-3 font-bold text-slate-600">
                {label}
              </Link>
            ))}
          </div>
        )}
      </header>

      <section className="lg:ml-[280px]">
        {children}
      </section>
    </main>
  );
}
TSX

cat > app/dashboard/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

export default function DashboardPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[40px] bg-slate-950 p-10 text-white shadow-2xl">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-300">Command Center</p>
          <h1 className="mt-5 max-w-4xl text-6xl font-black tracking-[-0.07em]">Operate your AI company from one place.</h1>
          <p className="mt-6 max-w-2xl text-white/60 leading-8">Monitor agents, workflows, approvals, connectors, memory and background execution.</p>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-4">
          {[
            ["Agents", "12", "AI workers ready"],
            ["Workflows", "28", "Execution pipelines"],
            ["Approvals", "4", "Waiting review"],
            ["Workers", "Online", "Background tasks active"]
          ].map(([a,b,c]) => (
            <div key={a} className="rounded-[30px] border border-slate-200 bg-white p-7 shadow-sm">
              <p className="text-sm font-bold text-slate-500">{a}</p>
              <p className="mt-3 text-4xl font-black tracking-[-0.06em]">{b}</p>
              <p className="mt-2 text-sm text-slate-500">{c}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 grid gap-6 lg:grid-cols-[1.3fr_.7fr]">
          <div className="rounded-[32px] border border-slate-200 bg-white p-8">
            <h2 className="text-4xl font-black tracking-[-0.05em]">Live execution stream</h2>
            <div className="mt-7 space-y-4">
              {["Dataset indexed", "Research agent completed brief", "Approval requested for email send", "Workflow run finished"].map((x) => (
                <div key={x} className="flex justify-between rounded-2xl border border-slate-200 p-5">
                  <span className="font-bold text-slate-700">{x}</span>
                  <span className="text-sm text-slate-400">now</span>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-[32px] border border-slate-200 bg-white p-8">
            <h2 className="text-3xl font-black tracking-[-0.05em]">Next actions</h2>
            <div className="mt-7 grid gap-3">
              {["Create agent", "Connect Gmail", "Upload dataset", "Run workflow"].map((x) => (
                <button key={x} className="rounded-2xl bg-slate-100 p-4 text-left font-bold">{x}</button>
              ))}
            </div>
          </div>
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/agents/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";
import Link from "next/link";

const agents = [
  ["Research Analyst", "Research", "Finds insights and summarizes markets"],
  ["Support Operator", "Support", "Handles tickets and drafts replies"],
  ["Sales Builder", "Sales", "Builds lead lists and outreach"],
  ["Finance Reviewer", "Finance", "Reviews costs and revenue signals"]
];

export default function AgentsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="flex flex-col justify-between gap-6 rounded-[36px] bg-white p-8 shadow-sm lg:flex-row lg:items-end">
          <div>
            <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-600">AI Workforce</p>
            <h1 className="mt-4 text-6xl font-black tracking-[-0.07em]">Agents</h1>
            <p className="mt-5 max-w-2xl text-slate-500 leading-8">Create AI employees, attach skills, connect tools and control how each worker executes tasks.</p>
          </div>
          <Link href="/builder" className="rounded-full bg-slate-950 px-7 py-4 font-bold text-white">Create Agent</Link>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-2 xl:grid-cols-4">
          {agents.map(([name, role, text]) => (
            <div key={name} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <div className="mb-7 h-24 rounded-[28px] bg-gradient-to-br from-blue-50 via-white to-emerald-50" />
              <p className="text-xs font-black uppercase tracking-[0.16em] text-blue-600">{role}</p>
              <h2 className="mt-3 text-3xl font-black tracking-[-0.05em]">{name}</h2>
              <p className="mt-4 text-slate-500 leading-7">{text}</p>
              <div className="mt-6 flex gap-3">
                <Link href="/skills" className="rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">Skills</Link>
                <Link href="/workflow-studio" className="rounded-full border border-slate-200 px-5 py-3 text-sm font-bold">Workflows</Link>
              </div>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/skills/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

const skills = ["Research", "Sales Outreach", "PDF Analysis", "Code Review", "Financial Analysis", "Legal Review", "Gmail Assistant", "Slack Reporter"];

export default function SkillsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[36px] bg-gradient-to-br from-blue-600 to-slate-950 p-10 text-white">
          <h1 className="text-6xl font-black tracking-[-0.07em]">Skills Library</h1>
          <p className="mt-5 max-w-2xl text-white/65 leading-8">Reusable capabilities that can be attached to any agent.</p>
        </div>

        <div className="mt-8 grid gap-5 md:grid-cols-4">
          {skills.map((skill) => (
            <div key={skill} className="rounded-[28px] border border-slate-200 bg-white p-6 shadow-sm">
              <div className="mb-6 h-16 w-16 rounded-2xl bg-blue-50" />
              <h2 className="text-2xl font-black tracking-[-0.05em]">{skill}</h2>
              <p className="mt-3 text-sm leading-6 text-slate-500">Attach this skill to agents and control execution through approvals and permissions.</p>
              <button className="mt-5 rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">Add Skill</button>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

export default function WorkflowStudioPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="grid gap-6 lg:grid-cols-[.8fr_1.2fr]">
          <div className="rounded-[36px] bg-white p-8 shadow-sm">
            <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-600">Builder</p>
            <h1 className="mt-4 text-5xl font-black tracking-[-0.07em]">Workflow Studio</h1>
            <p className="mt-5 text-slate-500 leading-8">Design task chains, approvals, model calls, memory lookups and tool actions.</p>
            <button className="mt-8 rounded-full bg-slate-950 px-7 py-4 font-bold text-white">New Workflow</button>
          </div>

          <div className="relative min-h-[560px] rounded-[36px] border border-slate-200 bg-white p-8 shadow-sm">
            <svg className="absolute inset-0 h-full w-full">
              <line x1="150" y1="150" x2="420" y2="240" stroke="#2563eb" strokeWidth="3" strokeDasharray="8 8" />
              <line x1="420" y1="240" x2="680" y2="150" stroke="#10b981" strokeWidth="3" strokeDasharray="8 8" />
            </svg>
            {[
              ["Trigger", "User command", 60, 90],
              ["Agent", "Research worker", 330, 180],
              ["Tool", "Gmail draft", 610, 90],
              ["Approval", "Human review", 330, 360]
            ].map(([a,b,x,y]) => (
              <div key={a} style={{left:x as number, top:y as number}} className="absolute w-56 rounded-[28px] border border-slate-200 bg-white p-5 shadow-xl">
                <p className="text-xs font-black uppercase tracking-[0.16em] text-blue-600">{a}</p>
                <h3 className="mt-2 text-xl font-black">{b}</h3>
              </div>
            ))}
          </div>
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/datasets/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

export default function DatasetsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[36px] bg-white p-10 shadow-sm">
          <h1 className="text-6xl font-black tracking-[-0.07em]">Datasets</h1>
          <p className="mt-5 max-w-2xl text-slate-500 leading-8">Upload files, build embeddings and create business memory for your agents.</p>

          <div className="mt-8 rounded-[32px] border-2 border-dashed border-blue-200 bg-blue-50/40 p-12 text-center">
            <h2 className="text-3xl font-black tracking-[-0.05em]">Upload company knowledge</h2>
            <p className="mt-4 text-slate-500">PDF, DOCX, CSV, TXT and structured data.</p>
            <button className="mt-7 rounded-full bg-slate-950 px-7 py-4 font-bold text-white">Upload Dataset</button>
          </div>
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/marketplace-explore/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

const assets = ["AI Sales Team", "Support Desk", "Research OS", "Content Factory", "Finance Analyst", "Hiring Pipeline"];

export default function MarketplacePage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Marketplace</h1>
        <p className="mt-5 max-w-2xl text-slate-500 leading-8">Install agent teams, skills, workflow systems and company templates.</p>

        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {assets.map((asset) => (
            <div key={asset} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <div className="mb-7 h-40 rounded-[28px] bg-gradient-to-br from-blue-50 via-white to-purple-50" />
              <h2 className="text-3xl font-black tracking-[-0.05em]">{asset}</h2>
              <p className="mt-4 text-slate-500 leading-7">A ready-to-install operating pack with agents, workflows and skills.</p>
              <button className="mt-7 rounded-full bg-slate-950 px-6 py-4 font-bold text-white">View Pack</button>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/approval-inbox/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

export default function ApprovalInboxPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Approval Inbox</h1>
        <p className="mt-5 max-w-2xl text-slate-500 leading-8">Review sensitive actions before agents execute them.</p>

        <div className="mt-8 space-y-5">
          {["Send customer email", "Publish social post", "Run supplier outreach", "Update CRM record"].map((x) => (
            <div key={x} className="flex items-center justify-between rounded-[28px] border border-slate-200 bg-white p-6 shadow-sm">
              <div>
                <h2 className="text-2xl font-black tracking-[-0.04em]">{x}</h2>
                <p className="mt-2 text-slate-500">Requires human approval before execution.</p>
              </div>
              <div className="flex gap-3">
                <button className="rounded-full border border-slate-200 px-5 py-3 font-bold">Reject</button>
                <button className="rounded-full bg-slate-950 px-5 py-3 font-bold text-white">Approve</button>
              </div>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/realtime-dashboard/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

export default function RealtimeDashboardPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[36px] bg-slate-950 p-10 text-white">
          <h1 className="text-6xl font-black tracking-[-0.07em]">Realtime Operations</h1>
          <p className="mt-5 max-w-2xl text-white/60 leading-8">Live execution events, workers, connector syncs and workflow activity.</p>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {["Worker status", "Execution stream", "Connector sync"].map((x) => (
            <div key={x} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{x}</h2>
              <div className="mt-8 h-40 rounded-[24px] bg-gradient-to-t from-blue-100 to-white" />
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/billing-center/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

const plans = ["Starter", "Builder", "Company", "Enterprise"];

export default function BillingPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Billing</h1>
        <p className="mt-5 max-w-2xl text-slate-500 leading-8">Manage subscription, platform credits and usage limits.</p>

        <div className="mt-8 grid gap-6 md:grid-cols-4">
          {plans.map((plan) => (
            <div key={plan} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{plan}</h2>
              <p className="mt-4 text-slate-500 leading-7">Credit-based workspace access for AI operations.</p>
              <button className="mt-7 rounded-full bg-slate-950 px-6 py-4 font-bold text-white">Select</button>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

cat > app/settings/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

export default function SettingsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Settings</h1>
        <div className="mt-8 grid gap-6 lg:grid-cols-2">
          {["Workspace", "Security", "Model Keys", "Team Access"].map((x) => (
            <div key={x} className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-sm">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{x}</h2>
              <p className="mt-4 text-slate-500 leading-7">Configure workspace controls and permissions.</p>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
TSX

npm run build
git add app components
git commit -m "Redesign core pages with unique premium layouts" || true
git push origin main
