import AppShell from "@/components/layout/AppShell";

export default function RealtimeDashboardPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[36px] bg-slate-950 p-10 text-white">
          <h1 className="text-6xl font-black tracking-[-0.07em]">Realtime Operations</h1>
          <p className="mt-5 max-w-2xl text-white/60 leading-8">Live execution events, workers, connector syncs and workflow activity.</p>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {["Worker status", "Execution stream", "Connector sync"].map((x) => (
            <div key={x} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{x}</h2>
              <div className="mt-8 h-40 rounded-[24px] bg-gradient-to-t from-blue-100 to-white" />
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
