#!/bin/bash
set -e

echo "Installing real Next.js UNIC.ai build. No iframe. No static Stitch preview."

rm -rf public/stitch

mkdir -p components/unic lib app/{login,signup,onboarding,dashboard,workflow-studio,agents,swarms,tasks,datasets,brain,connection-layer,marketplace,billing,approvals,activity,settings,pricing,legal/privacy,legal/refund,legal/ai-policy,legal/terms}

cat > lib/supabase-browser.ts <<'TS'
"use client";

import { createBrowserClient } from "@supabase/ssr";

export function supabaseBrowser() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ""
  );
}
TS

cat > components/unic/UNICShell.tsx <<'TSX'
"use client";

import Link from "next/link";
import { ReactNode, useState } from "react";

const nav = [
  ["Dashboard", "/dashboard", "grid_view"],
  ["Workflow Studio", "/workflow-studio", "hub"],
  ["Agents", "/agents", "smart_toy"],
  ["Swarms", "/swarms", "group_work"],
  ["Tasks", "/tasks", "view_kanban"],
  ["Datasets", "/datasets", "database"],
  ["Company Brain", "/brain", "memory"],
  ["Connection Layer", "/connection-layer", "lan"],
  ["Marketplace", "/marketplace", "storefront"],
  ["Billing", "/billing", "account_balance_wallet"],
  ["Approvals", "/approvals", "verified_user"],
  ["Activity", "/activity", "monitoring"],
  ["Settings", "/settings", "settings"]
];

export function Icon({ name }: { name: string }) {
  return <span className="material-symbols-outlined text-[20px]">{name}</span>;
}

export function AppShell({
  title,
  eyebrow,
  children,
  right
}: {
  title: string;
  eyebrow?: string;
  children: ReactNode;
  right?: ReactNode;
}) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <main className="min-h-screen bg-[#031427] text-[#d3e4fe] selection:bg-[#2fd9f4]/30">
      <aside className={`${collapsed ? "w-[82px]" : "w-64"} fixed left-0 top-0 z-40 hidden h-screen border-r border-[#45474b]/40 bg-[#000f21] transition-all lg:flex lg:flex-col`}>
        <div className="flex h-16 items-center gap-3 border-b border-[#45474b]/30 px-5">
          <div className="grid h-8 w-8 place-items-center rounded bg-[#2fd9f4] text-sm font-black text-[#00363e]">U</div>
          {!collapsed && (
            <div>
              <p className="text-lg font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-[#c6c6cb]/60">Enterprise OS</p>
            </div>
          )}
        </div>

        <nav className="flex-1 space-y-1 overflow-y-auto p-3">
          {nav.map(([label, href, icon]) => (
            <Link key={href} href={href} className="flex items-center gap-3 rounded px-3 py-2.5 font-mono text-xs uppercase tracking-[0.08em] text-[#c6c6cb] transition hover:bg-[#26364a]/50 hover:text-[#2fd9f4]">
              <Icon name={icon} />
              {!collapsed && <span>{label}</span>}
            </Link>
          ))}
        </nav>

        <div className="border-t border-[#45474b]/30 p-3">
          <button onClick={() => setCollapsed(!collapsed)} className="flex w-full items-center justify-center gap-2 rounded border border-[#45474b]/40 px-3 py-2 font-mono text-xs text-[#c6c6cb] hover:text-[#2fd9f4]">
            <Icon name="dock_to_right" />
            {!collapsed && "Collapse"}
          </button>
        </div>
      </aside>

      <section className={`${collapsed ? "lg:ml-[82px]" : "lg:ml-64"} transition-all`}>
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[#45474b]/30 bg-[#031427]/85 px-6 backdrop-blur-xl">
          <div>
            {eyebrow && <p className="font-mono text-[10px] uppercase tracking-[0.22em] text-[#2fd9f4]">{eyebrow}</p>}
            <h1 className="text-xl font-black tracking-[-0.04em]">{title}</h1>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden items-center gap-2 rounded border border-[#45474b]/40 bg-[#0b1c30] px-3 py-2 md:flex">
              <Icon name="search" />
              <span className="font-mono text-xs text-[#c6c6cb]/70">Command / Search</span>
            </div>
            <Link href="/billing" className="rounded border border-[#2fd9f4]/30 bg-[#000e12] px-3 py-2 font-mono text-xs font-bold text-[#2fd9f4]">14.2k credits</Link>
            <Link href="/settings" className="rounded border border-[#45474b]/40 p-2 text-[#c6c6cb] hover:text-[#2fd9f4]"><Icon name="settings" /></Link>
          </div>
        </header>

        <div className={right ? "grid gap-0 xl:grid-cols-[1fr_340px]" : ""}>
          <div className="p-6">{children}</div>
          {right && <aside className="hidden min-h-[calc(100vh-64px)] border-l border-[#45474b]/30 bg-[#000f21] p-5 xl:block">{right}</aside>}
        </div>
      </section>
    </main>
  );
}

