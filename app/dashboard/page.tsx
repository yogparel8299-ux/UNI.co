import AppShell from "@/components/layout/AppShell";

export default function DashboardPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[40px] bg-slate-950 p-10 text-white shadow-2xl">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-300">Command Center</p>
          <h1 className="mt-5 max-w-4xl text-6xl font-black tracking-[-0.07em]">Operate your AI company from one place.</h1>
          <p className="mt-6 max-w-2xl text-white/60 leading-8">Monitor agents, workflows, approvals, connectors, memory and background execution.</p>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-4">
          {[
            ["Agents", "12", "AI workers ready"],
            ["Workflows", "28", "Execution pipelines"],
            ["Approvals", "4", "Waiting review"],
            ["Workers", "Online", "Background tasks active"]
          ].map(([a,b,c]) => (
            <div key={a} className="rounded-[30px] border border-slate-200 bg-white p-7 shadow-sm">
              <p className="text-sm font-bold text-slate-500">{a}</p>
              <p className="mt-3 text-4xl font-black tracking-[-0.06em]">{b}</p>
              <p className="mt-2 text-sm text-slate-500">{c}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 grid gap-6 lg:grid-cols-[1.3fr_.7fr]">
          <div className="rounded-[32px] border border-slate-200 bg-white p-8">
            <h2 className="text-4xl font-black tracking-[-0.05em]">Live execution stream</h2>
            <div className="mt-7 space-y-4">
              {["Dataset indexed", "Research agent completed brief", "Approval requested for email send", "Workflow run finished"].map((x) => (
                <div key={x} className="flex justify-between rounded-2xl border border-slate-200 p-5">
                  <span className="font-bold text-slate-700">{x}</span>
                  <span className="text-sm text-slate-400">now</span>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-[32px] border border-slate-200 bg-white p-8">
            <h2 className="text-3xl font-black tracking-[-0.05em]">Next actions</h2>
            <div className="mt-7 grid gap-3">
              {["Create agent", "Connect Gmail", "Upload dataset", "Run workflow"].map((x) => (
                <button key={x} className="rounded-2xl bg-slate-100 p-4 text-left font-bold">{x}</button>
              ))}
            </div>
          </div>
        </div>
      </section>
    </AppShell>
  );
}
