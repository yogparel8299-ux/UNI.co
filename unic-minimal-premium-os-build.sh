#!/bin/bash
set -e

echo "Building UNIC.ai minimal premium Next.js OS..."

mkdir -p components/unic lib app/{login,signup,onboarding,pricing,dashboard,workflow-studio,agents,swarms,tasks,datasets,brain,connection-layer,marketplace,billing,approvals,activity,settings,legal/privacy,legal/refund,legal/ai-policy,legal/terms}

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

cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

* { box-sizing: border-box; }

html, body {
  margin: 0;
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Inter", "Segoe UI", sans-serif;
  background: #f0f0ee;
}

.video-soft {
  filter: saturate(0.86) contrast(0.94) brightness(0.96);
}

.os-panel {
  background: rgba(237,237,237,.76);
  backdrop-filter: blur(18px);
  border: 1px solid rgba(255,255,255,.42);
}

.dark-panel {
  background: rgba(12, 16, 22, .58);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,.12);
}
CSS

cat > app/layout.tsx <<'TSX'
import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "UNIC.ai",
  description: "Operating System for AI Companies"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body>{children}</body></html>;
}
TSX

cat > components/unic/Logo.tsx <<'TSX'
export default function Logo() {
  return (
    <svg width="18" height="18" viewBox="0 0 256 256" fill="none">
      <path
        fill="rgb(84, 84, 84)"
        d="M 160 88 L 194 34 L 216 0 L 256 0 L 256 40 L 221.5 93.5 L 200 128 L 256 128 L 256 256 L 96 256 L 96 168 L 64.246 220 L 40 256 L 0 256 L 0 216 L 34 162 L 56 128 L 0 128 L 0 0 L 160 0 Z"
      />
    </svg>
  );
}
TSX

cat > components/unic/PublicHeroShell.tsx <<'TSX'
import Link from "next/link";
import Logo from "./Logo";

const links = [
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Pricing", "/pricing"],
  ["Login", "/login"]
];

export default function PublicHeroShell({
  badge,
  title,
  subtext,
  cta,
  ctaHref = "/signup",
  children
}: {
  badge: string;
  title: string;
  subtext: string;
  cta: string;
  ctaHref?: string;
  children?: React.ReactNode;
}) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-[#f0f0ee]">
      <video
        className="video-soft absolute inset-0 h-full w-full object-cover"
        src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4"
        autoPlay
        muted
        loop
        playsInline
      />
      <div className="absolute inset-0 bg-[#f0f0ee]/10" />

      <div className="relative z-10 flex min-h-screen flex-col">
        <nav className="flex items-center justify-center gap-2 px-4 pt-4 sm:gap-3 sm:px-8 sm:pt-6">
          <Link
            href="/"
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full sm:h-11 sm:w-11"
            style={{ backgroundColor: "#EDEDED" }}
          >
            <Logo />
          </Link>

          <div
            className="flex items-center gap-4 rounded-xl px-4 py-2.5 sm:gap-10 sm:px-8 sm:py-3"
            style={{ backgroundColor: "#EDEDED" }}
          >
            {links.map(([label, href]) => (
              <Link
                key={href}
                href={href}
                className="text-[12px] font-medium text-gray-700 transition-colors duration-200 hover:text-gray-900 sm:text-[14px]"
              >
                {label}
              </Link>
            ))}
          </div>
        </nav>

        <section className="flex flex-1 items-end px-6 pb-10 sm:px-12 sm:pb-16 md:px-20 lg:px-28 lg:pb-20">
          <div className="max-w-xs">
            <Link
              href="/dashboard"
              className="group mb-3 inline-flex items-center gap-1.5 text-[11.5px] font-medium text-blue-500 transition-colors hover:text-blue-600"
            >
              {badge}
              <span className="inline-block transition-transform duration-200 group-hover:translate-x-0.5">→</span>
            </Link>

            <h1 className="mb-3 text-[1.5rem] font-medium leading-[1.15] tracking-tight text-gray-900 sm:text-[1.75rem]">
              {title}
            </h1>

            <p className="mb-3 text-[13px] font-normal text-gray-400">{subtext}</p>

            <Link
              href={ctaHref}
              className="group inline-flex items-center gap-2 rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition-all duration-200 hover:border-blue-500 hover:bg-blue-500 hover:text-white"
            >
              {cta}
              <span className="transition-transform duration-200 group-hover:translate-x-0.5">→</span>
            </Link>
          </div>
        </section>

        {children}
      </div>
    </main>
  );
}
TSX

