import { supabaseAdmin } from "@/lib/supabase-admin";

export async function runSwarm(companyId: string, swarmId: string, prompt: string) {
  const { data: members } = await supabaseAdmin
    .from("swarm_agents")
    .select("*, agents(*)")
    .eq("swarm_id", swarmId);

  const queued = [];

  for (const member of members || []) {
    const agent = member.agents;
    if (!agent) continue;

    await supabaseAdmin.from("swarm_messages").insert({
      company_id: companyId,
      swarm_id: swarmId,
      to_agent_id: agent.id,
      message: prompt,
      metadata: { role: member.role }
    });

    const { data: job } = await supabaseAdmin
      .from("execution_queue")
      .insert({
        company_id: companyId,
        agent_id: agent.id,
        swarm_id: swarmId,
        payload: {
          prompt,
          swarm_id: swarmId,
          swarm_role: member.role
        },
        status: "pending"
      })
      .select()
      .single();

    if (job) queued.push(job);
  }

  return queued;
}
