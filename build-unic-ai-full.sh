#!/bin/bash
set -e

echo "Building UNIC.ai full Codespaces app..."

rm -rf app components lib workers scripts
mkdir -p app/{dashboard,command,companies,agents,swarms,tasks,datasets,marketplace,billing,approvals,activity,builder,usage,schedules,settings,pricing,login,signup,legal/privacy,legal/refund,legal/ai-policy}
mkdir -p app/api/{command,queue}
mkdir -p components lib workers scripts

cat > package.json <<'PKG'
{
  "name": "unic-ai",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "worker": "node workers/runtime-worker.js"
  },
  "dependencies": {
    "@supabase/ssr": "latest",
    "@supabase/supabase-js": "latest",
    "next": "latest",
    "react": "latest",
    "react-dom": "latest",
    "openai": "latest",
    "lucide-react": "latest"
  },
  "devDependencies": {
    "typescript": "latest",
    "@types/node": "latest",
    "@types/react": "latest",
    "tailwindcss": "latest",
    "postcss": "latest",
    "autoprefixer": "latest"
  }
}
PKG

cat > next.config.js <<'NEXT'
module.exports = {
  eslint: { ignoreDuringBuilds: true },
  typescript: { ignoreBuildErrors: true }
};
NEXT

cat > tsconfig.json <<'TS'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": false,
    "noEmit": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
TS

cat > tailwind.config.js <<'TW'
module.exports = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {}
  },
  plugins: []
};
TW

cat > postcss.config.js <<'POST'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
};
POST

cat > .env.example <<'ENV'
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
OPENAI_API_KEY=
NEXT_PUBLIC_APP_NAME=UNIC.ai
NEXT_PUBLIC_APP_URL=
UNIC_WORKER_SECRET=
ENV

cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --bg: #ffffff;
  --soft: #f7f8fa;
  --text: #0a0a0a;
  --muted: #6b7280;
  --green: #22c55e;
  --green-dark: #16a34a;
  --border: rgba(15, 23, 42, 0.08);
  --shadow: 0 20px 60px rgba(15, 23, 42, 0.06);
  --shadow-soft: 0 8px 30px rgba(15, 23, 42, 0.04);
}

* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  background: #ffffff;
  color: var(--text);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  -webkit-font-smoothing: antialiased;
}

a {
  color: inherit;
  text-decoration: none;
}

.page-shell {
  display: flex;
  min-height: 100vh;
  background:
    radial-gradient(circle at top right, rgba(34, 197, 94, 0.10), transparent 32%),
    radial-gradient(circle at bottom left, rgba(34, 197, 94, 0.06), transparent 26%),
    linear-gradient(to bottom right, #ffffff, #f7f8fa);
}

.sidebar {
  width: 292px;
  min-height: 100vh;
  padding: 28px;
  background: rgba(255, 255, 255, 0.78);
  backdrop-filter: blur(26px);
  border-right: 1px solid rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
}

.sidebar-link {
  display: block;
  padding: 14px 18px;
  border-radius: 18px;
  color: #4b5563;
  margin-bottom: 6px;
  transition: all 0.22s ease;
}

.sidebar-link:hover {
  background: rgba(34, 197, 94, 0.10);
  color: #0a0a0a;
  transform: translateX(3px);
}

.main {
  flex: 1;
  padding: 44px;
}

.page-title {
  font-size: 54px;
  line-height: 0.95;
  letter-spacing: -0.055em;
  font-weight: 850;
}

.page-subtitle {
  color: var(--muted);
  margin-top: 14px;
  font-size: 17px;
  max-width: 780px;
  line-height: 1.7;
}

.glass-card {
  background: rgba(255, 255, 255, 0.86);
  border: 1px solid var(--border);
  border-radius: 32px;
  box-shadow: var(--shadow);
  backdrop-filter: blur(22px);
}

.primary-button {
  background: linear-gradient(135deg, var(--green), var(--green-dark));
  color: white;
  padding: 14px 22px;
  border-radius: 999px;
  font-weight: 750;
  border: none;
  cursor: pointer;
  box-shadow: 0 14px 34px rgba(34, 197, 94, 0.20);
  transition: all 0.22s ease;
}

.primary-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 22px 54px rgba(34, 197, 94, 0.26);
}

.secondary-button {
  background: white;
  color: #111827;
  padding: 14px 22px;
  border-radius: 999px;
  font-weight: 700;
  border: 1px solid rgba(0, 0, 0, 0.08);
  cursor: pointer;
}

