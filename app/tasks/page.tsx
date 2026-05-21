import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="Tasks" subtitle="Task queue, ownership and execution status.">
      <div className="grid gap-4 md:grid-cols-3">
        {["Backlog", "Running", "Completed"].map((col) => (
          <div key={col} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <h2 className="text-2xl font-black">{col}</h2>
            <div className="mt-5 space-y-3">
              {["Task one", "Task two", "Task three"].map((x) => (
                <div key={x} className="rounded-xl bg-neutral-100 p-4 text-sm font-bold">
                  {x}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