export function Panel({ children, className = "" }: { children: ReactNode; className?: string }) {
  return <div className={`rounded border border-[#45474b]/40 bg-[#0b1c30]/80 p-5 backdrop-blur-xl ${className}`}>{children}</div>;
}

export function Stat({ label, value, tone = "cyan" }: { label: string; value: string; tone?: "cyan" | "violet" | "emerald" }) {
  const color = tone === "violet" ? "text-[#c0c1ff]" : tone === "emerald" ? "text-emerald-400" : "text-[#2fd9f4]";
  return (
    <Panel>
      <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-[#c6c6cb]/60">{label}</p>
      <p className={`mt-3 text-4xl font-black tracking-[-0.06em] ${color}`}>{value}</p>
    </Panel>
  );
}
TSX

cat > app/layout.tsx <<'TSX'
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "UNIC.ai",
  description: "Operating System for AI Companies"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body>{children}</body>
    </html>
  );
}
TSX

cat > app/globals.css <<'CSS'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=Geist+Mono:wght@400;500;600;700&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --background: #031427;
  --foreground: #d3e4fe;
}

* { box-sizing: border-box; }

html, body {
  margin: 0;
  background: var(--background);
  color: var(--foreground);
  font-family: Inter, system-ui, sans-serif;
}

.font-mono {
  font-family: "Geist Mono", ui-monospace, monospace;
}

.material-symbols-outlined {
  font-family: 'Material Symbols Outlined';
  font-weight: normal;
  font-style: normal;
  line-height: 1;
  text-transform: none;
  letter-spacing: normal;
  white-space: nowrap;
  direction: ltr;
  -webkit-font-feature-settings: 'liga';
  -webkit-font-smoothing: antialiased;
}
CSS

cat > app/page.tsx <<'TSX'
import Link from "next/link";

