#!/bin/bash
set -e

echo "Fixing UNIC.ai premium UI, auth routing, and collapsed navigation..."

mkdir -p components
mkdir -p app/login app/signup app/agents app/skills app/dashboard

cat > app/globals.css <<'CSS'
@import "tailwindcss";

:root {
  --bg: #030303;
  --panel: rgba(255,255,255,0.06);
  --panel2: rgba(255,255,255,0.1);
  --line: rgba(255,255,255,0.12);
  --text: #f7f7f7;
  --muted: rgba(255,255,255,0.62);
  --green: #72ff9d;
  --orange: #ff8a5b;
  --blue: #7aa7ff;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

a {
  color: inherit;
  text-decoration: none;
}

.page-shell {
  min-height: 100vh;
  background:
    radial-gradient(circle at 20% 10%, rgba(255,106,61,.28), transparent 28%),
    radial-gradient(circle at 70% 18%, rgba(91,129,255,.24), transparent 26%),
    radial-gradient(circle at 50% 55%, rgba(114,255,157,.12), transparent 30%),
    #030303;
}

.glass {
  background: rgba(255,255,255,.06);
  border: 1px solid rgba(255,255,255,.12);
  backdrop-filter: blur(22px);
  box-shadow: 0 24px 80px rgba(0,0,0,.35);
}

.glass-card {
  background: linear-gradient(145deg, rgba(255,255,255,.10), rgba(255,255,255,.045));
  border: 1px solid rgba(255,255,255,.12);
  border-radius: 32px;
  box-shadow: 0 30px 100px rgba(0,0,0,.35);
}

.primary-button {
  border: 0;
  border-radius: 999px;
  padding: 13px 22px;
  color: #080808;
  background: linear-gradient(135deg, #ffffff, #ff9d72);
  font-weight: 800;
  cursor: pointer;
}

.secondary-button {
  border: 1px solid rgba(255,255,255,.14);
  border-radius: 999px;
  padding: 13px 22px;
  color: white;
  background: rgba(255,255,255,.06);
  font-weight: 700;
  cursor: pointer;
}

.input-box {
  width: 100%;
  border-radius: 18px;
  border: 1px solid rgba(255,255,255,.12);
  background: rgba(255,255,255,.07);
  color: white;
  padding: 15px 16px;
  outline: none;
}

.input-box::placeholder {
  color: rgba(255,255,255,.45);
}

.page-title {
  font-size: clamp(42px, 7vw, 110px);
  letter-spacing: -.08em;
  line-height: .86;
  font-weight: 950;
}

.page-subtitle {
  color: var(--muted);
  font-size: 18px;
  line-height: 1.7;
  max-width: 720px;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  border: 1px solid rgba(255,255,255,.12);
  background: rgba(255,255,255,.06);
  border-radius: 999px;
  padding: 9px 13px;
  font-size: 12px;
  color: rgba(255,255,255,.78);
  font-weight: 700;
}

.orb {
  position: absolute;
  border-radius: 999px;
  filter: blur(.2px);
  opacity: .9;
  pointer-events: none;
}

.orb-1 {
  width: 520px;
  height: 760px;
  top: 70px;
  left: 28%;
  background: radial-gradient(circle at 40% 20%, rgba(255,117,77,.9), transparent 18%),
    radial-gradient(circle at 70% 15%, rgba(137,114,255,.85), transparent 28%),
    radial-gradient(circle at 50% 70%, rgba(255,145,90,.6), transparent 36%);
  box-shadow: inset 0 0 70px rgba(255,255,255,.18), 0 0 90px rgba(255,112,80,.22);
  transform: rotate(25deg);
  mix-blend-mode: screen;
}

.orb-2 {
  width: 460px;
  height: 460px;
  top: 420px;
  left: 22%;
  background: radial-gradient(circle at 20% 10%, rgba(255,154,90,.9), transparent 25%),
    radial-gradient(circle at 70% 90%, rgba(90,116,255,.85), transparent 35%),
    rgba(255,255,255,.02);
  box-shadow: inset 0 0 70px rgba(255,255,255,.16), 0 0 80px rgba(90,116,255,.25);
  mix-blend-mode: screen;
}

.orb-3 {
  width: 260px;
  height: 360px;
  top: 120px;
  right: 8%;
  background: radial-gradient(circle at 35% 10%, rgba(114,255,157,.7), transparent 26%),
    radial-gradient(circle at 80% 80%, rgba(74,113,255,.75), transparent 36%);
  box-shadow: inset 0 0 55px rgba(255,255,255,.14), 0 0 80px rgba(90,116,255,.22);
  mix-blend-mode: screen;
}

.sidebar {
  background: rgba(5,5,5,.78);
  border-right: 1px solid rgba(255,255,255,.10);
  backdrop-filter: blur(28px);
}

.nav-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 16px;
  padding: 12px 14px;
  color: rgba(255,255,255,.72);
  font-size: 14px;
}

.nav-item:hover {
  background: rgba(255,255,255,.08);
  color: white;
}

.nav-child {
  display: block;
  margin-left: 18px;
  padding: 9px 14px;
  border-radius: 14px;
  color: rgba(255,255,255,.55);
  font-size: 13px;
}

.nav-child:hover {
  background: rgba(255,255,255,.07);
  color: white;
}
CSS

cat > app/page.tsx <<'TSX'
import Link from "next/link";

export default function HomePage() {
  return (
    <main className="page-shell relative overflow-hidden">
      <div className="orb orb-1" />
      <div className="orb orb-2" />
      <div className="orb orb-3" />

      <nav className="relative z-10 mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <div className="glass flex items-center gap-3 rounded-full px-4 py-3">
          <div className="h-8 w-8 rounded-full bg-white text-black grid place-items-center font-black">U</div>
          <span className="font-black tracking-[-0.03em]">UNIC.ai</span>
        </div>

        <div className="glass hidden rounded-full px-6 py-3 md:flex gap-9 text-sm text-white/75">
          <Link href="/pricing">platform</Link>
          <Link href="/marketplace">marketplace</Link>
          <Link href="/agents">agents</Link>
          <Link href="/connection-layer">connectors</Link>
          <Link href="/legal/ownership">company</Link>
        </div>

        <Link href="/signup" className="primary-button">
          get started
        </Link>
      </nav>

      <section className="relative z-10 mx-auto grid max-w-7xl grid-cols-1 gap-12 px-6 pb-20 pt-20 lg:grid-cols-[1.1fr_.9fr]">
        <div>
          <div className="mb-8 flex flex-wrap gap-3">
            <span className="status-pill">AI company operating system</span>
            <span className="status-pill">BYOK-first</span>
            <span className="status-pill">workers run 24/7</span>
          </div>

          <h1 className="page-title">
            build your<br />AI company
          </h1>

          <p className="page-subtitle mt-8">
            UNIC.ai lets users create AI agents, skills, workflows, departments, approval systems,
            company memory, marketplace assets and autonomous business operations from one premium command center.
          </p>

          <div className="mt-10 flex flex-wrap gap-4">
            <Link href="/signup" className="primary-button">start building</Link>
            <Link href="/login" className="secondary-button">login</Link>
          </div>

          <div className="mt-16 grid grid-cols-3 gap-5 max-w-2xl">
            <div>
              <p className="text-4xl font-black">24/7</p>
              <p className="text-white/45 text-sm mt-2">worker execution</p>
            </div>
            <div>
              <p className="text-4xl font-black">100+</p>
              <p className="text-white/45 text-sm mt-2">connector-ready tools</p>
            </div>
            <div>
              <p className="text-4xl font-black">BYOK</p>
              <p className="text-white/45 text-sm mt-2">profitable by default</p>
            </div>
          </div>
        </div>

        <div className="glass-card p-6 lg:mt-24">
          <div className="rounded-[28px] border border-white/10 bg-black/30 p-6">
            <p className="text-sm text-green-300 font-bold">LIVE COMPANY STACK</p>
            <div className="mt-6 space-y-4">
              {[
                ["AI Boardroom", "strategy decisions, approvals, weekly reports"],
                ["Agents + Skills", "sales, support, finance, research, operations"],
                ["Workflow Studio", "drag/drop execution pipelines"],
                ["Company Brain", "datasets, memory, RAG and context"],
                ["Autopilot", "background workers complete tasks after tabs close"]
              ].map(([title, text]) => (
                <div key={title} className="rounded-3xl border border-white/10 bg-white/[.04] p-5">
                  <h3 className="font-black text-xl">{title}</h3>
                  <p className="text-white/50 mt-2 text-sm leading-6">{text}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="relative z-10 mx-auto max-w-7xl px-6 pb-28">
        <p className="mb-8 text-center text-white/45">Built for founders, operators, agencies and AI-native companies</p>
        <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
          {[
            ["Generate companies", "Create departments, AI employees, SOPs, workflows, business templates and operating systems."],
            ["Connect tools", "Let agents use Gmail, Slack, Notion, GitHub, Drive and other tools through secure connector sessions."],
            ["Control execution", "Approval inbox, budgets, rate limits, subscription locks, rollback and worker monitoring."]
          ].map(([title, text]) => (
            <div className="glass-card p-8" key={title}>
              <div className="mb-10 h-28 rounded-[32px] bg-gradient-to-br from-white/10 via-orange-400/20 to-blue-500/20" />
              <h2 className="text-3xl font-black tracking-[-0.04em]">{title}</h2>
              <p className="mt-5 text-white/55 leading-7">{text}</p>
            </div>
          ))}
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
    setMsg("Logging in...");
    const supabase = supabaseBrowser();
    const { error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      setMsg(error.message);
      return;
    }

    window.location.href = "/dashboard";
  }

  return (
    <main className="page-shell min-h-screen grid place-items-center px-6">
      <div className="glass-card w-full max-w-md p-8">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Login</h1>
        <p className="text-white/50 mt-3">Access your UNIC.ai workspace.</p>

        <input className="input-box mt-8" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="input-box mt-4" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

        <button className="primary-button mt-6 w-full" onClick={login}>Login</button>

        {msg && <p className="mt-4 text-sm text-white/60">{msg}</p>}

        <p className="mt-6 text-sm text-white/45">
          New here? <Link className="text-white" href="/signup">Create account</Link>
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
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function SignupPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function signup() {
    setMsg("Creating account...");
    const supabase = supabaseBrowser();
    const { data, error } = await supabase.auth.signUp({ email, password });

    if (error) {
      setMsg(error.message);
      return;
    }

    if (data.user?.id) {
      await fetch("/api/verify-user-email", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ user_id: data.user.id, email })
      }).catch(() => {});
    }

    setMsg("Account created. Go to dashboard.");
    setTimeout(() => {
      window.location.href = "/onboarding";
    }, 700);
  }

  return (
    <main className="page-shell min-h-screen grid place-items-center px-6">
      <div className="glass-card w-full max-w-md p-8">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Start UNIC.ai</h1>
        <p className="text-white/50 mt-3">Create your AI company operating system.</p>

        <input className="input-box mt-8" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="input-box mt-4" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

        <button className="primary-button mt-6 w-full" onClick={signup}>Create account</button>

        {msg && <p className="mt-4 text-sm text-white/60">{msg}</p>}

        <p className="mt-6 text-sm text-white/45">
          Already have an account? <Link className="text-white" href="/login">Login</Link>
        </p>
      </div>
    </main>
  );
}
TSX

cat > components/Nav.tsx <<'TSX'
"use client";

import Link from "next/link";
import { useState } from "react";

const groups = [
  {
    title: "Command",
    items: [
      ["Dashboard", "/dashboard"],
      ["Command Center", "/command"],
      ["Realtime Dashboard", "/realtime-dashboard"],
      ["Notifications", "/notifications-center"]
    ]
  },
  {
    title: "Agents",
    items: [
      ["All Agents", "/agents"],
      ["Skills", "/skills"],
      ["Swarms", "/swarms"],
      ["Agent Reviews", "/seller-dashboard"],
      ["Worker Health", "/worker-health"]
    ]
  },
  {
    title: "Company",
    items: [
      ["Companies", "/companies"],
      ["AI Boardroom", "/ai-boardroom"],
      ["Departments", "/departments"],
      ["Business Generator", "/business-generator"],
      ["Company Brain", "/brain"]
    ]
  },
  {
    title: "Automation",
    items: [
      ["Workflow Studio", "/workflow-studio"],
      ["Builder", "/builder"],
      ["Rollback Center", "/rollback-center"],
      ["Approval Inbox", "/approval-inbox"],
      ["Autopilot", "/company-autopilot"]
    ]
  },
  {
    title: "Data & Tools",
    items: [
      ["Datasets", "/datasets"],
      ["Dataset Lab", "/dataset-lab"],
      ["RAG Search", "/rag"],
      ["Connectors", "/connection-layer"],
      ["MCP Gateway", "/mcp-gateway"]
    ]
  },
  {
    title: "Business",
    items: [
      ["Marketplace", "/marketplace-explore"],
      ["Billing", "/billing-center"],
      ["Usage", "/usage-dashboard"],
      ["Pricing", "/pricing"],
      ["Settings", "/settings"]
    ]
  }
];

export default function Nav() {
  const [open, setOpen] = useState<Record<string, boolean>>({
    Command: true,
    Agents: true
  });

  return (
    <aside className="sidebar fixed left-0 top-0 z-40 hidden h-screen w-[280px] overflow-y-auto p-5 lg:block">
      <Link href="/" className="mb-8 flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-full bg-white text-black font-black">U</div>
        <div>
          <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
          <p className="text-xs text-white/40">AI company OS</p>
        </div>
      </Link>

      <div className="space-y-3">
        {groups.map((group) => (
          <div key={group.title}>
            <button
              onClick={() => setOpen({ ...open, [group.title]: !open[group.title] })}
              className="nav-item w-full"
            >
              <span>{group.title}</span>
              <span>{open[group.title] ? "−" : "+"}</span>
            </button>

            {open[group.title] && (
              <div className="mt-1 space-y-1">
                {group.items.map(([label, href]) => (
                  <Link key={href} href={href} className="nav-child">
                    {label}
                  </Link>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
    </aside>
  );
}
TSX

cat > components/Shell.tsx <<'TSX'
import Nav from "@/components/Nav";

export default function Shell({
  title,
  subtitle,
  children
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  return (
    <main className="page-shell min-h-screen">
      <Nav />
      <section className="px-6 py-8 lg:ml-[280px] lg:px-10">
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-5xl md:text-7xl font-black tracking-[-0.07em]">{title}</h1>
            {subtitle && <p className="page-subtitle mt-4">{subtitle}</p>}
          </div>
          <a href="/signup" className="primary-button hidden md:inline-flex">get started</a>
        </div>
        {children}
      </section>
    </main>
  );
}
TSX

git add app components
git commit -m "Upgrade UNIC.ai premium UI auth and navigation" || true
npm run build
git push origin main
