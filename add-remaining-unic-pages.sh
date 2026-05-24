#!/bin/bash
set -e

echo "Adding remaining UNIC.ai pages..."

make_page () {
  ROUTE="$1"
  TITLE="$2"
  EYEBROW="$3"
  DESC="$4"

  mkdir -p "app/$ROUTE"

  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell, { Card, Metric } from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" eyebrow="$EYEBROW">
      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Metric label="Active" value="Live" />
        <Metric label="Synced" value="98%" />
        <Metric label="Queued" value="12" />
        <Metric label="Status" value="Ready" />
      </div>

      <section className="mt-3 grid gap-3 xl:grid-cols-[1.2fr_.8fr]">
        <Card className="min-h-[420px]">
          <p className="mb-3 text-[11.5px] font-medium text-blue-500">$EYEBROW</p>
          <h2 className="max-w-md text-[1.75rem] font-medium leading-[1.15] tracking-tight text-gray-900">$TITLE</h2>
          <p className="mt-3 max-w-sm text-[13px] text-gray-400">$DESC</p>

          <div className="mt-8 grid gap-2">
            {["Supabase connected", "Realtime ready", "Actions enabled", "Audit trail active"].map((item) => (
              <div key={item} className="flex items-center justify-between rounded-xl bg-white/50 px-4 py-3 text-[13px]">
                <span className="text-gray-700">{item}</span>
                <span className="text-blue-500">→</span>
              </div>
            ))}
          </div>
        </Card>

        <Card className="min-h-[420px]">
          <p className="mb-3 text-[11.5px] font-medium text-blue-500">Operational feed</p>
          <div className="space-y-2">
            {["Record synced", "Runtime updated", "Policy checked", "Worker completed"].map((item) => (
              <div key={item} className="rounded-xl bg-white/50 px-4 py-3">
                <p className="text-[13px] font-medium text-gray-800">{item}</p>
                <p className="text-[12px] text-gray-400">Just now</p>
              </div>
            ))}
          </div>
        </Card>
      </section>
    </AppShell>
  );
}
TSX
}

make_page team "Team" "Workspace members" "Manage members, roles, invites, permissions and company access."
make_page goals "Goals" "Company direction" "Define company goals and align AI agents, swarms and workflows around them."
make_page usage "Usage" "Runtime consumption" "Track credits, tokens, workflow runs, model usage and cost controls."
make_page budgets "Budgets" "Spend governance" "Set limits for agents, workflows, teams, tools and company runtime usage."
make_page companies "Companies" "Workspace control" "Manage company profiles, operating units, workspaces and ownership structure."
make_page schedules "Schedules" "Automation timing" "Create recurring agent tasks, workflow triggers and scheduled company operations."
make_page dataset-sell "Dataset Sell" "Knowledge marketplace" "Package approved datasets for marketplace listing, licensing and monetization."
make_page agent-evolution "Agent Evolution" "Self-improvement review" "Review AI-generated improvement suggestions, version changes and rollback options."
make_page worker-health "Worker Health" "Runtime infrastructure" "Monitor DigitalOcean workers, queues, heartbeats, memory and execution stability."
make_page security "Security" "Company protection" "Manage sessions, access policies, verification, provider locks and sensitive actions."
make_page secret-manager "Secret Manager" "Encrypted keys" "Store model keys, API keys, provider secrets and tool credentials safely."
make_page notifications "Notifications" "System alerts" "View workspace alerts, payment events, approval requests and runtime failures."

# update sidebar with remaining pages
cat > components/unic/AppShell.tsx.tmp <<'TSX'
"use client";

import Link from "next/link";
import Logo from "./Logo";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Swarms", "/swarms"],
  ["Tasks", "/tasks"],
  ["Goals", "/goals"],
  ["Datasets", "/datasets"],
  ["Brain", "/brain"],
  ["Connect", "/connection-layer"],
  ["Market", "/marketplace"],
  ["Billing", "/billing"],
  ["Usage", "/usage"],
  ["Budgets", "/budgets"],
  ["Team", "/team"],
  ["Schedules", "/schedules"],
  ["Approvals", "/approvals"],
  ["Activity", "/activity"],
  ["Security", "/security"],
  ["Settings", "/settings"]
];

export default function AppShell({
  title,
  eyebrow,
  children
}: {
  title: string;
  eyebrow: string;
  children: React.ReactNode;
}) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-[#f0f0ee] text-gray-900">
      <video
        className="video-soft fixed inset-0 h-full w-full object-cover opacity-70"
        src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4"
        autoPlay
        muted
        loop
        playsInline
      />
      <div className="fixed inset-0 bg-[#f0f0ee]/40" />

      <div className="relative z-10 flex min-h-screen">
        <aside className="hidden w-[260px] shrink-0 border-r border-white/40 bg-[#ededed]/70 p-4 backdrop-blur-2xl lg:block">
          <Link href="/" className="mb-8 flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[#EDEDED]">
              <Logo />
            </div>
            <div>
              <p className="text-lg font-semibold tracking-tight">UNIC.ai</p>
              <p className="text-[11px] text-gray-500">Operating system</p>
            </div>
          </Link>

          <nav className="max-h-[calc(100vh-120px)] space-y-1 overflow-y-auto pr-1">
            {nav.map(([label, href]) => (
              <Link
                key={href}
                href={href}
                className="block rounded-xl px-4 py-3 text-[13px] font-medium text-gray-600 transition hover:bg-white/60 hover:text-gray-950"
              >
                {label}
              </Link>
            ))}
          </nav>
        </aside>

        <section className="flex-1">
          <header className="flex items-center justify-between px-5 py-4 sm:px-8">
            <div className="rounded-xl bg-[#EDEDED]/80 px-5 py-3 backdrop-blur-xl">
              <p className="text-[11px] font-medium text-blue-500">{eyebrow}</p>
              <h1 className="text-[1.55rem] font-medium leading-[1.1] tracking-tight text-gray-900">
                {title}
              </h1>
            </div>

            <div className="flex items-center gap-2">
              <Link
                href="/billing"
                className="rounded-xl bg-[#EDEDED]/80 px-4 py-3 text-[13px] font-medium text-gray-700 backdrop-blur-xl"
              >
                Credits
              </Link>
              <Link
                href="/notifications"
                className="rounded-xl bg-[#EDEDED]/80 px-4 py-3 text-[13px] font-medium text-gray-700 backdrop-blur-xl"
              >
                Alerts
              </Link>
              <Link
                href="/settings"
                className="rounded-xl bg-[#EDEDED]/80 px-4 py-3 text-[13px] font-medium text-gray-700 backdrop-blur-xl"
              >
                Settings
              </Link>
            </div>
          </header>

          <div className="px-5 pb-10 sm:px-8">{children}</div>
        </section>
      </div>
    </main>
  );
}

export function Card({
  children,
  className = ""
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={`os-panel rounded-2xl p-5 ${className}`}>{children}</div>;
}

export function Metric({ label, value }: { label: string; value: string }) {
  return (
    <Card>
      <p className="text-[11.5px] font-medium text-gray-400">{label}</p>
      <p className="mt-2 text-[1.75rem] font-medium leading-none tracking-tight text-gray-900">{value}</p>
    </Card>
  );
}
TSX

mv components/unic/AppShell.tsx.tmp components/unic/AppShell.tsx

npm run build
git add .
git commit -m "Add remaining UNIC app pages"
git push origin main

echo "DONE. Redeploy Vercel."
