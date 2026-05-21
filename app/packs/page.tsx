import Link from "next/link";
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

const packs = [
  ["Launch Pack", "Extra credits for founders testing agents and workflows.", "$9"],
  ["Growth Pack", "More execution room for daily workflows and content systems.", "$29"],
  ["Scale Pack", "High-volume credits for business workflows and teams.", "$99"]
];

export default function PacksPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="page-title">Credit packs</h1>
        <p className="page-subtitle mt-6">Add platform credits when you need more execution capacity without changing your subscription.</p>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {packs.map(([name, desc, price]) => (
            <div className="glass-card p-8" key={name}>
              <h2 className="text-3xl font-black tracking-[-0.05em]">{name}</h2>
              <p className="mt-4 text-slate-500 leading-7">{desc}</p>
              <p className="mt-8 text-5xl font-black">{price}</p>
              <Link className="primary-button mt-7" href="/signup">Get pack</Link>
            </div>
          ))}
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
