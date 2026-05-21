import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="Dataset Sell" subtitle="Package and sell approved datasets.">
      <div className="grid gap-4 md:grid-cols-3">{["Create","Configure","Monitor","Review","Run","Export"].map((x)=>(<div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6"><h2 className="text-2xl font-black">{x}</h2><p className="mt-3 text-sm text-neutral-500">Workspace action for this module.</p></div>))}</div>
    </AppShell>
  );
}