export default function HomePage() {
  return (
    <main className="min-h-screen overflow-hidden bg-[#031427] text-[#d3e4fe]">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-6">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-10 w-10 place-items-center rounded bg-[#2fd9f4] font-black text-[#00363e]">U</div>
          <div>
            <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[#c6c6cb]/60">Enterprise OS</p>
          </div>
        </Link>
        <div className="flex items-center gap-3">
          <Link href="/pricing" className="hidden font-mono text-xs uppercase tracking-[0.12em] text-[#c6c6cb] md:block">Pricing</Link>
          <Link href="/login" className="rounded border border-[#2fd9f4]/50 px-5 py-2.5 font-mono text-xs font-bold uppercase tracking-[0.12em] text-[#2fd9f4]">Login</Link>
          <Link href="/signup" className="rounded bg-[#2fd9f4] px-5 py-2.5 font-mono text-xs font-black uppercase tracking-[0.12em] text-[#00363e]">Get Started</Link>
        </div>
      </nav>

      <section className="relative mx-auto grid min-h-[calc(100vh-88px)] max-w-7xl items-center gap-12 px-6 py-16 lg:grid-cols-[1fr_0.95fr]">
        <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_75%_45%,rgba(47,217,244,.24),transparent_34%),radial-gradient(circle_at_50%_80%,rgba(192,193,255,.18),transparent_30%)]" />
        <div>
          <p className="font-mono text-xs font-bold uppercase tracking-[0.24em] text-[#2fd9f4]">Operating System for AI Companies</p>
          <h1 className="mt-6 max-w-5xl text-[clamp(56px,9vw,118px)] font-black leading-[0.88] tracking-[-0.08em]">
            Automate your company with AI runtime.
          </h1>
          <p className="mt-8 max-w-2xl text-lg leading-8 text-[#c6c6cb]">
            Build agents, swarms, workflows, memory, approvals, connected tools, billing and live execution from one enterprise AI operating system.
          </p>
          <div className="mt-10 flex flex-wrap gap-4">
            <Link href="/signup" className="rounded bg-[#2fd9f4] px-7 py-4 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Start Building</Link>
            <Link href="/login" className="rounded border border-[#2fd9f4]/40 px-7 py-4 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#2fd9f4]">Login</Link>
            <Link href="/dashboard" className="rounded border border-[#45474b]/50 px-7 py-4 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#d3e4fe]">View Demo</Link>
          </div>
        </div>

        <div className="rounded border border-[#45474b]/50 bg-[#0b1c30]/70 p-5 shadow-2xl shadow-black/40 backdrop-blur-xl">
          <div className="flex items-center justify-between border-b border-[#45474b]/40 pb-4">
            <div>
              <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[#2fd9f4]">Runtime Graph</p>
              <h2 className="mt-1 text-2xl font-black tracking-[-0.04em]">Workflow Kernel</h2>
            </div>
            <div className="rounded bg-emerald-400/10 px-3 py-1 font-mono text-[10px] font-bold text-emerald-400">LIVE</div>
          </div>
          <div className="relative mt-5 h-[460px] overflow-hidden rounded bg-[#000f21]">
            <div className="absolute inset-0 bg-[radial-gradient(rgba(144,144,149,.16)_1px,transparent_1px)] bg-[size:24px_24px]" />
            {[
              ["Webhook", "left-8 top-10", "webhook"],
              ["AI Agent", "left-[220px] top-[190px]", "psychology"],
              ["Company Brain", "right-8 top-16", "memory"],
              ["Human Approval", "right-8 bottom-12", "verified_user"]
            ].map(([label, pos, icon]) => (
              <div key={label} className={`absolute ${pos} w-48 rounded border border-[#45474b]/50 bg-[#102034]/90 p-4 shadow-xl`}>
                <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-[#2fd9f4]">{icon}</p>
                <p className="mt-2 font-black">{label}</p>
                <p className="mt-1 font-mono text-[10px] text-[#c6c6cb]/60">status: active</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/login/page.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function login() {
    setMsg("Authenticating...");
    const { error } = await supabaseBrowser().auth.signInWithPassword({ email, password });
    if (error) return setMsg(error.message);
    window.location.href = "/dashboard";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#031427] p-6 text-[#d3e4fe]">
      <div className="w-full max-w-md rounded border border-[#45474b]/50 bg-[#0b1c30] p-8">
        <p className="font-mono text-xs uppercase tracking-[0.22em] text-[#2fd9f4]">Secure Authentication</p>
        <h1 className="mt-4 text-5xl font-black tracking-[-0.06em]">Initialize Session</h1>
        <div className="mt-8 space-y-4">
          <input className="w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
          <button onClick={login} className="w-full rounded bg-[#2fd9f4] px-4 py-3 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Login</button>
        </div>
        {msg && <p className="mt-4 font-mono text-xs text-[#c6c6cb]">{msg}</p>}
        <p className="mt-6 text-sm text-[#c6c6cb]">No account? <Link href="/signup" className="text-[#2fd9f4]">Create workspace</Link></p>
      </div>
    </main>
  );
}
TSX

cat > app/signup/page.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function SignupPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function signup() {
    setMsg("Creating account...");
    const { error } = await supabaseBrowser().auth.signUp({ email, password });
    if (error) return setMsg(error.message);
    window.location.href = "/onboarding";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#031427] p-6 text-[#d3e4fe]">
      <div className="w-full max-w-md rounded border border-[#45474b]/50 bg-[#0b1c30] p-8">
        <p className="font-mono text-xs uppercase tracking-[0.22em] text-[#2fd9f4]">Join the Workforce</p>
        <h1 className="mt-4 text-5xl font-black tracking-[-0.06em]">Create Workspace</h1>
        <div className="mt-8 space-y-4">
          <input className="w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
          <button onClick={signup} className="w-full rounded bg-[#2fd9f4] px-4 py-3 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Create Account</button>
        </div>
        {msg && <p className="mt-4 font-mono text-xs text-[#c6c6cb]">{msg}</p>}
        <p className="mt-6 text-sm text-[#c6c6cb]">Already have account? <Link href="/login" className="text-[#2fd9f4]">Login</Link></p>
      </div>
    </main>
  );
}
TSX

cat > app/onboarding/page.tsx <<'TSX'
"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function OnboardingPage() {
  const [company, setCompany] = useState("");
  const [msg, setMsg] = useState("");

  async function createWorkspace() {
    const supabase = supabaseBrowser();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return (window.location.href = "/login");

    setMsg("Creating workspace...");
    await fetch("/api/onboarding-create-company", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ user_id: user.id, company_name: company })
    });
    window.location.href = "/dashboard";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#031427] p-6 text-[#d3e4fe]">
      <div className="w-full max-w-lg rounded border border-[#45474b]/50 bg-[#0b1c30] p-8">
        <p className="font-mono text-xs uppercase tracking-[0.22em] text-[#2fd9f4]">Workspace Provisioning</p>
        <h1 className="mt-4 text-5xl font-black tracking-[-0.06em]">Create Company OS</h1>
        <input className="mt-8 w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Company name" value={company} onChange={(e) => setCompany(e.target.value)} />
        <button onClick={createWorkspace} className="mt-4 w-full rounded bg-[#2fd9f4] px-4 py-3 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Provision Workspace</button>
        {msg && <p className="mt-4 font-mono text-xs text-[#c6c6cb]">{msg}</p>}
      </div>
    </main>
  );
}
TSX

