#!/bin/bash
set -e

echo "Replacing entire app shell with premium unified UI..."

mkdir -p components/ui
mkdir -p components/layout

cat > components/layout/AppShell.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";

const groups = [
  {
    title: "Workspace",
    items: [
      ["Dashboard", "/dashboard"],
      ["Agents", "/agents"],
      ["Skills", "/skills"],
      ["Swarms", "/swarms"],
      ["Tasks", "/tasks"]
    ]
  },
  {
    title: "Automation",
    items: [
      ["Workflow Studio", "/workflow-studio"],
      ["Approvals", "/approval-inbox"],
      ["Schedules", "/schedules"],
      ["Realtime", "/realtime-dashboard"]
    ]
  },
  {
    title: "Data",
    items: [
      ["Datasets", "/datasets"],
      ["Company Brain", "/brain"],
      ["RAG Search", "/rag"],
      ["Vault", "/vault"]
    ]
  },
  {
    title: "Business",
    items: [
      ["Marketplace", "/marketplace-explore"],
      ["Billing", "/billing-center"],
      ["Usage", "/usage-dashboard"],
      ["Settings", "/settings"]
    ]
  }
];

export default function AppShell({
  title,
  subtitle,
  children
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState<Record<string, boolean>>({
    Workspace: true,
    Automation: true
  });

  return (
    <main className="min-h-screen bg-[#f6f8fb] text-[#111827]">
      <aside className="fixed left-0 top-0 z-40 hidden h-screen w-[290px] overflow-y-auto border-r border-slate-200 bg-white lg:block">
        <div className="p-6">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-full bg-[#111827] text-white font-black">
              U
            </div>

            <div>
              <p className="font-black tracking-[-0.04em] text-xl">
                UNIC.ai
              </p>

              <p className="text-xs text-slate-500">
                AI company operating system
              </p>
            </div>
          </Link>
        </div>

        <div className="px-4 pb-10">
          {groups.map((group) => (
            <div key={group.title} className="mb-5">
              <button
                onClick={() =>
                  setOpen({
                    ...open,
                    [group.title]: !open[group.title]
                  })
                }
                className="flex w-full items-center justify-between rounded-2xl px-4 py-3 text-left text-sm font-black text-slate-700 hover:bg-slate-100"
              >
                <span>{group.title}</span>
                <span>{open[group.title] ? "−" : "+"}</span>
              </button>

              {open[group.title] && (
                <div className="mt-2 space-y-1">
                  {group.items.map(([label, href]) => (
                    <Link
                      key={href}
                      href={href}
                      className="block rounded-2xl px-4 py-3 text-sm font-semibold text-slate-500 hover:bg-slate-100 hover:text-slate-900"
                    >
                      {label}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      </aside>

      <section className="lg:ml-[290px]">
        <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/80 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-5">
            <div>
              <h1 className="text-4xl font-black tracking-[-0.06em]">
                {title}
              </h1>

              {subtitle && (
                <p className="mt-2 text-sm text-slate-500">
                  {subtitle}
                </p>
              )}
            </div>

            <div className="flex items-center gap-3">
              <Link
                href="/notifications-center"
                className="rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700"
              >
                Notifications
              </Link>

              <Link
                href="/settings"
                className="rounded-2xl bg-[#111827] px-5 py-3 text-sm font-bold text-white"
              >
                Settings
              </Link>
            </div>
          </div>
        </header>

        <div className="p-6">
          {children}
        </div>
      </section>
    </main>
  );
}
TSX

cat > components/ui/StatCard.tsx <<'TSX'
export default function StatCard({
  title,
  value,
  subtitle
}: {
  title: string;
  value: string;
  subtitle?: string;
}) {
  return (
    <div className="rounded-[30px] border border-slate-200 bg-white p-7 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
      <p className="text-sm font-bold text-slate-500">
        {title}
      </p>

      <p className="mt-3 text-5xl font-black tracking-[-0.06em]">
        {value}
      </p>

      {subtitle && (
        <p className="mt-3 text-sm text-slate-500">
          {subtitle}
        </p>
      )}
    </div>
  );
}
TSX

cat > components/ui/Empty.tsx <<'TSX'
import Link from "next/link";

export default function Empty({
  title,
  text,
  action,
  href
}: {
  title: string;
  text: string;
  action?: string;
  href?: string;
}) {
  return (
    <div className="rounded-[32px] border border-slate-200 bg-white p-14 text-center shadow-[0_20px_80px_rgba(15,23,42,.05)]">
      <div className="mx-auto mb-7 h-20 w-20 rounded-full bg-blue-50" />

      <h2 className="text-4xl font-black tracking-[-0.05em]">
        {title}
      </h2>

      <p className="mx-auto mt-5 max-w-2xl text-slate-500 leading-8">
        {text}
      </p>

      {action && href && (
        <Link
          href={href}
          className="mt-8 inline-flex rounded-full bg-[#111827] px-7 py-4 text-sm font-bold text-white"
        >
          {action}
        </Link>
      )}
    </div>
  );
}
TSX

cat > app/dashboard/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";
import StatCard from "@/components/ui/StatCard";

export default function DashboardPage() {
  return (
    <AppShell
      title="Dashboard"
      subtitle="Manage AI operations, connected tools and execution activity."
    >
      <div className="grid grid-cols-1 gap-5 md:grid-cols-4">
        <StatCard
          title="Agents"
          value="12"
          subtitle="Connected AI workers"
        />

        <StatCard
          title="Workflows"
          value="28"
          subtitle="Automation pipelines"
        />

        <StatCard
          title="Connectors"
          value="9"
          subtitle="Integrated business tools"
        />

        <StatCard
          title="Executions"
          value="Live"
          subtitle="Realtime worker activity"
        />
      </div>

      <div className="mt-7 grid grid-cols-1 gap-6 lg:grid-cols-[1.2fr_.8fr]">
        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <h2 className="text-4xl font-black tracking-[-0.05em]">
            Workspace activity
          </h2>

          <div className="mt-8 space-y-4">
            {[
              "Agent connected to Slack",
              "Workflow execution completed",
              "Dataset uploaded to memory",
              "Approval request submitted",
              "Connector synchronized"
            ].map((x) => (
              <div
                key={x}
                className="flex items-center justify-between rounded-2xl border border-slate-200 p-5"
              >
                <span className="font-semibold text-slate-700">
                  {x}
                </span>

                <span className="text-xs font-bold text-slate-400">
                  just now
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <h2 className="text-3xl font-black tracking-[-0.05em]">
            Quick actions
          </h2>

          <div className="mt-7 grid gap-4">
            {[
              "Create Agent",
              "Add Skill",
              "Connect Tool",
              "Create Workflow",
              "Upload Dataset"
            ].map((x) => (
              <button
                key={x}
                className="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-5 text-left text-sm font-bold text-slate-700 hover:bg-slate-100"
              >
                {x}
              </button>
            ))}
          </div>
        </div>
      </div>
    </AppShell>
  );
}
TSX

cat > app/agents/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";
import Empty from "@/components/ui/Empty";

export default function AgentsPage() {
  return (
    <AppShell
      title="Agents"
      subtitle="Create AI workers with connected skills and tools."
    >
      <Empty
        title="No agents yet"
        text="Create your first AI worker and assign skills, memory, workflows and connected tools."
        action="Create Agent"
        href="/builder"
      />
    </AppShell>
  );
}
TSX

cat > app/datasets/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";
import Empty from "@/components/ui/Empty";

export default function DatasetsPage() {
  return (
    <AppShell
      title="Datasets"
      subtitle="Upload files and build company memory for AI execution."
    >
      <Empty
        title="No datasets uploaded"
        text="Upload PDF, CSV, DOCX and structured business data for retrieval and AI memory."
        action="Upload Dataset"
        href="/dataset-lab"
      />
    </AppShell>
  );
}
TSX

cat > app/marketplace-explore/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";

const items = [
  "Customer Support Agent",
  "Research Workflow",
  "Sales Qualification System",
  "Operations Copilot",
  "Marketing Automation Stack",
  "Finance Review Pipeline"
];

export default function MarketplaceExplorePage() {
  return (
    <AppShell
      title="Marketplace"
      subtitle="Discover reusable agents, workflows and company systems."
    >
      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        {items.map((item) => (
          <div
            key={item}
            className="rounded-[30px] border border-slate-200 bg-white p-7 shadow-[0_20px_80px_rgba(15,23,42,.05)]"
          >
            <div className="mb-7 h-36 rounded-[24px] bg-gradient-to-br from-[#eef4ff] via-white to-[#f5f3ff]" />

            <h2 className="text-3xl font-black tracking-[-0.05em]">
              {item}
            </h2>

            <p className="mt-4 text-sm leading-7 text-slate-500">
              Ready-to-install automation system with configurable workflows and integrations.
            </p>

            <button className="mt-7 rounded-full bg-[#111827] px-5 py-3 text-sm font-bold text-white">
              View Asset
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX

cat > app/billing-center/page.tsx <<'TSX'
import AppShell from "@/components/layout/AppShell";
import StatCard from "@/components/ui/StatCard";

export default function BillingCenterPage() {
  return (
    <AppShell
      title="Billing"
      subtitle="Manage plans, credits and workspace billing."
    >
      <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
        <StatCard
          title="Current Plan"
          value="Builder"
          subtitle="Monthly subscription"
        />

        <StatCard
          title="Credits"
          value="124k"
          subtitle="Available platform credits"
        />

        <StatCard
          title="Usage"
          value="42%"
          subtitle="Current billing cycle"
        />
      </div>

      <div className="mt-7 rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
        <h2 className="text-4xl font-black tracking-[-0.05em]">
          Credit management
        </h2>

        <p className="mt-4 max-w-3xl text-slate-500 leading-8">
          Monitor platform usage, purchase additional credits and manage model access for workspace execution.
        </p>

        <div className="mt-8 flex flex-wrap gap-4">
          <button className="rounded-full bg-[#111827] px-7 py-4 text-sm font-bold text-white">
            Buy Credits
          </button>

          <button className="rounded-full border border-slate-200 bg-white px-7 py-4 text-sm font-bold text-slate-700">
            Change Plan
          </button>
        </div>
      </div>
    </AppShell>
  );
}
TSX

npm run build
git add app components
git commit -m "Replace entire app shell with premium UI system" || true
git push origin main
