import AppShell from "@/components/layout/AppShell";

export default function WorkflowStudioPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="grid gap-6 lg:grid-cols-[.8fr_1.2fr]">
          <div className="rounded-[36px] bg-white p-8 shadow-sm">
            <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-600">Builder</p>
            <h1 className="mt-4 text-5xl font-black tracking-[-0.07em]">Workflow Studio</h1>
            <p className="mt-5 text-slate-500 leading-8">Design task chains, approvals, model calls, memory lookups and tool actions.</p>
            <button className="mt-8 rounded-full bg-slate-950 px-7 py-4 font-bold text-white">New Workflow</button>
          </div>

          <div className="relative min-h-[560px] rounded-[36px] border border-slate-200 bg-white p-8 shadow-sm">
            <svg className="absolute inset-0 h-full w-full">
              <line x1="150" y1="150" x2="420" y2="240" stroke="#2563eb" strokeWidth="3" strokeDasharray="8 8" />
              <line x1="420" y1="240" x2="680" y2="150" stroke="#10b981" strokeWidth="3" strokeDasharray="8 8" />
            </svg>
            {[
              ["Trigger", "User command", 60, 90],
              ["Agent", "Research worker", 330, 180],
              ["Tool", "Gmail draft", 610, 90],
              ["Approval", "Human review", 330, 360]
            ].map(([a,b,x,y]) => (
              <div key={a} style={{left:x as number, top:y as number}} className="absolute w-56 rounded-[28px] border border-slate-200 bg-white p-5 shadow-xl">
                <p className="text-xs font-black uppercase tracking-[0.16em] text-blue-600">{a}</p>
                <h3 className="mt-2 text-xl font-black">{b}</h3>
              </div>
            ))}
          </div>
        </div>
      </section>
    </AppShell>
  );
}
