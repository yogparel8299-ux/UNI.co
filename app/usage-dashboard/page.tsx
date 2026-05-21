import Shell from "@/components/Shell";
import Card from "@/components/Card";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function UsageDashboard() {
  const tables = ["usage_events", "credit_ledger", "agent_runs", "tool_executions"];
  const counts: any = {};

  for (const table of tables) {
    const { count } = await supabaseAdmin.from(table).select("*", { count: "exact", head: true });
    counts[table] = count || 0;
  }

  return (
    <Shell title="Usage Dashboard" subtitle="Credits, runs, tool executions and cost control.">
      <div className="grid grid-cols-4 gap-6">
        <Card title="Usage Events" value={counts.usage_events} />
        <Card title="Credit Ledger" value={counts.credit_ledger} />
        <Card title="Agent Runs" value={counts.agent_runs} />
        <Card title="Tool Executions" value={counts.tool_executions} />
      </div>
    </Shell>
  );
}
