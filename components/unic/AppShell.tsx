import Link from "next/link";

const nav = [
  ["Dashboard","/dashboard"],["Companies","/companies"],["Team","/team"],["Goals","/goals"],
  ["Agents","/agents"],["Skills","/skills"],["Swarms","/swarms"],["Builder","/workflow-studio"],
  ["Tasks","/tasks"],["Schedules","/schedules"],["Datasets","/datasets"],["Brain","/brain"],
  ["Approvals","/approvals"],["Realtime","/realtime-dashboard"],["Marketplace","/marketplace"],
  ["Billing","/billing"],["Budgets","/budgets"],["Usage","/usage"],["Activity","/activity"],["Settings","/settings"]
];

export default function AppShell({ title, subtitle, children, right }: { title: string; subtitle?: string; children: React.ReactNode; right?: React.ReactNode }) {
  return (
    <main className="min-h-screen bg-[#f7f7f8] text-black">
      <aside className="fixed left-0 top-0 hidden h-screen w-[270px] border-r border-neutral-200 bg-white lg:block">
        <div className="border-b border-neutral-200 p-5">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-10 w-10 place-items-center rounded-xl bg-black text-white font-black">U</div>
            <div>
              <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-neutral-500">AI company OS</p>
            </div>
          </Link>
        </div>
        <div className="h-[calc(100vh-82px)] overflow-y-auto p-3">
          {nav.map(([label, href]) => (
            <Link key={href} href={href} className="mb-1 block rounded-xl px-3 py-2.5 text-sm font-bold text-neutral-600 hover:bg-neutral-100 hover:text-black">
              {label}
            </Link>
          ))}
        </div>
      </aside>

      <section className={right ? "lg:ml-[270px] lg:mr-[330px]" : "lg:ml-[270px]"}>
        <header className="sticky top-0 z-20 border-b border-neutral-200 bg-white/90 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-4">
            <div>
              <h1 className="text-2xl font-black tracking-[-0.04em]">{title}</h1>
              {subtitle && <p className="mt-1 text-sm text-neutral-500">{subtitle}</p>}
            </div>
            <div className="flex gap-2">
              <Link href="/workflow-studio" className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">Builder</Link>
              <Link href="/settings" className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">Settings</Link>
            </div>
          </div>
        </header>
        <div className="p-6">{children}</div>
      </section>

      {right && <aside className="fixed right-0 top-0 hidden h-screen w-[330px] border-l border-neutral-200 bg-white lg:block">{right}</aside>}
    </main>
  );
}
