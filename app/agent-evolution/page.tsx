import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";

export default async function AgentEvolutionPage() {
  const { supabase, user, companyId } = await getWorkspace();

  const { data: suggestions } = user && companyId
    ? await supabase.from("agent_evolution_suggestions").select("*, agents(name)").eq("company_id", companyId).order("created_at", { ascending: false })
    : { data: [] };

  return (
    <AppShell title="Agent Evolution" subtitle="Agent improvements require human approval.">
      <div className="space-y-4">
        {(suggestions || []).map((s: any) => (
          <div key={s.id} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <div className="flex justify-between gap-4">
              <div>
                <p className="text-xs font-black uppercase text-blue-600">{s.suggestion_type}</p>
                <h2 className="mt-2 text-2xl font-black">{s.title}</h2>
                <p className="mt-2 text-sm text-neutral-500">{s.description}</p>
              </div>
              <span className="h-fit rounded-full bg-neutral-100 px-3 py-1 text-xs font-black">{s.status}</span>
            </div>
          </div>
        ))}

        {(!suggestions || suggestions.length === 0) && (
          <div className="rounded-2xl border border-neutral-200 bg-white p-10 text-center">
            <h2 className="text-3xl font-black">No evolution suggestions yet</h2>
            <p className="mt-3 text-neutral-500">Agents will suggest improvements after execution history exists.</p>
          </div>
        )}
      </div>
    </AppShell>
  );
}
