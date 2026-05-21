import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="Billing" subtitle="Plans, invoices, credits and payment status.">
      <div className="grid gap-4 md:grid-cols-4">
        {["Starter", "Builder", "Company", "Enterprise"].map((x) => (
          <div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{x}</h2>
            <p className="mt-3 text-sm text-neutral-500">
              Credit-based workspace plan.
            </p>
            <button className="mt-6 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">
              Select
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
