#!/bin/bash
set -e

echo "Adding auth-aware dashboard: demo data for visitors, real data for logged-in users..."

cat > app/dashboard/page.tsx <<'TSX'
import Link from "next/link";
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

const demoStats = {
  agents: 12,
  workflows: 28,
  datasets: 9,
  approvals: 4,
  executions: 1842,
  connectors: 7
};

async function getSupabaseServer() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "",
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll() {}
      }
    }
  );
}

async function getRealDashboardData() {
  const supabase = await getSupabaseServer();

  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      loggedIn: false,
      user: null,
      company: null,
      stats: demoStats
    };
  }

  const { data: member } = await supabase
    .from("company_members")
    .select("company_id, companies(*)")
    .eq("user_id", user.id)
    .limit(1)
    .maybeSingle();

  const companyId = member?.company_id;

  if (!companyId) {
    return {
      loggedIn: true,
      user,
      company: null,
      stats: {
        agents: 0,
        workflows: 0,
        datasets: 0,
        approvals: 0,
        executions: 0,
        connectors: 0
      }
    };
  }

  const [
    agents,
    workflows,
    datasets,
    approvals,
    executions,
    connectors
  ] = await Promise.all([
    supabase.from("agents").select("*", { count: "exact", head: true }).eq("company_id", companyId),
    supabase.from("workflow_builders").select("*", { count: "exact", head: true }).eq("company_id", companyId),
    supabase.from("datasets").select("*", { count: "exact", head: true }).eq("company_id", companyId),
    supabase.from("human_approval_inbox").select("*", { count: "exact", head: true }).eq("company_id", companyId).eq("status", "pending"),
    supabase.from("agent_runs").select("*", { count: "exact", head: true }).eq("company_id", companyId),
    supabase.from("connector_sessions").select("*", { count: "exact", head: true }).eq("company_id", companyId)
  ]);

  return {
    loggedIn: true,
    user,
    company: member?.companies || null,
    stats: {
      agents: agents.count || 0,
      workflows: workflows.count || 0,
      datasets: datasets.count || 0,
      approvals: approvals.count || 0,
      executions: executions.count || 0,
      connectors: connectors.count || 0
    }
  };
}

export default async function DashboardPage() {
  const data = await getRealDashboardData();
  const stats = data.stats;

  return (
    <main className="min-h-screen bg-[#f6f8fb] text-slate-950">
      <section className="mx-auto max-w-7xl px-6 py-10">
        <nav className="mb-10 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-full bg-slate-950 text-white font-black">
              U
            </div>
            <div>
              <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-slate-500">
                {data.loggedIn ? "Workspace dashboard" : "Demo dashboard"}
              </p>
            </div>
          </Link>

          <div className="flex gap-3">
            {!data.loggedIn ? (
              <>
                <Link href="/login" className="rounded-full border border-slate-200 bg-white px-5 py-3 text-sm font-bold">
                  Login
                </Link>
                <Link href="/signup" className="rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">
                  Create account
                </Link>
              </>
            ) : (
              <Link href="/settings" className="rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">
                Settings
              </Link>
            )}
          </div>
        </nav>

        {!data.loggedIn && (
          <div className="mb-8 rounded-[28px] border border-blue-200 bg-blue-50 p-6">
            <p className="font-black text-blue-700">Demo Mode</p>
            <p className="mt-2 text-slate-600">
              You are viewing sample workspace data. Create an account or login to see your real agents, workflows, datasets, approvals and executions.
            </p>
          </div>
        )}

        {data.loggedIn && !data.company && (
          <div className="mb-8 rounded-[28px] border border-amber-200 bg-amber-50 p-6">
            <p className="font-black text-amber-700">Workspace setup needed</p>
            <p className="mt-2 text-slate-600">
              Your account exists, but no company workspace is attached yet. Continue onboarding to create your company.
            </p>
            <Link href="/onboarding" className="mt-4 inline-flex rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">
              Continue onboarding
            </Link>
          </div>
        )}

        <div className="rounded-[40px] bg-slate-950 p-10 text-white shadow-2xl">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-300">
            {data.loggedIn ? "Live Workspace" : "Product Preview"}
          </p>
          <h1 className="mt-5 max-w-4xl text-6xl font-black tracking-[-0.07em]">
            {data.loggedIn
              ? "Your AI company command center."
              : "See how an AI company operates."}
          </h1>
          <p className="mt-6 max-w-2xl text-white/60 leading-8">
            {data.loggedIn
              ? "Real-time view of your agents, workflows, approvals, datasets, connectors and background execution."
              : "This demo shows the operating layer users get after they create their workspace."}
          </p>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-3 lg:grid-cols-6">
          {[
            ["Agents", stats.agents],
            ["Workflows", stats.workflows],
            ["Datasets", stats.datasets],
            ["Approvals", stats.approvals],
            ["Executions", stats.executions],
            ["Connectors", stats.connectors]
          ].map(([label, value]) => (
            <div key={label} className="rounded-[28px] border border-slate-200 bg-white p-6 shadow-sm">
              <p className="text-sm font-bold text-slate-500">{label}</p>
              <p className="mt-3 text-4xl font-black tracking-[-0.06em]">{value}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 grid gap-6 lg:grid-cols-[1.2fr_.8fr]">
          <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-sm">
            <h2 className="text-4xl font-black tracking-[-0.05em]">
              {data.loggedIn ? "Workspace activity" : "Example activity"}
            </h2>

            <div className="mt-7 space-y-4">
              {(data.loggedIn
                ? [
                    "Agent run completed",
                    "Workflow execution updated",
                    "Dataset indexed",
                    "Connector sync finished"
                  ]
                : [
                    "Research agent generated a market brief",
                    "Support workflow drafted customer replies",
                    "Dataset memory updated",
                    "Approval requested for external action"
                  ]
              ).map((x) => (
                <div key={x} className="flex justify-between rounded-2xl border border-slate-200 p-5">
                  <span className="font-bold text-slate-700">{x}</span>
                  <span className="text-sm text-slate-400">{data.loggedIn ? "live" : "demo"}</span>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-sm">
            <h2 className="text-3xl font-black tracking-[-0.05em]">
              Quick actions
            </h2>

            <div className="mt-7 grid gap-3">
              {[
                ["Create agent", "/agents"],
                ["Add skills", "/skills"],
                ["Connect tools", "/connection-layer"],
                ["Upload dataset", "/datasets"],
                ["Build workflow", "/workflow-studio"]
              ].map(([label, href]) => (
                <Link key={href} href={href} className="rounded-2xl bg-slate-100 p-4 text-left font-bold text-slate-700">
                  {label}
                </Link>
              ))}
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
TSX

npm run build
git add app/dashboard/page.tsx
git commit -m "Make dashboard auth-aware with demo and real data" || true
git push origin main
