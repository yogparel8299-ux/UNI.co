import AppShell from "@/components/layout/AppShell";
import StatCard from "@/components/ui/StatCard";

export default function BillingCenterPage() {
  return (
    <AppShell
      title="Billing"
      subtitle="Manage plans, credits and workspace billing."
    >
      <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
        <StatCard
          title="Current Plan"
          value="Builder"
          subtitle="Monthly subscription"
        />

        <StatCard
          title="Credits"
          value="124k"
          subtitle="Available platform credits"
        />

        <StatCard
          title="Usage"
          value="42%"
          subtitle="Current billing cycle"
        />
      </div>

      <div className="mt-7 rounded-[32px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
        <h2 className="text-4xl font-black tracking-[-0.05em]">
          Credit management
        </h2>

        <p className="mt-4 max-w-3xl text-slate-500 leading-8">
          Monitor platform usage, purchase additional credits and manage model access for workspace execution.
        </p>

        <div className="mt-8 flex flex-wrap gap-4">
          <button className="rounded-full bg-[#111827] px-7 py-4 text-sm font-bold text-white">
            Buy Credits
          </button>

          <button className="rounded-full border border-slate-200 bg-white px-7 py-4 text-sm font-bold text-slate-700">
            Change Plan
          </button>
        </div>
      </div>
    </AppShell>
  );
}