.metric {
  padding: 28px;
}

.metric-label {
  color: var(--muted);
  font-size: 14px;
  font-weight: 600;
}

.metric-value {
  font-size: 42px;
  font-weight: 850;
  margin-top: 8px;
  letter-spacing: -0.05em;
}

.table {
  width: 100%;
  border-collapse: collapse;
}

.table th {
  text-align: left;
  padding: 16px;
  color: #6b7280;
  background: rgba(0,0,0,0.025);
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.table td {
  padding: 16px;
  border-top: 1px solid rgba(0,0,0,0.06);
  color: #111827;
  font-size: 14px;
}

.input-box {
  width: 100%;
  border: 1px solid rgba(0,0,0,0.10);
  background: rgba(255,255,255,0.86);
  border-radius: 28px;
  padding: 22px;
  outline: none;
  transition: all 0.22s ease;
}

.input-box:focus {
  border-color: rgba(34, 197, 94, 0.45);
  box-shadow: 0 0 0 6px rgba(34, 197, 94, 0.10);
}

.status-pill {
  display: inline-flex;
  background: rgba(34,197,94,0.10);
  color: #15803d;
  border: 1px solid rgba(34,197,94,0.14);
  padding: 8px 14px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 700;
}
CSS

cat > app/layout.tsx <<'LAYOUT'
import "./globals.css";

export const metadata = {
  title: "UNIC.ai",
  description: "AI Agent Operating System"
};

export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
LAYOUT

cat > lib/supabase-admin.ts <<'ADMIN'
import { createClient } from "@supabase/supabase-js";

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || "",
  process.env.SUPABASE_SERVICE_ROLE_KEY || ""
);
ADMIN

cat > lib/command-planner.ts <<'PLANNER'
import OpenAI from "openai";

export type CommandPlan = {
  company?: {
    name: string;
    slug: string;
  };
  agents?: {
    name: string;
    description: string;
    system_prompt: string;
    model?: string;
  }[];
  workflows?: {
    name: string;
    graph: any;
  }[];
  tasks?: {
    title: string;
    input: string;
    agent_name?: string;
  }[];
  response: string;
};

function slugify(input: string) {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 50);
}

export async function createCommandPlan(command: string): Promise<CommandPlan> {
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    const name = command.slice(0, 48) || "New AI Company";

    return {
      company: {
        name,
        slug: slugify(name) || "new-ai-company"
      },
      agents: [
        {
          name: "CEO Agent",
          description: "Defines company strategy, goals, operating model and execution roadmap.",
          system_prompt: "You are a CEO agent. Build strategy, priorities, plans and operating decisions.",
          model: "gpt-4o-mini"
        },
        {
          name: "Research Agent",
          description: "Researches markets, customers, competitors and useful data.",
          system_prompt: "You are a research agent. Produce structured research with assumptions and next actions.",
          model: "gpt-4o-mini"
        },
        {
          name: "Execution Agent",
          description: "Executes tasks and creates business outputs.",
          system_prompt: "You are an execution agent. Complete the task with practical, ready-to-use output.",
          model: "gpt-4o-mini"
        }
      ],
      workflows: [
        {
          name: "Company Build Workflow",
          graph: {
            nodes: [
              { id: "ceo", type: "agent", label: "CEO Agent" },
              { id: "research", type: "agent", label: "Research Agent" },
              { id: "execution", type: "agent", label: "Execution Agent" }
            ],
            edges: [
              { from: "ceo", to: "research" },
              { from: "research", to: "execution" }
            ]
          }
        }
      ],
      tasks: [
        {
          title: "Create company operating plan",
          input: command,
          agent_name: "CEO Agent"
        },
        {
          title: "Create first execution output",
          input: command,
          agent_name: "Execution Agent"
        }
      ],
      response: "Created a fallback AI company plan because OPENAI_API_KEY is not configured."
    };
  }

  const openai = new OpenAI({ apiKey });

  const completion = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0.2,
    messages: [
      {
        role: "system",
        content: `
You are the UNIC.ai command planner.

Convert the user command into JSON only.

Return this exact shape:
{
  "company": { "name": "...", "slug": "..." },
  "agents": [
    {
      "name": "...",
      "description": "...",
      "system_prompt": "...",
      "model": "gpt-4o-mini"
    }
  ],
  "workflows": [
    {
      "name": "...",
      "graph": {
        "nodes": [],
        "edges": []
      }
    }
  ],
  "tasks": [
    {
      "title": "...",
      "input": "...",
      "agent_name": "..."
    }
  ],
  "response": "short explanation"
}

Rules:
- If the user asks to build a company, create company, agents, workflow and tasks.
- If the user asks to create an agent, include agents.
- If the user asks to create a workflow, include workflows.
- If the user asks to run work, include tasks.
- Always make useful agents.
- Slug must be lowercase and URL safe.
- Return JSON only. No markdown.
`
      },
      {
        role: "user",
        content: command
      }
    ]
  });

  const raw = completion.choices[0]?.message?.content || "{}";

  try {
    return JSON.parse(raw);
  } catch {
    return {
      response: "Planner returned invalid JSON.",
      tasks: [
        {
          title: "Manual command review",
          input: command
        }
      ]
    };
  }
}
PLANNER

