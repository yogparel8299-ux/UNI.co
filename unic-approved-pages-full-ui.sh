#!/bin/bash
set -e

echo "Building approved UNIC.ai pages only..."

mkdir -p components/unic lib
mkdir -p app/{team,goals,tasks,usage,agents,skills,swarms,billing,budgets,builder,workflow-studio,pricing,activity,datasets,dataset-sell,settings,approvals,companies,schedules,marketplace,connection-layer,brain,realtime-dashboard,live-runtime,agent-evolution,login,signup,legal/terms,legal/refund,legal/privacy,legal/ai-policy}

cat > lib/protected-routes.ts <<'TS'
export const PROTECTED_ROUTES = [
  "/team",
  "/goals",
  "/tasks",
  "/usage",
  "/agents",
  "/skills",
  "/swarms",
  "/billing",
  "/budgets",
  "/builder",
  "/workflow-studio",
  "/activity",
  "/datasets",
  "/dataset-sell",
  "/settings",
  "/approvals",
  "/companies",
  "/schedules",
  "/marketplace",
  "/connection-layer",
  "/brain",
  "/realtime-dashboard",
  "/live-runtime",
  "/agent-evolution"
];
TS

cat > middleware.ts <<'TS'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { PROTECTED_ROUTES } from "./lib/protected-routes";

function isProtected(pathname: string) {
  return PROTECTED_ROUTES.some((route) => pathname.startsWith(route));
}

