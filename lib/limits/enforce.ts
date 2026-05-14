import { supabaseAdmin } from "@/lib/supabase-admin";

export async function enforceCompanyLimit(companyId: string, limitType: "agents" | "workflows" | "datasets" | "runs") {
  const { data: billing } = await supabaseAdmin
    .from("billing_accounts")
    .select("*")
    .eq("company_id", companyId)
    .single();

  const plan = billing?.plan || "starter";

  const { data: limits } = await supabaseAdmin
    .from("plan_limits")
    .select("*")
    .eq("plan_slug", plan)
    .single();

  if (!limits) return { allowed: true };

  const tableMap: any = {
    agents: "agents",
    workflows: "workflow_builders",
    datasets: "datasets",
    runs: "agent_runs"
  };

  const columnMap: any = {
    agents: "max_agents",
    workflows: "max_workflows",
    datasets: "max_datasets",
    runs: "max_monthly_runs"
  };

  const { count } = await supabaseAdmin
    .from(tableMap[limitType])
    .select("*", { count: "exact", head: true })
    .eq("company_id", companyId);

  const max = Number(limits[columnMap[limitType]] || 0);

  return {
    allowed: Number(count || 0) < max,
    used: count || 0,
    max,
    plan
  };
}
