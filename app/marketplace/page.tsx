import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";

const demoAssets = [
  ["AI Sales Team", "agent_pack"],
  ["Support Desk", "workflow_pack"],
  ["Research OS", "company_template"],
  ["Content Factory", "workflow_pack"],
  ["Finance Analyst", "agent_pack"],
  ["Hiring Pipeline", "workflow_pack"]
];

export default async function MarketplacePage() {
  const { supabase, user, companyId } = await getWorkspace();

  const { data: installs } = user && companyId
    ? await supabase.from("marketplace_installs").select("*").eq("company_id", companyId).order("created_at", { ascending: false })
    : { data: [] };

  return (
    <AppShell title="Marketplace" subtitle="Install agents, workflows and company systems.">
      <div className="grid gap-4 md:grid-cols-3">
        {demoAssets.map(([title, type]) => (
          <div key={title} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <div className="mb-5 h-28 rounded-2xl bg-gradient-to-br from-blue-50 to-purple-50" />
            <h2 className="text-2xl font-black">{title}</h2>
            <p className="mt-2 text-sm text-neutral-500">{type}</p>
            <button className="mt-5 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">
              Install
            </button>
          </div>
        ))}
      </div>

      <div className="mt-8 rounded-2xl border border-neutral-200 bg-white p-6">
        <h2 className="text-2xl font-black">Installed Assets</h2>
        <div className="mt-4 space-y-3">
          {(installs || []).map((x: any) => (
            <div key={x.id} className="rounded-xl border border-neutral-200 p-4">
              <p className="font-black">{x.asset_title}</p>
              <p className="text-sm text-neutral-500">{x.asset_type}</p>
            </div>
          ))}
          {(!installs || installs.length === 0) && <p className="text-sm text-neutral-500">No marketplace installs yet.</p>}
        </div>
      </div>
    </AppShell>
  );
}
