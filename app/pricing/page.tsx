import PublicShell from "@/components/unic/PublicShell";

export default function PricingPage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="text-7xl font-black tracking-[-.08em]">Pricing</h1>
        <p className="mt-5 max-w-2xl text-neutral-500">Credit-based plans for AI operations, agents and workflows.</p>

        <div className="mt-10 grid gap-4 md:grid-cols-4">
          {["Starter","Builder","Company","Enterprise"].map((p)=>(
            <div key={p} className="rounded-2xl border border-neutral-200 bg-white p-6">
              <h2 className="text-3xl font-black">{p}</h2>
              <p className="mt-4 text-neutral-500">Workspace access with platform credits and BYOK support.</p>
              <button className="mt-7 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">Start</button>
            </div>
          ))}
        </div>
      </section>
    </PublicShell>
  );
}
