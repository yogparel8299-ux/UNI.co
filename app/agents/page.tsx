import OpsShell from "@/components/ops/OpsShell";

export default function AgentsPage() {
  return (
    <OpsShell
      title="Agents"
      subtitle="Persistent AI workers with skills, tools, memory, budgets and version history."
      rightPanel={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-neutral-400">Agent Config</p>
          <h2 className="mt-3 text-xl font-black">Create Agent</h2>
          <div className="mt-5 space-y-4">
            <input className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Agent name" />
            <input className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Role" />
            <textarea className="min-h-[120px] w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="System instructions" />
            <button className="w-full rounded-lg bg-black px-4 py-3 text-sm font-bold text-white">Create Agent</button>
          </div>
        </div>
      }
    >
      <div className="grid gap-4 md:grid-cols-3">
        {["Research Analyst", "Sales Operator", "Support Agent", "Finance Reviewer", "Ops Manager", "Content Strategist"].map((agent) => (
          <div key={agent} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <div className="mb-5 h-20 rounded-xl bg-neutral-100" />
            <h2 className="text-xl font-black">{agent}</h2>
            <p className="mt-2 text-sm text-neutral-500">Active AI worker with skills, memory and tool access.</p>
            <div className="mt-5 flex gap-2">
              <button className="rounded-lg bg-black px-3 py-2 text-xs font-bold text-white">Open</button>
              <button className="rounded-lg border border-neutral-200 px-3 py-2 text-xs font-bold">Skills</button>
            </div>
          </div>
        ))}
      </div>
    </OpsShell>
  );
}
