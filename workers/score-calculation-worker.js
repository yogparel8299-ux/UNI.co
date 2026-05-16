const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function calculate() {
  const { data: companies } = await supabase
    .from("companies")
    .select("id");

  for (const company of companies || []) {
    const score = Math.floor(Math.random() * 100);

    await supabase
      .from("workspace_health_scores")
      .upsert({
        company_id: company.id,
        health_score: score,
        agent_score: score - 5,
        workflow_score: score - 10,
        billing_score: score - 8,
        connector_score: score - 7,
        memory_score: score - 6
      });

    await supabase
      .from("realtime_dashboard_metrics")
      .insert([
        {
          company_id: company.id,
          metric_key: "active_agents",
          metric_value: Math.floor(Math.random() * 50)
        },
        {
          company_id: company.id,
          metric_key: "running_workflows",
          metric_value: Math.floor(Math.random() * 25)
        },
        {
          company_id: company.id,
          metric_key: "runtime_executions",
          metric_value: Math.floor(Math.random() * 1000)
        }
      ]);
  }
}

setInterval(calculate, 1000 * 60 * 5);

calculate();
