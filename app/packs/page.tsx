import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Packs() {
  const { data: plans } = await supabaseAdmin.from("platform_pricing_plans").select("*").order("monthly_price");
  const { data: packs } = await supabaseAdmin.from("credit_packs").select("*").eq("active", true).order("price");

  return (
    <Shell title="Pricing & Packs" subtitle="Affordable entry pricing, user-paid model bills, and profitable UNIC.ai platform credits.">
      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">Plans</h2>
      <div className="grid grid-cols-4 gap-6 mb-12">
        {(plans || []).map((p) => (
          <div key={p.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">{p.name}</h3>
            <p className="text-4xl font-black mt-4">${p.monthly_price}</p>
            <p className="text-gray-500 mt-3">{p.included_credits} credits included</p>
            <p className="text-gray-500 mt-2">${p.overage_rate}/extra credit</p>
            <p className="text-green-600 font-bold mt-4">{p.ownership_model}</p>
          </div>
        ))}
      </div>

      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">Credit Packs</h2>
      <div className="grid grid-cols-4 gap-6">
        {(packs || []).map((p) => (
          <div key={p.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">{p.name}</h3>
            <p className="text-4xl font-black mt-4">${p.price}</p>
            <p className="text-gray-500 mt-3">{p.credits} credits</p>
            <p className="text-green-600 font-bold mt-2">+{p.bonus_credits} bonus</p>
            <button className="primary-button mt-6">Buy Pack</button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