export function middleware(req: NextRequest) {
  const pathname = req.nextUrl.pathname;

  if (
    pathname.startsWith("/api") ||
    pathname.startsWith("/_next") ||
    pathname.includes(".")
  ) {
    return NextResponse.next();
  }

  if (!isProtected(pathname)) return NextResponse.next();

  const hasAuthCookie =
    req.cookies.get("sb-access-token") ||
    req.cookies.get("sb-refresh-token") ||
    Array.from(req.cookies.getAll()).some((c) => c.name.startsWith("sb-"));

  if (!hasAuthCookie) {
    return NextResponse.redirect(new URL("/login", req.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"]
};
TS

cat > components/unic/AppShell.tsx <<'TSX'
import Link from "next/link";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Companies", "/companies"],
  ["Team", "/team"],
  ["Goals", "/goals"],
  ["Agents", "/agents"],
  ["Skills", "/skills"],
  ["Swarms", "/swarms"],
  ["Builder", "/workflow-studio"],
  ["Tasks", "/tasks"],
  ["Schedules", "/schedules"],
  ["Datasets", "/datasets"],
  ["Brain", "/brain"],
  ["Approvals", "/approvals"],
  ["Realtime", "/realtime-dashboard"],
  ["Marketplace", "/marketplace"],
  ["Billing", "/billing"],
  ["Budgets", "/budgets"],
  ["Usage", "/usage"],
  ["Activity", "/activity"],
  ["Settings", "/settings"]
];

export default function AppShell({
  title,
  subtitle,
  children,
  right
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  right?: React.ReactNode;
}) {
  return (
    <main className="min-h-screen bg-[#f7f7f8] text-black">
      <aside className="fixed left-0 top-0 hidden h-screen w-[270px] border-r border-neutral-200 bg-white lg:block">
        <div className="border-b border-neutral-200 p-5">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-10 w-10 place-items-center rounded-xl bg-black text-white font-black">U</div>
            <div>
              <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-neutral-500">AI company OS</p>
            </div>
          </Link>
        </div>

        <div className="h-[calc(100vh-82px)] overflow-y-auto p-3">
          {nav.map(([label, href]) => (
            <Link
              key={href}
              href={href}
              className="mb-1 block rounded-xl px-3 py-2.5 text-sm font-bold text-neutral-600 hover:bg-neutral-100 hover:text-black"
            >
              {label}
            </Link>
          ))}
        </div>
      </aside>

      <section className={right ? "lg:ml-[270px] lg:mr-[330px]" : "lg:ml-[270px]"}>
        <header className="sticky top-0 z-20 border-b border-neutral-200 bg-white/90 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-4">
            <div>
              <h1 className="text-2xl font-black tracking-[-0.04em]">{title}</h1>
              {subtitle && <p className="mt-1 text-sm text-neutral-500">{subtitle}</p>}
            </div>

            <div className="flex gap-2">
              <Link href="/workflow-studio" className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">
                Builder
              </Link>
              <Link href="/settings" className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">
                Settings
              </Link>
            </div>
          </div>
        </header>

        <div className="p-6">{children}</div>
      </section>

      {right && (
        <aside className="fixed right-0 top-0 hidden h-screen w-[330px] border-l border-neutral-200 bg-white lg:block">
          {right}
        </aside>
      )}
    </main>
  );
}
TSX

cat > components/unic/PublicShell.tsx <<'TSX'
import Link from "next/link";

export default function PublicShell({ children }: { children: React.ReactNode }) {
  return (
    <main className="min-h-screen bg-[#f7f7f8] text-black">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-xl bg-black text-white font-black">U</div>
          <div>
            <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
            <p className="text-xs text-neutral-500">AI company operating system</p>
          </div>
        </Link>

        <div className="hidden rounded-full border border-neutral-200 bg-white px-6 py-3 text-sm font-bold text-neutral-600 shadow-sm md:flex gap-8">
          <Link href="/dashboard">Demo</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/legal/privacy">Privacy</Link>
          <Link href="/legal/ai-policy">AI Policy</Link>
        </div>

        <Link href="/signup" className="rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">
          Get Started
        </Link>
      </nav>

      {children}
    </main>
  );
}
TSX

cat > app/page.tsx <<'TSX'
import Link from "next/link";
import PublicShell from "@/components/unic/PublicShell";

export default function HomePage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-16">
        <div className="grid gap-12 lg:grid-cols-[1fr_.95fr]">
          <div className="pt-10">
            <div className="mb-8 flex flex-wrap gap-3">
              {["AI workforce", "Connected tools", "Human approvals"].map((x) => (
                <span key={x} className="rounded-full border border-neutral-200 bg-white px-4 py-2 text-xs font-black text-neutral-600">
                  {x}
                </span>
              ))}
            </div>

            <h1 className="text-[clamp(56px,8vw,110px)] font-black leading-[.9] tracking-[-0.08em]">
              Build your<br />AI company
            </h1>

            <p className="mt-8 max-w-2xl text-lg leading-8 text-neutral-500">
              Create agents, skills, workflows, approvals, memory and connected operations from one operational workspace.
            </p>

            <div className="mt-10 flex gap-4">
              <Link href="/signup" className="rounded-xl bg-black px-6 py-4 text-sm font-bold text-white">Start Building</Link>
              <Link href="/dashboard" className="rounded-xl border border-neutral-200 bg-white px-6 py-4 text-sm font-bold">View Demo</Link>
            </div>
          </div>

          <div className="rounded-[32px] border border-neutral-200 bg-white p-6 shadow-[0_24px_90px_rgba(15,23,42,.07)]">
            <div className="rounded-[24px] border border-neutral-200 bg-gradient-to-br from-white to-blue-50 p-6">
              <p className="text-xs font-black uppercase tracking-[.18em] text-blue-600">Workspace</p>
              <h2 className="mt-2 text-4xl font-black tracking-[-.05em]">Command Center</h2>

              <div className="mt-8 space-y-4">
                {["Create AI agents", "Build workflow canvas", "Connect Gmail and Slack", "Review approvals", "Track live execution"].map((x) => (
                  <div key={x} className="rounded-2xl border border-neutral-200 bg-white p-5 font-bold">
                    {x}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>
    </PublicShell>
  );
}
TSX

cat > app/dashboard/page.tsx <<'TSX'
import Link from "next/link";
import PublicShell from "@/components/unic/PublicShell";

export default function DashboardPage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-10">
        <div className="rounded-[36px] bg-white p-10 shadow-[0_20px_80px_rgba(15,23,42,.06)]">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-neutral-500">Product Preview</p>
          <h1 className="mt-5 text-6xl font-black tracking-[-0.07em]">AI company command center</h1>
          <p className="mt-6 max-w-3xl text-neutral-500 leading-8">
            Visitors can preview the workspace. Login is required for agents, workflows, datasets, approvals, marketplace, billing and runtime tools.
          </p>
        </div>

        <div className="mt-8 grid gap-4 md:grid-cols-4">
          {[
            ["Agents", "18"],
            ["Workflows", "42"],
            ["Executions", "12.4k"],
            ["Workers", "Online"]
          ].map(([label, value]) => (
            <div key={label} className="rounded-2xl border border-neutral-200 bg-white p-5">
              <p className="text-sm font-bold text-neutral-500">{label}</p>
              <p className="mt-3 text-4xl font-black tracking-[-0.05em]">{value}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 grid gap-5 lg:grid-cols-[1.4fr_.6fr]">
          <div className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">Live execution preview</h2>
            <div className="mt-5 space-y-3">
              {["Research workflow completed", "Supplier outreach drafted", "Dataset indexed", "Approval requested"].map((x) => (
                <div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4">
                  <span className="font-bold">{x}</span>
                  <span className="text-sm text-neutral-500">demo</span>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">Access workspace</h2>
            <div className="mt-5 grid gap-3">
              {["Agents", "Workflow Studio", "Datasets", "Approvals"].map((x) => (
                <Link key={x} href="/login" className="rounded-xl bg-neutral-100 p-4 text-left text-sm font-black">
                  {x}
                </Link>
              ))}
            </div>
          </div>
        </div>
      </section>
    </PublicShell>
  );
}
TSX

cat > app/login/page.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";
import { createBrowserClient } from "@supabase/ssr";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(true);
  const [msg, setMsg] = useState("");

  async function login() {
    setMsg("Logging in...");

    const supabase = createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL || "",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ""
    );

    if (remember) localStorage.setItem("unic_remember_me", "true");
    else localStorage.removeItem("unic_remember_me");

    const { error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      setMsg(error.message);
      return;
    }

    window.location.href = "/agents";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6 text-black">
      <div className="w-full max-w-md rounded-[32px] border border-neutral-200 bg-white p-8 shadow-[0_24px_90px_rgba(15,23,42,.07)]">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Login</h1>
        <p className="mt-3 text-neutral-500">Access your AI company workspace.</p>

        <div className="mt-8 space-y-4">
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

          <label className="flex items-center gap-3 text-sm font-semibold text-neutral-600">
            <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
            Remember me on this device
          </label>

          <button onClick={login} className="w-full rounded-xl bg-black px-4 py-3 font-black text-white">Login</button>
        </div>

        {msg && <p className="mt-4 text-sm text-neutral-500">{msg}</p>}

        <p className="mt-6 text-sm text-neutral-500">
          No account? <Link href="/signup" className="font-black text-black">Create workspace</Link>
        </p>
      </div>
    </main>
  );
}
TSX

cat > app/signup/page.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";
import { createBrowserClient } from "@supabase/ssr";

export default function SignupPage() {
  const [companyName, setCompanyName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(true);
  const [msg, setMsg] = useState("");

  async function signup() {
    setMsg("Creating workspace...");

    const supabase = createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL || "",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ""
    );

    if (remember) localStorage.setItem("unic_remember_me", "true");

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { company_name: companyName } }
    });

    if (error) {
      setMsg(error.message);
      return;
    }

    if (data.user?.id) {
      await fetch("/api/verify-user-email", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user_id: data.user.id, email })
      }).catch(() => {});
    }

    window.location.href = "/onboarding";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6 text-black">
      <div className="w-full max-w-md rounded-[32px] border border-neutral-200 bg-white p-8 shadow-[0_24px_90px_rgba(15,23,42,.07)]">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Create workspace</h1>
        <p className="mt-3 text-neutral-500">Start your AI company operating system.</p>

        <div className="mt-8 space-y-4">
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Company name" value={companyName} onChange={(e) => setCompanyName(e.target.value)} />
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

          <label className="flex items-center gap-3 text-sm font-semibold text-neutral-600">
            <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
            Remember me on this device
          </label>

          <button onClick={signup} className="w-full rounded-xl bg-black px-4 py-3 font-black text-white">Create workspace</button>
        </div>

        {msg && <p className="mt-4 text-sm text-neutral-500">{msg}</p>}

        <p className="mt-6 text-sm text-neutral-500">
          Already have account? <Link href="/login" className="font-black text-black">Login</Link>
        </p>
      </div>
    </main>
  );
}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";

