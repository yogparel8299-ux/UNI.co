import Shell from "@/components/Shell";
import SkillAssignmentPanel from "@/components/skills/SkillAssignmentPanel";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function AgentSkillsPage({
  params,
  searchParams
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ company_id?: string }>;
}) {
  const resolvedParams = await params;
  const resolvedSearch = await searchParams;

  const agentId = resolvedParams.id;
  const companyId = resolvedSearch.company_id || "";

  const { data: publicSkills } = await supabaseAdmin
    .from("skill_library")
    .select("*")
    .eq("active", true)
    .eq("is_public", true)
    .order("category", { ascending: true });

  const { data: companySkills } = companyId
    ? await supabaseAdmin
        .from("company_skills")
        .select("*")
        .eq("company_id", companyId)
        .eq("active", true)
        .order("created_at", { ascending: false })
    : { data: [] as any[] };

  const { data: assignedSkills } = companyId
    ? await supabaseAdmin
        .from("agent_skill_assignments")
        .select("*, skill_library(*), company_skills(*)")
        .eq("company_id", companyId)
        .eq("agent_id", agentId)
        .eq("enabled", true)
        .order("priority", { ascending: true })
    : { data: [] as any[] };

  return (
    <Shell
      title="Agent Skills"
      subtitle="Add reusable skills to this agent. Use ?company_id=YOUR_COMPANY_ID in the URL."
    >
      {!companyId && (
        <div className="glass-card p-6 mb-8 text-gray-500">
          Add company_id in the URL to assign skills:
          <br />
          /agents/{agentId}/skills?company_id=YOUR_COMPANY_ID
        </div>
      )}

      <SkillAssignmentPanel
        companyId={companyId}
        agentId={agentId}
        publicSkills={publicSkills || []}
        companySkills={companySkills || []}
        assignedSkills={assignedSkills || []}
      />
    </Shell>
  );
}
