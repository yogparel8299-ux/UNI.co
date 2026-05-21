import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="Schedules" subtitle="Recurring tasks and automation schedules.">
      <div className="rounded-2xl border border-neutral-200 bg-white p-6">
        <div className="space-y-3">
          {["Workspace updated", "Agent assigned", "Workflow synced", "Approval reviewed"].map((x) => (
            <div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4">
              <span className="font-bold">{x}</span>
              <span className="text-sm text-neutral-500">live</span>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