export default function WorkflowStudioPage() {
  return (
    <AppShell
      title="Workflow Studio"
      subtitle="Build workflows with triggers, agents, tools, memory and approvals."
      right={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[.16em] text-neutral-400">Properties</p>
          <h2 className="mt-3 text-xl font-black">Selected Node</h2>
          <div className="mt-5 space-y-4">
            <input className="w-full rounded-lg border px-3 py-2 text-sm" placeholder="Node name" />
            <select className="w-full rounded-lg border px-3 py-2 text-sm"><option>Agent Node</option><option>Tool Node</option><option>Approval Node</option></select>
            <textarea className="min-h-[130px] w-full rounded-lg border px-3 py-2 text-sm" placeholder="Node instructions" />
            <button className="w-full rounded-lg bg-black px-4 py-3 text-sm font-bold text-white">Save Node</button>
          </div>
        </div>
      }
    >
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap gap-2">
          {["Trigger", "Agent", "Skill", "Tool", "Memory", "Approval", "Condition"].map((x) => (
            <button key={x} className="rounded-lg border bg-white px-3 py-2 text-sm font-bold">+ {x}</button>
          ))}
        </div>
        <button className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">Run Workflow</button>
      </div>

      <div className="relative h-[720px] overflow-hidden rounded-2xl border border-neutral-200 bg-white">
        <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />
        <svg className="absolute inset-0 h-full w-full">
          <path d="M250 170 C330 170 310 235 365 235" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M570 235 C640 235 600 150 665 150" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M570 235 C640 235 600 385 665 385" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M875 385 C940 385 905 265 960 265" fill="none" stroke="#111" strokeWidth="2" />
        </svg>
        {[
          ["Trigger", "New lead received", "left-[70px] top-[120px]"],
          ["Agent", "Research Agent", "left-[365px] top-[190px]"],
          ["Memory", "Company Brain", "left-[665px] top-[95px]"],
          ["Approval", "Human Review", "left-[665px] top-[330px]"],
          ["Tool", "Gmail Draft", "left-[960px] top-[210px]"]
        ].map(([type,label,pos]) => (
          <div key={label} className={`absolute ${pos} w-[190px] rounded-xl border border-neutral-300 bg-white p-4 shadow-lg`}>
            <p className="text-[11px] font-black uppercase tracking-[.14em] text-neutral-400">{type}</p>
            <h3 className="mt-2 font-black">{label}</h3>
            <p className="mt-2 text-xs text-neutral-500">Click to configure</p>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX

make_page () {
  ROUTE="$1"
  TITLE="$2"
  SUBTITLE="$3"
  BODY="$4"
  mkdir -p "app/$ROUTE"
  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" subtitle="$SUBTITLE">
      $BODY
    </AppShell>
  );
}
TSX
}

CARD_GRID='<div className="grid gap-4 md:grid-cols-3">{["Create","Configure","Monitor","Review","Run","Export"].map((x)=>(<div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6"><h2 className="text-2xl font-black">{x}</h2><p className="mt-3 text-sm text-neutral-500">Workspace action for this module.</p></div>))}</div>'
TABLE='<div className="rounded-2xl border border-neutral-200 bg-white p-6"><div className="space-y-3">{["Workspace updated","Agent assigned","Workflow synced","Approval reviewed"].map((x)=>(<div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4"><span className="font-bold">{x}</span><span className="text-sm text-neutral-500">live</span></div>))}</div></div>'

make_page team "Team" "Members, roles, invites and workspace access." "$CARD_GRID"
make_page goals "Goals" "Company goals and agent alignment." "$CARD_GRID"
make_page tasks "Tasks" "Task queue, ownership and execution status." "$TABLE"
make_page usage "Usage" "Credits, runtime consumption and workspace limits." "$CARD_GRID"
make_page agents "Agents" "Create and manage AI employees." "$CARD_GRID"
make_page skills "Skills" "Reusable capabilities attached to agents." "$CARD_GRID"
make_page swarms "Swarms" "Multi-agent teams and delegation systems." "$CARD_GRID"
make_page billing "Billing" "Plans, invoices, credits and payment status." "$CARD_GRID"
make_page budgets "Budgets" "Agent, workflow and company spending controls." "$CARD_GRID"
make_page builder "Builder" "Create agents, workflows and company systems." "$CARD_GRID"
make_page activity "Activity" "Audit trail and workspace event feed." "$TABLE"
make_page datasets "Datasets" "Upload and index company knowledge." "$CARD_GRID"
make_page dataset-sell "Dataset Sell" "Package and sell approved datasets." "$CARD_GRID"
make_page settings "Settings" "Workspace, model keys, security and controls." "$CARD_GRID"
make_page approvals "Approvals" "Human approval inbox for sensitive actions." "$TABLE"
make_page companies "Companies" "Company profiles, workspaces and operating units." "$CARD_GRID"
make_page schedules "Schedules" "Recurring tasks and automation schedules." "$CARD_GRID"
make_page marketplace "Marketplace" "Buy, sell and install agents, skills and workflows." "$CARD_GRID"
make_page connection-layer "Connection Layer" "Connect Gmail, Slack, Notion, GitHub and other tools." "$CARD_GRID"
make_page brain "Company Brain" "Memory, RAG and company knowledge graph." "$CARD_GRID"
make_page realtime-dashboard "Realtime" "Runtime events, worker health and execution streams." "$TABLE"
make_page live-runtime "Live Runtime" "Live agent and workflow execution monitor." "$TABLE"
make_page agent-evolution "Agent Evolution" "Review agent improvements and version suggestions." "$CARD_GRID"

cat > app/pricing/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell";

export default function PricingPage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="text-7xl font-black tracking-[-.08em]">Pricing</h1>
        <p className="mt-5 max-w-2xl text-neutral-500">Credit-based plans for AI operations, agents and workflows.</p>

        <div className="mt-10 grid gap-4 md:grid-cols-4">
          {["Starter","Builder","Company","Enterprise"].map((p)=>(
            <div key={p} className="rounded-2xl border border-neutral-200 bg-white p-6">
              <h2 className="text-3xl font-black">{p}</h2>
              <p className="mt-4 text-neutral-500">Workspace access with platform credits and BYOK support.</p>
              <button className="mt-7 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">Start</button>
            </div>
          ))}
        </div>
      </section>
    </PublicShell>
  );
}
TSX

cat > app/legal/terms/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell";
export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">Terms</h1><p className="mt-6 leading-8 text-neutral-500">UNIC.ai workspace access, generated systems, exports and enterprise rights are governed by plan terms and applicable agreements.</p></section></PublicShell>}
TSX

cat > app/legal/refund/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell";
export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">Refund Policy</h1><p className="mt-6 leading-8 text-neutral-500">Refunds are reviewed according to subscription status, usage, credits and applicable commercial terms.</p></section></PublicShell>}
TSX

cat > app/legal/privacy/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell";
export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">Privacy Policy</h1><p className="mt-6 leading-8 text-neutral-500">UNIC.ai protects workspace data, connected credentials, model keys and company files through access controls and encrypted storage patterns.</p></section></PublicShell>}
TSX

cat > app/legal/ai-policy/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell";
export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">AI Policy</h1><p className="mt-6 leading-8 text-neutral-500">Users are responsible for reviewing AI outputs, configuring approvals and complying with laws and third-party platform terms.</p></section></PublicShell>}
TSX

npm run build
git add app components lib middleware.ts
git commit -m "Build approved UNIC.ai page set with auth and remember me" || true
git push origin main
