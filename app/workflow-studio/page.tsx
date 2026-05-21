import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";

export default async function WorkflowStudioPage() {
  const { supabase, user, companyId } = await getWorkspace();

  if (!user) {
    return (
      <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6">
        <div className="rounded-3xl border border-neutral-200 bg-white p-10 text-center">
          <h1 className="text-4xl font-black">Login required</h1>
          <p className="mt-3 text-neutral-500">Login to access Workflow Studio.</p>
        </div>
      </main>
    );
  }

  const { data: workflows } = companyId
    ? await supabase.from("workflow_graphs").select("*").eq("company_id", companyId).order("updated_at", { ascending: false }).limit(10)
    : { data: [] };

  return (
    <AppShell
      title="Workflow Studio"
      subtitle="Save and load workflow graphs from Supabase."
      right={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[.16em] text-neutral-400">Graph Save</p>
          <h2 className="mt-3 text-xl font-black">Persistence enabled</h2>
          <p className="mt-4 text-sm leading-6 text-neutral-500">
            Workflow graph JSON is saved into workflow_graphs.
          </p>
          <p className="mt-4 text-xs text-neutral-400 break-all">
            company_id: {companyId || "missing workspace"}
          </p>
        </div>
      }
    >
      <div className="mb-5 grid gap-5 lg:grid-cols-[.75fr_1.25fr]">
        <div className="rounded-2xl border border-neutral-200 bg-white p-5">
          <h2 className="text-2xl font-black">Saved Graphs</h2>
          <div className="mt-5 space-y-3">
            {(workflows || []).map((wf: any) => (
              <div key={wf.id} className="rounded-xl border border-neutral-200 p-4">
                <p className="font-black">{wf.title}</p>
                <p className="mt-1 text-xs text-neutral-500">{wf.status}</p>
              </div>
            ))}
            {(!workflows || workflows.length === 0) && (
              <p className="text-sm text-neutral-500">No saved workflow graphs yet.</p>
            )}
          </div>
        </div>

        <div className="relative h-[680px] overflow-hidden rounded-2xl border border-neutral-200 bg-white">
          <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />
          <svg className="absolute inset-0 h-full w-full">
            <path d="M250 170 C330 170 310 235 365 235" fill="none" stroke="#111" strokeWidth="2" />
            <path d="M570 235 C640 235 600 150 665 150" fill="none" stroke="#111" strokeWidth="2" />
            <path d="M570 235 C640 235 600 385 665 385" fill="none" stroke="#111" strokeWidth="2" />
          </svg>
          {[
            ["Trigger", "Command", "left-[70px] top-[120px]"],
            ["Agent", "AI Worker", "left-[365px] top-[190px]"],
            ["Memory", "Company Brain", "left-[665px] top-[95px]"],
            ["Approval", "Human Review", "left-[665px] top-[330px]"]
          ].map(([type,label,pos]) => (
            <div key={label} className={`absolute ${pos} w-[190px] rounded-xl border border-neutral-300 bg-white p-4 shadow-lg`}>
              <p className="text-[11px] font-black uppercase tracking-[.14em] text-neutral-400">{type}</p>
              <h3 className="mt-2 font-black">{label}</h3>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