cat > components/unic/AppShell.tsx <<'TSX'
"use client";

import Link from "next/link";
import Logo from "./Logo";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Swarms", "/swarms"],
  ["Tasks", "/tasks"],
  ["Datasets", "/datasets"],
  ["Brain", "/brain"],
  ["Connect", "/connection-layer"],
  ["Market", "/marketplace"],
  ["Billing", "/billing"],
  ["Approvals", "/approvals"],
  ["Activity", "/activity"],
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

          <nav className="space-y-1">
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

cat > app/page.tsx <<'TSX'
import PublicHeroShell from "@/components/unic/PublicHeroShell";

export default function Page() {
  return (
    <PublicHeroShell
      badge="Seen in the future of AI operations"
      title="Simple, smart operating systems made for companies that keep building."
      subtext="Deploy your AI workforce now."
      cta="Start your workspace"
      ctaHref="/signup"
    />
  );
}
TSX

cat > app/pricing/page.tsx <<'TSX'
import PublicHeroShell from "@/components/unic/PublicHeroShell";

export default function Page() {
  return (
    <PublicHeroShell
      badge="Pricing for AI-native teams"
      title="Clear credits, clean plans, no confusing infrastructure."
      subtext="Choose the runtime that fits your company."
      cta="Open billing"
      ctaHref="/billing"
    />
  );
}
TSX

cat > app/login/page.tsx <<'TSX'
"use client";

import { useState } from "react";
import Link from "next/link";
import { supabaseBrowser } from "@/lib/supabase-browser";
import Logo from "@/components/unic/Logo";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function login() {
    setMsg("Logging in...");
    const { error } = await supabaseBrowser().auth.signInWithPassword({ email, password });
    if (error) return setMsg(error.message);
    window.location.href = "/dashboard";
  }

  return (
    <main className="relative grid min-h-screen place-items-center overflow-hidden bg-[#f0f0ee] p-6">
      <video className="video-soft absolute inset-0 h-full w-full object-cover" src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4" autoPlay muted loop playsInline />
      <div className="relative z-10 w-full max-w-sm rounded-2xl bg-[#EDEDED]/85 p-6 backdrop-blur-2xl">
        <div className="mb-6 flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white"><Logo /></div>
          <div>
            <p className="font-medium text-gray-900">UNIC.ai</p>
            <p className="text-[12px] text-gray-400">Initialize session</p>
          </div>
        </div>
        <input className="mb-3 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="mb-3 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <button onClick={login} className="w-full rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition hover:bg-blue-500 hover:text-white">Login →</button>
        {msg && <p className="mt-3 text-[12px] text-gray-500">{msg}</p>}
        <Link href="/signup" className="mt-4 block text-[12px] text-blue-500">Create workspace →</Link>
      </div>
    </main>
  );
}
TSX

cat > app/signup/page.tsx <<'TSX'
"use client";

import { useState } from "react";
import Link from "next/link";
import { supabaseBrowser } from "@/lib/supabase-browser";
import Logo from "@/components/unic/Logo";

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
    <main className="relative grid min-h-screen place-items-center overflow-hidden bg-[#f0f0ee] p-6">
      <video className="video-soft absolute inset-0 h-full w-full object-cover" src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4" autoPlay muted loop playsInline />
      <div className="relative z-10 w-full max-w-sm rounded-2xl bg-[#EDEDED]/85 p-6 backdrop-blur-2xl">
        <div className="mb-6 flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white"><Logo /></div>
          <div>
            <p className="font-medium text-gray-900">UNIC.ai</p>
            <p className="text-[12px] text-gray-400">Create workspace</p>
          </div>
        </div>
        <input className="mb-3 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="mb-3 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <button onClick={signup} className="w-full rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition hover:bg-blue-500 hover:text-white">Create account →</button>
        {msg && <p className="mt-3 text-[12px] text-gray-500">{msg}</p>}
        <Link href="/login" className="mt-4 block text-[12px] text-blue-500">Already have account →</Link>
      </div>
    </main>
  );
}
TSX

