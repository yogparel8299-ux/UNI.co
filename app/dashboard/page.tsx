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
