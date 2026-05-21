import OpsShell from "@/components/ops/OpsShell";

export default function DashboardPage() {
  return (
    <OpsShell title="Overview" subtitle="Operational view of agents, workflows and live execution.">
      <div className="grid gap-4 md:grid-cols-4">
        {[
          ["Agents", "12"],
          ["Workflows", "28"],
          ["Pending approvals", "4"],
          ["Worker status", "Online"]
        ].map(([label, value]) => (
          <div key={label} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <p className="text-sm font-semibold text-neutral-500">{label}</p>
            <p className="mt-3 text-3xl font-black tracking-[-0.04em]">{value}</p>
          </div>
        ))}
      </div>

      <div className="mt-5 grid gap-5 lg:grid-cols-[1.4fr_.6fr]">
        <div className="rounded-2xl border border-neutral-200 bg-white p-5">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-black">Recent executions</h2>
            <button className="rounded-lg border border-neutral-200 px-3 py-2 text-sm font-bold">View all</button>
          </div>
          <div className="mt-5 space-y-2">
            {["Research workflow completed", "Gmail draft created", "Dataset indexed", "Approval requested"].map((x) => (
              <div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4">
                <span className="font-semibold">{x}</span>
                <span className="text-sm text-neutral-500">live</span>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-2xl border border-neutral-200 bg-white p-5">
          <h2 className="text-xl font-black">Quick start</h2>
          <div className="mt-5 grid gap-2">
            {["Create agent", "Add skill", "Build workflow", "Connect Gmail"].map((x) => (
              <button key={x} className="rounded-xl bg-neutral-100 p-4 text-left text-sm font-bold">{x}</button>
            ))}
          </div>
        </div>
      </div>
    </OpsShell>
  );
}