cat > components/Nav.tsx <<'NAV'
import Link from "next/link";

const links = [
  ["Dashboard", "/dashboard"],
  ["Command", "/command"],
  ["Companies", "/companies"],
  ["Agents", "/agents"],
  ["Swarms", "/swarms"],
  ["Tasks", "/tasks"],
  ["Builder", "/builder"],
  ["Datasets", "/datasets"],
  ["Marketplace", "/marketplace"],
  ["Approvals", "/approvals"],
  ["Usage", "/usage"],
  ["Activity", "/activity"],
  ["Billing", "/billing"],
  ["Schedules", "/schedules"],
  ["Settings", "/settings"]
];

export default function Nav() {
  return (
    <aside className="sidebar">
      <Link href="/" className="text-4xl font-black tracking-[-0.055em]">
        UNIC<span className="text-green-500">.ai</span>
      </Link>

      <p className="text-gray-500 mt-2 mb-10">
        AI Operating System
      </p>

      <div>
        {links.map(([label, href]) => (
          <Link key={href} href={href} className="sidebar-link">
            {label}
          </Link>
        ))}
      </div>

      <div className="glass-card p-5 mt-10">
        <div className="status-pill">
          Runtime Active
        </div>
        <p className="text-gray-500 text-sm mt-4 leading-7">
          Workers, queues, usage, agent runs and AI command execution are ready.
        </p>
      </div>
    </aside>
  );
}
NAV

cat > components/Shell.tsx <<'SHELL'
import Nav from "./Nav";

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
    <main className="page-shell">
      <Nav />
      <section className="main">
        <div className="flex items-center justify-between gap-8 mb-10">
          <div>
            <h1 className="page-title">{title}</h1>
            <p className="page-subtitle">
              {subtitle || "Live UNIC.ai command center powered by Supabase, workers and AI runtime infrastructure."}
            </p>
          </div>
          <button className="primary-button">
            Create
          </button>
        </div>
        {children}
      </section>
    </main>
  );
}
SHELL

cat > components/Card.tsx <<'CARD'
export default function Card({
  title,
  value,
  note
}: {
  title: string;
  value: any;
  note?: string;
}) {
  return (
    <div className="glass-card metric">
      <p className="metric-label">{title}</p>
      <h2 className="metric-value">{value}</h2>
      {note && <p className="text-gray-500 text-sm mt-3">{note}</p>}
    </div>
  );
}
CARD

