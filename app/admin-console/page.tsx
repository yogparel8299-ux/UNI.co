import Shell from "@/components/Shell";
import Card from "@/components/Card";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function AdminConsolePage() {
  const tables = [
    "companies",
    "agents",
    "agent_runs",
    "tool_executions",
    "marketplace_orders",
    "payment_checkouts",
    "audit_events",
    "worker_health"
  ];

  const counts: any = {};

  for (const table of tables) {
    const { count } = await supabaseAdmin
      .from(table)
      .select("*", {
        count: "exact",
        head: true
      });

    counts[table] = count || 0;
  }

  return (
    <Shell
      title="Admin Console"
      subtitle="System-wide command center for platform health, usage and governance."
    >
      <div className="grid grid-cols-4 gap-6">
        <Card title="Companies" value={counts.companies} />
        <Card title="Agents" value={counts.agents} />
        <Card title="Agent Runs" value={counts.agent_runs} />
        <Card title="Tool Executions" value={counts.tool_executions} />
        <Card title="Orders" value={counts.marketplace_orders} />
        <Card title="Payments" value={counts.payment_checkouts} />
        <Card title="Audit Events" value={counts.audit_events} />
        <Card title="Workers" value={counts.worker_health} />
      </div>
    </Shell>
  );
}