cat > app/onboarding/page.tsx <<'TSX'
"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function Page() {
  const [company, setCompany] = useState("");
  const [msg, setMsg] = useState("");

  async function createWorkspace() {
    setMsg("Creating workspace...");
    const supabase = supabaseBrowser();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return (window.location.href = "/login");

    await fetch("/api/onboarding-create-company", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ company_name: company, user_id: user.id })
    });

    window.location.href = "/dashboard";
  }

  return (
    <main className="relative grid min-h-screen place-items-center overflow-hidden bg-[#f0f0ee] p-6">
      <video className="video-soft absolute inset-0 h-full w-full object-cover" src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4" autoPlay muted loop playsInline />
      <div className="relative z-10 w-full max-w-sm rounded-2xl bg-[#EDEDED]/85 p-6 backdrop-blur-2xl">
        <p className="text-[12px] font-medium text-blue-500">Workspace onboarding</p>
        <h1 className="mt-3 text-[1.75rem] font-medium leading-[1.15] tracking-tight text-gray-900">Name your AI company system.</h1>
        <input className="mt-6 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Company name" value={company} onChange={(e) => setCompany(e.target.value)} />
        <button onClick={createWorkspace} className="mt-3 w-full rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition hover:bg-blue-500 hover:text-white">Create workspace →</button>
        {msg && <p className="mt-3 text-[12px] text-gray-500">{msg}</p>}
      </div>
    </main>
  );
}
TSX

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
        <Metric label="Active" value="42" />
        <Metric label="Synced" value="98%" />
        <Metric label="Queued" value="12" />
        <Metric label="Runtime" value="Live" />
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
            {["Runtime updated", "Record synced", "Action requested", "Worker completed"].map((item) => (
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

make_page dashboard "Command center" "Live company OS" "Watch agents, workflows, approvals, tools and runtime events from one clean surface."
make_page workflow-studio "Workflow studio" "Build automation" "Create node-based AI workflows with agents, tools, approvals and Supabase persistence."
make_page agents "AI workforce" "Agent fleet" "Manage AI workers, skills, memory, tool access, budgets and runtime status."
make_page swarms "Swarms" "Multi-agent systems" "Coordinate teams of AI agents with delegation, monitoring and review."
make_page tasks "Mission tasks" "Execution queue" "Track AI work across backlog, running, review and completed states."
make_page datasets "Datasets" "Knowledge ingestion" "Upload files, process documents, create embeddings and prepare memory."
make_page brain "Company brain" "Semantic memory" "Search company knowledge and inspect RAG memory state."
make_page connection-layer "Connection layer" "Connected tools" "Connect Gmail, Slack, GitHub, Notion and operational business apps."
make_page marketplace "Marketplace" "AI assets" "Install agents, workflows, tools and datasets into your workspace."
make_page billing "Billing" "Credits and plans" "Track credits, subscriptions, payments, invoices and usage."
make_page approvals "Approvals" "Human control" "Review sensitive AI actions before execution."
make_page activity "Activity" "Audit feed" "Inspect operational events, runtime logs and system history."
make_page settings "Settings" "Workspace control" "Manage workspace profile, keys, limits, security and preferences."

for p in privacy refund ai-policy terms; do
  cat > "app/legal/$p/page.tsx" <<TSX
import PublicHeroShell from "@/components/unic/PublicHeroShell";

export default function Page() {
  return (
    <PublicHeroShell
      badge="UNIC.ai legal"
      title="Clear terms for operating AI workspaces."
      subtext="Legal information for UNIC.ai."
      cta="Back home"
      ctaHref="/"
    />
  );
}
TSX
done

npm run build
git add .
git commit -m "Build UNIC minimal video hero OS direction"
git push origin main

echo "DONE. Redeploy Vercel."
