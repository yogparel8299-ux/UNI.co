import { supabaseAdmin } from "@/lib/supabase-admin";
import { runRealModel } from "@/lib/models/real-router";

export async function runAgentSkill({
  companyId,
  agentId,
  skillAssignmentId,
  input
}: {
  companyId: string;
  agentId: string;
  skillAssignmentId: string;
  input: any;
}) {
  const { data: assignment, error: assignmentError } = await supabaseAdmin
    .from("agent_skill_assignments")
    .select("*, skill_library(*), company_skills(*)")
    .eq("id", skillAssignmentId)
    .eq("company_id", companyId)
    .eq("agent_id", agentId)
    .eq("enabled", true)
    .single();

  if (assignmentError) throw assignmentError;

  const skill = assignment.company_skills || assignment.skill_library;

  if (!skill) {
    throw new Error("Skill not found.");
  }

  const { data: run, error: runError } = await supabaseAdmin
    .from("skill_runs")
    .insert({
      company_id: companyId,
      agent_id: agentId,
      skill_assignment_id: skillAssignmentId,
      input,
      status: "running"
    })
    .select()
    .single();

  if (runError) throw runError;

  try {
    const result = await runRealModel({
      companyId,
      provider: input.provider || "openai",
      model: input.model || skill.default_model || skill.model || "gpt-4o-mini",
      systemPrompt: skill.system_prompt,
      prompt: input.prompt || JSON.stringify(input)
    });

    await supabaseAdmin
      .from("skill_runs")
      .update({
        output: result,
        status: "completed",
        completed_at: new Date().toISOString()
      })
      .eq("id", run.id);

    await supabaseAdmin.from("runtime_events").insert({
      company_id: companyId,
      run_id: null,
      event_type: "skill_completed",
      message: `${skill.title} skill completed.`,
      metadata: {
        skill_run_id: run.id,
        agent_id: agentId,
        skill_assignment_id: skillAssignmentId
      }
    });

    return {
      run_id: run.id,
      result
    };
  } catch (error: any) {
    await supabaseAdmin
      .from("skill_runs")
      .update({
        status: "failed",
        error: error.message,
        completed_at: new Date().toISOString()
      })
      .eq("id", run.id);

    throw error;
  }
}
