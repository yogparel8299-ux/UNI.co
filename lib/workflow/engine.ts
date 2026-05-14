import { supabaseAdmin } from "@/lib/supabase-admin";

export async function startWorkflowRun(companyId: string, workflowId: string, input: any) {
  const { data: workflow, error } = await supabaseAdmin
    .from("workflow_builders")
    .select("*")
    .eq("id", workflowId)
    .single();

  if (error) throw error;

  const { data: run, error: runError } = await supabaseAdmin
    .from("workflow_runs")
    .insert({
      company_id: companyId,
      workflow_id: workflowId,
      status: "running",
      input,
      current_node: workflow.graph?.nodes?.[0]?.id || null
    })
    .select()
    .single();

  if (runError) throw runError;

  for (const node of workflow.graph?.nodes || []) {
    if (node.type === "agent" && node.agent_id) {
      await supabaseAdmin.from("execution_queue").insert({
        company_id: companyId,
        agent_id: node.agent_id,
        payload: {
          prompt: input.prompt || JSON.stringify(input),
          workflow_run_id: run.id,
          node_id: node.id
        },
        status: "pending"
      });
    }
  }

  return run;
}
