import AppShell from "@/components/layout/AppShell";
import StatCard from "@/components/ui/StatCard";

export default function DashboardPage() {
  return (
    <AppShell
      title="Dashboard"
      subtitle="Manage AI operations, connected tools and execution activity."
    >
      <div className="grid grid-cols-1 gap-5 md:grid-cols-4">
        <StatCard
          title="Agents"
          value="12"
          subtitle="Connected AI workers"
        />

        <StatCard
          title="Workflows"
          value="28"
          subtitle="Automation pipelines"
        />

        <StatCard
          title="Connectors"
          value="9"
          subtitle="Integrated business tools"
        />

        <StatCard
          title="Executions"
          value="Live"
          subtitle="Realtime worker activity"
        />
      </div>

      <div className="mt-7 grid grid-cols-1 gap-6 lg:grid-cols-[1.2fr_.8fr]">
        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <h2 className="text-4xl font-black tracking-[-0.05em]">
            Workspace activity
          </h2>

          <div className="mt-8 space-y-4">
            {[
              "Agent connected to Slack",
              "Workflow execution completed",
              "Dataset uploaded to memory",
              "Approval request submitted",
              "Connector synchronized"
            ].map((x) => (
              <div
                key={x}
                className="flex items-center justify-between rounded-2xl border border-slate-200 p-5"
              >
                <span className="font-semibold text-slate-700">
                  {x}
                </span>

                <span className="text-xs font-bold text-slate-400">
                  just now
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <h2 className="text-3xl font-black tracking-[-0.05em]">
            Quick actions
          </h2>

          <div className="mt-7 grid gap-4">
            {[
              "Create Agent",
              "Add Skill",
              "Connect Tool",
              "Create Workflow",
              "Upload Dataset"
            ].map((x) => (
              <button
                key={x}
                className="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-5 text-left text-sm font-bold text-slate-700 hover:bg-slate-100"
              >
                {x}
              </button>
            ))}
          </div>
        </div>
      </div>
    </AppShell>
  );
}
