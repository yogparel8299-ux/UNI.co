import Shell from "@/components/Shell";
import Card from "@/components/Card";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function AdminAnalyticsPage() {
  const tables = ["companies", "agents", "agent_runs", "usage_events", "tool_executions", "payment_checkouts", "marketplace_orders", "notifications", "worker_health"];
  const counts: any = {};
  for (const table of tables) {
    const { count } = await supabaseAdmin.from(table).select("*", { count: "exact", head: true });
    counts[table] = count || 0;
  }
  return (
    <Shell title="Admin Analytics" subtitle="Visual platform metrics for operations, usage, marketplace and workers.">
      <div className="grid grid-cols-3 gap-6">
        {tables.map((table) => <Card key={table} title={table.replaceAll("_", " ")} value={counts[table]} />)}
      </div>
    </Shell>
  );
}
