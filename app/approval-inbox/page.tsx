import AppShell from "@/components/layout/AppShell";

export default function Page() {
  return (
    <AppShell
      title="approval inbox"
      subtitle="UNIC.ai workspace module"
    >
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <div className="mb-7 h-32 rounded-[24px] bg-gradient-to-br from-[#eef4ff] via-white to-[#ecfeff]" />

          <h2 className="text-3xl font-black tracking-[-0.05em] capitalize">
            approval inbox
          </h2>

          <p className="mt-4 text-slate-500 leading-8">
            Manage and monitor this workspace module from one unified operating layer.
          </p>

          <button className="mt-8 rounded-full bg-[#111827] px-6 py-4 text-sm font-bold text-white">
            Open Module
          </button>
        </div>

        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <h2 className="text-3xl font-black tracking-[-0.05em]">
            Activity
          </h2>

          <div className="mt-7 space-y-4">
            {[
              "Workspace updated",
              "Execution completed",
              "Connector synchronized",
              "Approval reviewed",
              "Memory indexed"
            ].map((x) => (
              <div
                key={x}
                className="rounded-2xl border border-slate-200 p-5"
              >
                <p className="font-semibold text-slate-700">
                  {x}
                </p>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
          <h2 className="text-3xl font-black tracking-[-0.05em]">
            Quick Actions
          </h2>

          <div className="mt-7 grid gap-4">
            {[
              "Create",
              "Configure",
              "Connect",
              "Monitor",
              "Manage"
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
