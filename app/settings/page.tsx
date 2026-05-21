import AppShell from "@/components/layout/AppShell";

export default function SettingsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Settings</h1>
        <div className="mt-8 grid gap-6 lg:grid-cols-2">
          {["Workspace", "Security", "Model Keys", "Team Access"].map((x) => (
            <div key={x} className="rounded-[32px] border border-slate-200 bg-white p-8 shadow-sm">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{x}</h2>
              <p className="mt-4 text-slate-500 leading-7">Configure workspace controls and permissions.</p>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
