import AppShell, { Card, Metric } from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="Approvals" eyebrow="Human control">
      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Metric label="Active" value="42" />
        <Metric label="Synced" value="98%" />
        <Metric label="Queued" value="12" />
        <Metric label="Runtime" value="Live" />
      </div>

      <section className="mt-3 grid gap-3 xl:grid-cols-[1.2fr_.8fr]">
        <Card className="min-h-[420px]">
          <p className="mb-3 text-[11.5px] font-medium text-blue-500">Human control</p>
          <h2 className="max-w-md text-[1.75rem] font-medium leading-[1.15] tracking-tight text-gray-900">Approvals</h2>
          <p className="mt-3 max-w-sm text-[13px] text-gray-400">Review sensitive AI actions before execution.</p>

          <div className="mt-8 grid gap-2">
            {["Supabase connected", "Realtime ready", "Actions enabled", "Audit trail active"].map((item) => (
              <div key={item} className="flex items-center justify-between rounded-xl bg-white/50 px-4 py-3 text-[13px]">
                <span className="text-gray-700">{item}</span>
                <span className="text-blue-500">→</span>
              </div>
            ))}
          </div>
        </Card>

        <Card className="min-h-[420px]">
          <p className="mb-3 text-[11.5px] font-medium text-blue-500">Operational feed</p>
          <div className="space-y-2">
            {["Runtime updated", "Record synced", "Action requested", "Worker completed"].map((item) => (
              <div key={item} className="rounded-xl bg-white/50 px-4 py-3">
                <p className="text-[13px] font-medium text-gray-800">{item}</p>
                <p className="text-[12px] text-gray-400">Just now</p>
              </div>
            ))}
          </div>
        </Card>
      </section>
    </AppShell>
  );
}
