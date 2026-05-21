import AppShell from "@/components/layout/AppShell";

const assets = ["AI Sales Team", "Support Desk", "Research OS", "Content Factory", "Finance Analyst", "Hiring Pipeline"];

export default function MarketplacePage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Marketplace</h1>
        <p className="mt-5 max-w-2xl text-slate-500 leading-8">Install agent teams, skills, workflow systems and company templates.</p>

        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {assets.map((asset) => (
            <div key={asset} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <div className="mb-7 h-40 rounded-[28px] bg-gradient-to-br from-blue-50 via-white to-purple-50" />
              <h2 className="text-3xl font-black tracking-[-0.05em]">{asset}</h2>
              <p className="mt-4 text-slate-500 leading-7">A ready-to-install operating pack with agents, workflows and skills.</p>
              <button className="mt-7 rounded-full bg-slate-950 px-6 py-4 font-bold text-white">View Pack</button>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
