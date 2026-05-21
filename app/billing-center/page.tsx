import AppShell from "@/components/layout/AppShell";

const plans = ["Starter", "Builder", "Company", "Enterprise"];

export default function BillingPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <h1 className="text-6xl font-black tracking-[-0.07em]">Billing</h1>
        <p className="mt-5 max-w-2xl text-slate-500 leading-8">Manage subscription, platform credits and usage limits.</p>

        <div className="mt-8 grid gap-6 md:grid-cols-4">
          {plans.map((plan) => (
            <div key={plan} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{plan}</h2>
              <p className="mt-4 text-slate-500 leading-7">Credit-based workspace access for AI operations.</p>
              <button className="mt-7 rounded-full bg-slate-950 px-6 py-4 font-bold text-white">Select</button>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
