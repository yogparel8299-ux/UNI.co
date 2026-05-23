import { AppShell, Panel, Stat } from "@/components/unic/UNICShell";

export default function Page() {
  return (
    <AppShell title="Knowledge Ingestion OS" eyebrow="Datasets">
      <div className="grid gap-5 md:grid-cols-3">
        <Stat label="Active" value="12" />
        <Stat label="Queued" value="34" tone="violet" />
        <Stat label="Health" value="99%" tone="emerald" />
      </div>
      <div className="mt-5 grid gap-5 lg:grid-cols-[1fr_.8fr]">
        <Panel className="min-h-[420px]">
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#2fd9f4]">Operational Surface</p>
          <h2 className="mt-4 text-4xl font-black tracking-[-0.05em]">Knowledge Ingestion OS</h2>
          <p className="mt-4 max-w-2xl text-[#c6c6cb]">This module is wired into the UNIC.ai operating workspace and ready for Supabase-backed records, runtime states, and production actions.</p>
          <div className="mt-8 space-y-3">
            {["Runtime connected", "Supabase ready", "Actions enabled", "Audit trail active"].map((x) => (
              <div key={x} className="flex justify-between border-b border-[#45474b]/20 py-3 font-mono text-sm">
                <span>{x}</span>
                <span className="text-[#2fd9f4]">ONLINE</span>
              </div>
            ))}
          </div>
        </Panel>
        <Panel>
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#c0c1ff]">Actions</p>
          <div className="mt-5 grid gap-3">
            {["Create", "Sync", "Review", "Export"].map((x) => (
              <button key={x} className="rounded border border-[#45474b]/40 bg-[#000f21] px-4 py-3 text-left font-mono text-xs uppercase tracking-[0.12em] hover:border-[#2fd9f4]/60 hover:text-[#2fd9f4]">{x}</button>
            ))}
          </div>
        </Panel>
      </div>
    </AppShell>
  );
}