cat > components/DataTable.tsx <<'TABLE'
export default function DataTable({ rows }: { rows: any[] }) {
  if (!rows?.length) {
    return (
      <div className="glass-card p-10 text-gray-500">
        No records yet. Create records using the AI Command Center or Supabase.
      </div>
    );
  }

  const keys = Object.keys(rows[0]).slice(0, 6);

  return (
    <div className="glass-card overflow-hidden">
      <table className="table">
        <thead>
          <tr>
            {keys.map((k) => (
              <th key={k}>{k}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={row.id || i}>
              {keys.map((k) => (
                <td key={k}>
                  {typeof row[k] === "object"
                    ? JSON.stringify(row[k]).slice(0, 80)
                    : String(row[k] ?? "").slice(0, 80)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
TABLE

cat > components/CommandCenter.tsx <<'CMD'
"use client";

import { useState } from "react";

export default function CommandCenter() {
  const [command, setCommand] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  async function runCommand() {
    if (!command.trim()) return;

    setLoading(true);
    setResult(null);

    try {
      const res = await fetch("/api/command", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ command })
      });

      const data = await res.json();
      setResult(data);
    } catch (err: any) {
      setResult({
        ok: false,
        error: err.message || "Command failed"
      });
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="glass-card p-8">
      <div className="flex items-start justify-between gap-8">
        <div>
          <p className="text-green-600 font-bold mb-3">
            UNIC.ai Command Center
          </p>

          <h2 className="text-4xl font-black tracking-[-0.045em]">
            Tell UNIC.ai what to build.
          </h2>

          <p className="text-gray-500 mt-4 max-w-3xl leading-7">
            Create companies, agents, workflows, tasks and queued execution jobs from one natural-language command.
          </p>
        </div>

        <div className="status-pill">
          AI Builder Active
        </div>
      </div>

      <textarea
        value={command}
        onChange={(e) => setCommand(e.target.value)}
        placeholder="Example: Build me a company for an AI sales agency. Create a CEO agent, sales closer agent, email marketing agent, workflow and run the first output."
        className="input-box mt-8 min-h-[180px] text-lg"
      />

      <div className="mt-5 flex gap-4">
        <button
          onClick={runCommand}
          disabled={loading}
          className="primary-button disabled:opacity-60"
        >
          {loading ? "Building..." : "Run Command"}
        </button>

        <button
          onClick={() =>
            setCommand(
              "Build me a company for an AI sales agency. Create a CEO agent, sales closer agent, email marketing agent, a workflow to find leads and send outreach, and run the first output."
            )
          }
          className="secondary-button"
        >
          Use Example
        </button>
      </div>

      {result && (
        <div className="mt-8 rounded-[28px] border border-black/10 bg-white p-6">
          <p className="font-bold text-lg">
            Result
          </p>

          {result.ok ? (
            <div className="mt-4 space-y-4">
              <p className="text-gray-700">
                {result.response}
              </p>

              <div className="grid grid-cols-4 gap-4">
                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Company</p>
                  <p className="font-bold">{result.company ? "Created" : "Used"}</p>
                </div>

                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Agents</p>
                  <p className="font-bold">{result.agents?.length || 0}</p>
                </div>

                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Workflows</p>
                  <p className="font-bold">{result.workflows?.length || 0}</p>
                </div>

                <div className="rounded-2xl bg-gray-50 p-4">
                  <p className="text-gray-500 text-sm">Queued Jobs</p>
                  <p className="font-bold">{result.queued_jobs?.length || 0}</p>
                </div>
              </div>

              <pre className="overflow-auto rounded-2xl bg-gray-950 text-green-300 p-5 text-xs max-h-[420px]">
                {JSON.stringify(result, null, 2)}
              </pre>
            </div>
          ) : (
            <p className="mt-4 text-red-600">
              {result.error}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
CMD

cat > app/page.tsx <<'HOME'
import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen bg-white p-8">
      <nav className="flex justify-between items-center">
        <div className="text-4xl font-black tracking-[-0.055em]">
          UNIC<span className="text-green-500">.ai</span>
        </div>

        <div className="space-x-5">
          <Link href="/pricing">Pricing</Link>
          <Link href="/login">Login</Link>
          <Link href="/dashboard" className="primary-button">
            Open Dashboard
          </Link>
        </div>
      </nav>

      <section className="py-32 max-w-6xl">
        <p className="text-green-600 font-bold mb-5">
          AI Agent Operating System
        </p>

        <h1 className="text-7xl font-black tracking-[-0.065em] leading-[0.94]">
          Build, host, train, sell and operate AI agents from one beautiful command center.
        </h1>

        <p className="text-xl text-gray-500 mt-8 max-w-3xl leading-8">
          UNIC.ai gives companies one operating layer for agents, swarms, datasets, billing, usage, approvals, marketplace and runtime infrastructure.
        </p>

        <div className="mt-10 flex gap-4">
          <Link href="/command" className="primary-button">
            Build with AI Command
          </Link>

          <Link href="/dashboard" className="secondary-button">
            View Dashboard
          </Link>
        </div>
      </section>

      <section className="grid grid-cols-3 gap-6 pb-20">
        {[
          ["AI Command Center", "Tell UNIC.ai to build companies, agents and workflows."],
          ["Agent Runtime", "Queue tasks and process outputs with workers."],
          ["Marketplace Layer", "Prepare agents and datasets for buying, selling and renting."]
        ].map(([title, text]) => (
          <div key={title} className="glass-card p-8">
            <h3 className="text-2xl font-black tracking-[-0.03em]">{title}</h3>
            <p className="text-gray-500 mt-4 leading-7">{text}</p>
          </div>
        ))}
      </section>
    </main>
  );
}
HOME

cat > app/api/command/route.ts <<'API'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createCommandPlan } from "@/lib/command-planner";

function slugify(input: string) {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 50);
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const command = body.command as string;

    if (!command) {
      return NextResponse.json(
        { ok: false, error: "Command is required." },
        { status: 400 }
      );
    }

    const plan = await createCommandPlan(command);

    let companyId = body.company_id || null;
    let company: any = null;

    if (!companyId && plan.company?.name) {
      const slugBase = plan.company.slug || slugify(plan.company.name);
      const slug = `${slugBase}-${Date.now().toString().slice(-5)}`;

      const { data, error } = await supabaseAdmin
        .from("companies")
        .insert({
          name: plan.company.name,
          slug,
          plan: "free"
        })
        .select()
        .single();

      if (error) throw error;

      company = data;
      companyId = data.id;

      await supabaseAdmin.from("billing_accounts").insert({
        company_id: companyId,
        plan: "free",
        monthly_limit: 100,
        current_usage: 0
      });

      await supabaseAdmin.from("activity_logs").insert({
        company_id: companyId,
        action: "company_created_by_ai_command",
        entity_type: "company",
        entity_id: companyId,
        metadata: { command }
      });
    }

    if (!companyId) {
      return NextResponse.json(
        {
          ok: false,
          error: "No company_id found and command did not create a company."
        },
        { status: 400 }
      );
    }

    const createdAgents: any[] = [];

    for (const agent of plan.agents || []) {
      const { data, error } = await supabaseAdmin
        .from("agents")
        .insert({
          company_id: companyId,
          name: agent.name,
          description: agent.description,
          system_prompt: agent.system_prompt,
          model: agent.model || "gpt-4o-mini",
          status: "active"
        })
        .select()
        .single();

      if (!error && data) {
        createdAgents.push(data);

        await supabaseAdmin.from("activity_logs").insert({
          company_id: companyId,
          action: "agent_created_by_ai_command",
          entity_type: "agent",
          entity_id: data.id,
          metadata: { agent }
        });
      }
    }

    const createdWorkflows: any[] = [];

    for (const workflow of plan.workflows || []) {
      const { data, error } = await supabaseAdmin
        .from("workflow_builders")
        .insert({
          company_id: companyId,
          name: workflow.name,
          graph: workflow.graph || {},
          status: "active"
        })
        .select()
        .single();

      if (!error && data) {
        createdWorkflows.push(data);

        await supabaseAdmin.from("activity_logs").insert({
          company_id: companyId,
          action: "workflow_created_by_ai_command",
          entity_type: "workflow_builder",
          entity_id: data.id,
          metadata: { workflow }
        });
      }
    }

    const createdTasks: any[] = [];
    const queuedJobs: any[] = [];

    for (const task of plan.tasks || []) {
      const selectedAgent =
        createdAgents.find((a) => a.name === task.agent_name) ||
        createdAgents[0] ||
        null;

      const { data: taskData, error: taskError } = await supabaseAdmin
        .from("tasks")
        .insert({
          company_id: companyId,
          agent_id: selectedAgent?.id || null,
          title: task.title,
          input: task.input,
          status: "queued"
        })
        .select()
        .single();

      if (!taskError && taskData) {
        createdTasks.push(taskData);

        const { data: queueData } = await supabaseAdmin
          .from("execution_queue")
          .insert({
            company_id: companyId,
            agent_id: selectedAgent?.id || null,
            task_id: taskData.id,
            payload: {
              prompt: task.input,
              task_title: task.title,
              agent_name: selectedAgent?.name,
              system_prompt: selectedAgent?.system_prompt,
              model: selectedAgent?.model || "gpt-4o-mini"
            },
            status: "pending"
          })
          .select()
          .single();

        if (queueData) queuedJobs.push(queueData);

        await supabaseAdmin.from("activity_logs").insert({
          company_id: companyId,
          action: "task_queued_by_ai_command",
          entity_type: "task",
          entity_id: taskData.id,
          metadata: { task }
        });
      }
    }

    return NextResponse.json({
      ok: true,
      response: plan.response,
      company,
      company_id: companyId,
      agents: createdAgents,
      workflows: createdWorkflows,
      tasks: createdTasks,
      queued_jobs: queuedJobs
    });
  } catch (error: any) {
    console.error(error);

    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Command failed."
      },
      { status: 500 }
    );
  }
}
API

cat > app/api/queue/route.ts <<'QUEUE'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.prompt) {
      return NextResponse.json(
        { ok: false, error: "company_id and prompt are required." },
        { status: 400 }
      );
    }

    const { data: task, error: taskError } = await supabaseAdmin
      .from("tasks")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        title: body.title || "AI Command Task",
        input: body.prompt,
        status: "queued"
      })
      .select()
      .single();

    if (taskError) throw taskError;

    const { data: job, error: jobError } = await supabaseAdmin
      .from("execution_queue")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        task_id: task.id,
        payload: {
          prompt: body.prompt,
          model: body.model || "gpt-4o-mini"
        },
        status: "pending"
      })
      .select()
      .single();

    if (jobError) throw jobError;

    return NextResponse.json({
      ok: true,
      task,
      job
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
QUEUE

cat > app/dashboard/page.tsx <<'DASH'
import Shell from "@/components/Shell";
import Card from "@/components/Card";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Dashboard() {
  const tables = [
    "companies",
    "agents",
    "swarms",
    "tasks",
    "datasets",
    "agent_runs",
    "usage_events",
    "marketplace_listings"
  ];

  const counts: any = {};

  for (const table of tables) {
    const { count } = await supabaseAdmin
      .from(table)
      .select("*", { count: "exact", head: true });

    counts[table] = count || 0;
  }

  return (
    <Shell title="Command Center">
      <div className="grid grid-cols-4 gap-6">
        <Card title="Companies" value={counts.companies} />
        <Card title="Agents" value={counts.agents} />
        <Card title="Swarms" value={counts.swarms} />
        <Card title="Tasks" value={counts.tasks} />
        <Card title="Datasets" value={counts.datasets} />
        <Card title="Agent Runs" value={counts.agent_runs} />
        <Card title="Usage Events" value={counts.usage_events} />
        <Card title="Marketplace Listings" value={counts.marketplace_listings} />
      </div>
    </Shell>
  );
}
DASH

cat > app/command/page.tsx <<'COMMAND'
import Shell from "@/components/Shell";
import CommandCenter from "@/components/CommandCenter";

export default function CommandPage() {
  return (
    <Shell
      title="AI Command Center"
      subtitle="Talk to UNIC.ai like an operating system. Ask it to build companies, agents, workflows and outputs."
    >
      <CommandCenter />
    </Shell>
  );
}
COMMAND

create_page () {
  route=$1
  title=$2
  table=$3

cat > app/$route/page.tsx <<PAGE
import Shell from "@/components/Shell";
import Card from "@/components/Card";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Page() {
  const { data, count } = await supabaseAdmin
    .from("$table")
    .select("*", { count: "exact" })
    .order("created_at", { ascending: false })
    .limit(50);

  return (
    <Shell title="$title">
      <div className="grid grid-cols-3 gap-6 mb-8">
        <Card title="Total Records" value={count || 0} />
        <Card title="Database Table" value="$table" />
        <Card title="Status" value="Live" />
      </div>

      <DataTable rows={data || []} />
    </Shell>
  );
}
PAGE
}

create_page companies Companies companies
create_page agents Agents agents
create_page swarms Swarms swarms
create_page tasks Tasks tasks
create_page datasets Datasets datasets
create_page marketplace Marketplace marketplace_listings
create_page approvals Approvals approvals
create_page activity Activity activity_logs
create_page billing Billing billing_accounts
create_page builder Builder workflow_builders
create_page usage Usage usage_events
create_page schedules Schedules schedules

cat > app/settings/page.tsx <<'SETTINGS'
import Shell from "@/components/Shell";
import Card from "@/components/Card";

export default function Settings() {
  return (
    <Shell title="Settings">
      <div className="grid grid-cols-3 gap-6">
        <Card title="Brand" value="UNIC.ai" />
        <Card title="Theme" value="Light Premium" />
        <Card title="Backend" value="Supabase" />
      </div>
    </Shell>
  );
}
SETTINGS

cat > app/pricing/page.tsx <<'PRICING'
import Link from "next/link";

export default function Pricing() {
  const plans = [
    ["Free", "$0", "Test agents and workflows."],
    ["Founder", "$29/mo", "For solo founders and early teams."],
    ["Business", "$299/mo", "For companies running AI operations."],
    ["Enterprise", "Custom", "For AI workforce infrastructure."]
  ];

  return (
    <main className="min-h-screen bg-white p-10">
      <Link href="/" className="text-3xl font-black tracking-[-0.05em]">
        UNIC<span className="text-green-500">.ai</span>
      </Link>

      <h1 className="text-6xl font-black tracking-[-0.055em] mt-16">
        Pricing built for AI operators.
      </h1>

      <div className="grid grid-cols-4 gap-6 mt-12">
        {plans.map(([name, price, text]) => (
          <div key={name} className="glass-card p-8">
            <h2 className="text-2xl font-black">{name}</h2>
            <p className="text-4xl font-black mt-4">{price}</p>
            <p className="text-gray-500 mt-4 leading-7">{text}</p>
          </div>
        ))}
      </div>
    </main>
  );
}
PRICING

cat > app/login/page.tsx <<'LOGIN'
import Link from "next/link";

export default function Login() {
  return (
    <main className="min-h-screen bg-white p-10 flex items-center justify-center">
      <div className="glass-card p-10 w-full max-w-md">
        <Link href="/" className="text-3xl font-black tracking-[-0.05em]">
          UNIC<span className="text-green-500">.ai</span>
        </Link>
        <h1 className="text-4xl font-black mt-10">Login</h1>
        <p className="text-gray-500 mt-4">
          Supabase Auth UI/API can be connected here.
        </p>
      </div>
    </main>
  );
}
LOGIN

cat > app/signup/page.tsx <<'SIGNUP'
import Link from "next/link";

export default function Signup() {
  return (
    <main className="min-h-screen bg-white p-10 flex items-center justify-center">
      <div className="glass-card p-10 w-full max-w-md">
        <Link href="/" className="text-3xl font-black tracking-[-0.05em]">
          UNIC<span className="text-green-500">.ai</span>
        </Link>
        <h1 className="text-4xl font-black mt-10">Signup</h1>
        <p className="text-gray-500 mt-4">
          Signup and company onboarding can be connected here.
        </p>
      </div>
    </main>
  );
}
SIGNUP

cat > app/legal/privacy/page.tsx <<'P'
export default function Privacy() {
  return (
    <main className="p-10 bg-white min-h-screen">
      <h1 className="text-4xl font-black">Privacy Policy</h1>
      <p className="text-gray-500 mt-4">
        UNIC.ai protects company data, agent data, datasets, workflows and runtime logs.
      </p>
    </main>
  );
}
P

cat > app/legal/refund/page.tsx <<'R'
export default function Refund() {
  return (
    <main className="p-10 bg-white min-h-screen">
      <h1 className="text-4xl font-black">Refund Policy</h1>
      <p className="text-gray-500 mt-4">
        Refunds depend on usage, billing cycle and enterprise contract terms.
      </p>
    </main>
  );
}
R

cat > app/legal/ai-policy/page.tsx <<'A'
export default function AIPolicy() {
  return (
    <main className="p-10 bg-white min-h-screen">
      <h1 className="text-4xl font-black">AI Usage Policy</h1>
      <p className="text-gray-500 mt-4">
        UNIC.ai supports safe, auditable and controllable AI agent operations.
      </p>
    </main>
  );
}
A

cat > workers/runtime-worker.js <<'WORKER'
const { createClient } = require("@supabase/supabase-js");
const OpenAI = require("openai");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const openai = process.env.OPENAI_API_KEY
  ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
  : null;

async function getAgent(agentId) {
  if (!agentId) return null;

  const { data } = await supabase
    .from("agents")
    .select("*")
    .eq("id", agentId)
    .single();

  return data;
}

async function processQueue() {
  const { data: jobs, error } = await supabase
    .from("execution_queue")
    .select("*")
    .eq("status", "pending")
    .order("created_at", { ascending: true })
    .limit(5);

  if (error) {
    console.error("Queue fetch error:", error.message);
    return;
  }

  for (const job of jobs || []) {
    let run = null;

    try {
      await supabase
        .from("execution_queue")
        .update({
          status: "running",
          attempts: (job.attempts || 0) + 1,
          locked_at: new Date().toISOString()
        })
        .eq("id", job.id);

      const agent = await getAgent(job.agent_id);

      const { data: createdRun, error: runError } = await supabase
        .from("agent_runs")
        .insert({
          company_id: job.company_id,
          agent_id: job.agent_id,
          task_id: job.task_id,
          status: "running",
          input: job.payload || {},
          started_at: new Date().toISOString()
        })
        .select()
        .single();

      if (runError) throw runError;
      run = createdRun;

      await supabase.from("runtime_events").insert({
        company_id: job.company_id,
        run_id: run.id,
        event_type: "started",
        message: "UNIC.ai worker started the command."
      });

      let output = "Command executed. OPENAI_API_KEY is not configured, so this is placeholder output.";

      if (openai && job.payload?.prompt) {
        const completion = await openai.chat.completions.create({
          model: job.payload?.model || agent?.model || "gpt-4o-mini",
          temperature: 0.4,
          messages: [
            {
              role: "system",
              content:
                agent?.system_prompt ||
                job.payload?.system_prompt ||
                "You are a UNIC.ai execution agent. Complete the user's requested work with structured, useful output."
            },
            {
              role: "user",
              content: job.payload.prompt
            }
          ]
        });

        output =
          completion.choices?.[0]?.message?.content ||
          "No output returned.";
      }

      await supabase
        .from("agent_runs")
        .update({
          status: "completed",
          output: { text: output },
          finished_at: new Date().toISOString()
        })
        .eq("id", run.id);

      if (job.task_id) {
        await supabase
          .from("tasks")
          .update({
            status: "completed",
            output,
            completed_at: new Date().toISOString()
          })
          .eq("id", job.task_id);
      }

      await supabase.from("runtime_events").insert({
        company_id: job.company_id,
        run_id: run.id,
        event_type: "completed",
        message: "UNIC.ai worker completed the command."
      });

      await supabase.from("usage_events").insert({
        company_id: job.company_id,
        event_type: "agent_run",
        quantity: 1,
        cost: 0.01,
        metadata: {
          job_id: job.id,
          run_id: run.id,
          task_id: job.task_id
        }
      });

      await supabase
        .from("execution_queue")
        .update({ status: "completed" })
        .eq("id", job.id);

      console.log("Completed job", job.id);
    } catch (err) {
      console.error("Job failed", job.id, err.message);

      if (run?.id) {
        await supabase
          .from("agent_runs")
          .update({
            status: "failed",
            error: err.message,
            finished_at: new Date().toISOString()
          })
          .eq("id", run.id);
      }

      await supabase
        .from("execution_queue")
        .update({
          status:
            (job.attempts || 0) + 1 >= (job.max_attempts || 3)
              ? "failed"
              : "pending"
        })
        .eq("id", job.id);
    }
  }
}

console.log("UNIC.ai AI Command Worker running...");
setInterval(processQueue, 10000);
WORKER

cat > scripts/digitalocean-setup.sh <<'DO'
#!/bin/bash
set -e

apt update && apt upgrade -y
apt install -y nodejs npm git curl
npm install -g pm2

npm install

pm2 start workers/runtime-worker.js --name unic-runtime-worker
pm2 save
pm2 startup

echo "UNIC.ai worker deployed on DigitalOcean."
DO

cat > scripts/vercel-env.txt <<'VERCEL'
Add these in Vercel Project Settings > Environment Variables:

NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
OPENAI_API_KEY=
NEXT_PUBLIC_APP_NAME=UNIC.ai
NEXT_PUBLIC_APP_URL=https://your-domain.com
UNIC_WORKER_SECRET=

Build settings:
Framework Preset: Next.js
Install Command: npm install
Build Command: npm run build
Output Directory: .next
VERCEL

cat > README.md <<'README'
# UNIC.ai

UNIC.ai is a light-premium AI Agent Operating System.

## Included

- Landing page
- Dashboard
- AI Command Center
- Companies
- Agents
- Swarms
- Tasks
- Builder
- Datasets
- Marketplace
- Approvals
- Usage
- Activity
- Billing
- Schedules
- Settings
- Legal pages
- Supabase admin client
- AI command planner
- Queue API
- Command API
- DigitalOcean worker
- OpenAI execution support
- Usage event tracking
- Runtime event tracking

## Commands

npm install
npm run dev
npm run build
npm run worker

## Required environment variables

NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY
OPENAI_API_KEY
NEXT_PUBLIC_APP_NAME
NEXT_PUBLIC_APP_URL
UNIC_WORKER_SECRET
README

npm install

git add .
git commit -m "Build UNIC.ai full light premium AI command platform" || true

echo "DONE: UNIC.ai full Codespaces app created."
echo "Next: run Supabase SQL, then add Vercel env vars."