cat > app/dashboard/page.tsx <<'TSX'
import { AppShell, Panel, Stat } from "@/components/unic/UNICShell";

export default function DashboardPage() {
  return (
    <AppShell title="Mission Control" eyebrow="Operational OS">
      <div className="grid gap-5 md:grid-cols-4">
        <Stat label="Active Agents" value="18" />
        <Stat label="Running Workflows" value="42" tone="violet" />
        <Stat label="Approvals" value="07" tone="emerald" />
        <Stat label="Runtime Health" value="99.9%" />
      </div>
      <div className="mt-5 grid gap-5 xl:grid-cols-[1.3fr_.7fr]">
        <Panel className="min-h-[520px]">
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#2fd9f4]">Live Runtime Feed</p>
          <div className="mt-5 space-y-3 font-mono text-sm">
            {["Agent Sentinel completed data audit", "Workflow Support_OS moved to review", "Gmail connector synchronized", "Dataset embedding queued", "Approval requested for outbound email"].map((x, i) => (
              <div key={x} className="flex gap-4 border-b border-[#45474b]/20 py-3">
                <span className="text-[#909095]">14:{22 + i}:0{i}</span>
                <span className="text-[#2fd9f4]">[INFO]</span>
                <span className="text-[#c6c6cb]">{x}</span>
              </div>
            ))}
          </div>
        </Panel>
        <Panel>
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#c0c1ff]">Connected Entities</p>
          <div className="mt-5 space-y-3">
            {["GPT Orchestrator", "Pinecone Vector DB", "Gmail Runtime", "Slack Runtime"].map((x) => (
              <div key={x} className="flex items-center justify-between rounded border border-[#45474b]/30 bg-[#000f21] p-3">
                <span className="font-bold">{x}</span>
                <span className="font-mono text-[10px] text-emerald-400">ACTIVE</span>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </AppShell>
  );
}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import { AppShell, Icon, Panel } from "@/components/unic/UNICShell";

export default function WorkflowStudioPage() {
  const nodes = [
    ["Webhook In", "left-12 top-16", "webhook"],
    ["LLM Agent", "left-[380px] top-[250px]", "psychology"],
    ["Company Brain", "left-[710px] top-24", "memory"],
    ["Human Approval", "left-[760px] top-[430px]", "verified_user"]
  ];

  return (
    <AppShell title="Workflow Studio" eyebrow="AI Orchestration" right={<Panel><p className="font-mono text-xs uppercase tracking-[0.2em] text-[#2fd9f4]">Inspector</p><h2 className="mt-4 text-2xl font-black">Node Configuration</h2><textarea className="mt-5 h-40 w-full rounded border border-[#45474b] bg-[#000f21] p-3 text-sm text-[#d3e4fe]" defaultValue="Analyze the incoming request and route to the correct AI worker." /></Panel>}>
      <div className="grid h-[calc(100vh-112px)] grid-cols-[250px_1fr] overflow-hidden rounded border border-[#45474b]/40">
        <aside className="border-r border-[#45474b]/40 bg-[#000f21] p-4">
          <button className="mb-5 flex w-full items-center justify-center gap-2 rounded bg-[#2fd9f4] py-3 font-mono text-xs font-black uppercase text-[#00363e]"><Icon name="add" /> New Runtime</button>
          {["Triggers", "AI Models", "Logic & Tools", "Integrations"].map((group) => (
            <div key={group} className="mb-6">
              <p className="mb-2 font-mono text-[10px] uppercase tracking-[0.18em] text-[#c6c6cb]/50">{group}</p>
              {["Webhook", "LLM Inference", "Vector Store", "Slack Outbound"].map((x) => (
                <div key={x} className="rounded px-3 py-2 font-mono text-xs text-[#c6c6cb] hover:bg-[#26364a]/40 hover:text-[#2fd9f4]">{x}</div>
              ))}
            </div>
          ))}
        </aside>
        <section className="relative overflow-hidden bg-[#031427]">
          <div className="absolute inset-0 bg-[radial-gradient(rgba(144,144,149,.16)_1px,transparent_1px)] bg-[size:24px_24px]" />
          {nodes.map(([label, pos, icon]) => (
            <div key={label} className={`absolute ${pos} w-60 rounded border border-[#45474b]/50 bg-[#102034]/95 p-4 shadow-2xl`}>
              <div className="flex items-center gap-3">
                <Icon name={icon} />
                <b>{label}</b>
              </div>
              <p className="mt-3 font-mono text-[11px] text-[#c6c6cb]/70">status: ready</p>
            </div>
          ))}
        </section>
      </div>
    </AppShell>
  );
}
TSX

create_basic_page () {
  ROUTE="$1"
  TITLE="$2"
  EYEBROW="$3"
  mkdir -p "app/$ROUTE"
  cat > "app/$ROUTE/page.tsx" <<TSX
import { AppShell, Panel, Stat } from "@/components/unic/UNICShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" eyebrow="$EYEBROW">
      <div className="grid gap-5 md:grid-cols-3">
        <Stat label="Active" value="12" />
        <Stat label="Queued" value="34" tone="violet" />
        <Stat label="Health" value="99%" tone="emerald" />
      </div>
      <div className="mt-5 grid gap-5 lg:grid-cols-[1fr_.8fr]">
        <Panel className="min-h-[420px]">
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#2fd9f4]">Operational Surface</p>
          <h2 className="mt-4 text-4xl font-black tracking-[-0.05em]">$TITLE</h2>
          <p className="mt-4 max-w-2xl text-[#c6c6cb]">This module is wired into the UNIC.ai operating workspace and ready for Supabase-backed records, runtime states, and production actions.</p>
          <div className="mt-8 space-y-3">
            {["Runtime connected", "Supabase ready", "Actions enabled", "Audit trail active"].map((x) => (
              <div key={x} className="flex justify-between border-b border-[#45474b]/20 py-3 font-mono text-sm">
                <span>{x}</span>
                <span className="text-[#2fd9f4]">ONLINE</span>
              </div>
            ))}
          </div>
        </Panel>
        <Panel>
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#c0c1ff]">Actions</p>
          <div className="mt-5 grid gap-3">
            {["Create", "Sync", "Review", "Export"].map((x) => (
              <button key={x} className="rounded border border-[#45474b]/40 bg-[#000f21] px-4 py-3 text-left font-mono text-xs uppercase tracking-[0.12em] hover:border-[#2fd9f4]/60 hover:text-[#2fd9f4]">{x}</button>
            ))}
          </div>
        </Panel>
      </div>
    </AppShell>
  );
}
TSX
}

create_basic_page agents "AI Workforce" "Agents"
create_basic_page swarms "Swarm Orchestration" "Multi-Agent Runtime"
create_basic_page tasks "Mission Control Tasks" "Operational Queue"
create_basic_page datasets "Knowledge Ingestion OS" "Datasets"
create_basic_page brain "Memory Infrastructure" "Company Brain"
create_basic_page connection-layer "Runtime Hub" "Integrations"
create_basic_page marketplace "Asset Marketplace" "Marketplace"
create_basic_page billing "Billing & Infrastructure" "Credits"
create_basic_page approvals "Approval Control" "Human Review"
create_basic_page activity "Kernel Auditor" "Operational Audit Feed"
create_basic_page settings "Workspace Configuration" "Settings"

cat > app/pricing/page.tsx <<'TSX'
import Link from "next/link";

export default function PricingPage() {
  return (
    <main className="min-h-screen bg-[#031427] p-8 text-[#d3e4fe]">
      <Link href="/" className="font-mono text-xs uppercase tracking-[0.18em] text-[#2fd9f4]">UNIC.ai</Link>
      <h1 className="mt-12 text-7xl font-black tracking-[-0.07em]">Pricing & Plans</h1>
      <div className="mt-10 grid gap-5 md:grid-cols-4">
        {["Starter", "Builder", "Company", "Enterprise"].map((x) => (
          <div key={x} className="rounded border border-[#45474b]/50 bg-[#0b1c30] p-6">
            <h2 className="text-3xl font-black">{x}</h2>
            <p className="mt-4 text-[#c6c6cb]">Credits, workflows, runtime and connected AI operations.</p>
            <button className="mt-8 rounded bg-[#2fd9f4] px-5 py-3 font-mono text-xs font-black uppercase text-[#00363e]">Start</button>
          </div>
        ))}
      </div>
    </main>
  );
}
TSX

for page in privacy refund ai-policy terms; do
  cat > "app/legal/$page/page.tsx" <<TSX
export default function Page() {
  return (
    <main className="min-h-screen bg-[#031427] p-8 text-[#d3e4fe]">
      <h1 className="text-6xl font-black tracking-[-0.06em]">UNIC.ai ${page}</h1>
      <p className="mt-6 max-w-3xl text-[#c6c6cb]">Legal and policy information for the UNIC.ai operating system.</p>
    </main>
  );
}
TSX
done

npm run build
git add .
git commit -m "Install real Next.js dark OS video-ready build"
git push origin main

echo "DONE. Redeploy Vercel."
