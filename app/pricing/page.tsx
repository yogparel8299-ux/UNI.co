import Link from "next/link";

export default function PricingPage() {
  return (
    <main className="min-h-screen bg-[#031427] p-8 text-[#d3e4fe]">
      <Link href="/" className="font-mono text-xs uppercase tracking-[0.18em] text-[#2fd9f4]">UNIC.ai</Link>
      <h1 className="mt-12 text-7xl font-black tracking-[-0.07em]">Pricing & Plans</h1>
      <div className="mt-10 grid gap-5 md:grid-cols-4">
        {["Starter", "Builder", "Company", "Enterprise"].map((x) => (
          <div key={x} className="rounded border border-[#45474b]/50 bg-[#0b1c30] p-6">
            <h2 className="text-3xl font-black">{x}</h2>
            <p className="mt-4 text-[#c6c6cb]">Credits, workflows, runtime and connected AI operations.</p>
            <button className="mt-8 rounded bg-[#2fd9f4] px-5 py-3 font-mono text-xs font-black uppercase text-[#00363e]">Start</button>
          </div>
        ))}
      </div>
    </main>
  );
}
