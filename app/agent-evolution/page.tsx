import OpsShell from "@/components/ops/OpsShell";

export default function AgentEvolutionPage() {
  return (
    <OpsShell
      title="Agent Evolution"
      subtitle="Review agent performance and approve self-improvement suggestions."
      rightPanel={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-neutral-400">Policy</p>
          <h2 className="mt-3 text-xl font-black">Evolution Guardrails</h2>
          <div className="mt-5 space-y-3 text-sm text-neutral-600">
            <p>Agents can suggest prompt, skill and workflow improvements.</p>
            <p>Self-updates require approval before being applied.</p>
            <p>Every improvement creates a version snapshot.</p>
          </div>
        </div>
      }
    >
      <div className="grid gap-4">
        {[
          ["Research Analyst", "Improve source-ranking logic", "Pending approval"],
          ["Support Operator", "Add escalation rule for refunds", "Pending approval"],
          ["Sales Builder", "Rewrite outreach tone based on response data", "Suggested"]
        ].map(([agent, change, status]) => (
          <div key={agent} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-black">{agent}</h2>
                <p className="mt-2 text-neutral-500">{change}</p>
              </div>
              <span className="rounded-full bg-neutral-100 px-3 py-1 text-xs font-bold">{status}</span>
            </div>
            <div className="mt-5 flex gap-2">
              <button className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">Approve</button>
              <button className="rounded-lg border border-neutral-200 px-4 py-2 text-sm font-bold">Reject</button>
            </div>
          </div>
        ))}
      </div>
    </OpsShell>
  );
}
