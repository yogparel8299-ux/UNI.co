import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function BillingCenterPage() {
  const { data: plans } = await supabaseAdmin
    .from("platform_pricing_plans")
    .select("*")
    .order("monthly_price");

  const { data: packs } = await supabaseAdmin
    .from("credit_packs")
    .select("*")
    .eq("active", true)
    .order("price");

  return (
    <Shell
      title="Billing Center"
      subtitle="Affordable plans, credit packs and user-paid model routing."
    >
      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">
        Plans
      </h2>

      <div className="grid grid-cols-4 gap-6 mb-12">
        {(plans || []).map((plan) => (
          <div key={plan.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">
              {plan.name}
            </h3>

            <p className="text-4xl font-black mt-4">
              ${plan.monthly_price}
            </p>

            <p className="text-gray-500 mt-4">
              {plan.included_credits} credits included
            </p>

            <p className="text-green-600 font-bold mt-4">
              {plan.ownership_model}
            </p>

            <button className="primary-button mt-6">
              Choose Plan
            </button>
          </div>
        ))}
      </div>

      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">
        Credit Packs
      </h2>

      <div className="grid grid-cols-4 gap-6">
        {(packs || []).map((pack) => (
          <div key={pack.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">
              {pack.name}
            </h3>

            <p className="text-4xl font-black mt-4">
              ${pack.price}
            </p>

            <p className="text-gray-500 mt-4">
              {pack.credits} credits
            </p>

            <p className="text-green-600 font-bold mt-2">
              +{pack.bonus_credits} bonus
            </p>

            <button className="primary-button mt-6">
              Buy Credits
            </button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
