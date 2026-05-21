import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function MarketplacePage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="page-title">Marketplace</h1>
        <p className="page-subtitle mt-6">Discover agent templates, skill packs, workflow systems and company operating packs.</p>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {["Agent templates", "Skill packs", "Workflow systems"].map((x) => (
            <div className="glass-card p-8" key={x}>
              <h2 className="text-3xl font-black tracking-[-0.05em]">{x}</h2>
              <p className="mt-4 text-slate-500 leading-7">Install ready-made assets into your workspace and customize them for your company.</p>
            </div>
          ))}
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
