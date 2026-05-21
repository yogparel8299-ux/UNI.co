import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function MarketplaceExplorePage() {
  const { data: listings } = await supabaseAdmin
    .from("marketplace_listings")
    .select("*")
    .eq("status", "active")
    .order("created_at", {
      ascending: false
    })
    .limit(60);

  const { data: categories } = await supabaseAdmin
    .from("marketplace_categories")
    .select("*")
    .eq("active", true);

  return (
    <Shell
      title="Marketplace Explore"
      subtitle="Buy, rent and license AI employees, workflows, datasets, prompt systems and memory packs."
    >
      <div className="flex gap-3 mb-8 flex-wrap">
        {(categories || []).map((category) => (
          <span key={category.id} className="status-pill">
            {category.name}
          </span>
        ))}
      </div>

      <div className="grid grid-cols-3 gap-6">
        {(listings || []).map((item) => (
          <div key={item.id} className="glass-card p-6">
            <p className="text-green-600 font-bold uppercase text-xs">
              {item.listing_type}
            </p>

            <h2 className="text-2xl font-black tracking-[-0.03em] mt-3">
              {item.title}
            </h2>

            <p className="text-gray-500 mt-3 leading-7">
              {item.description || "Premium UNIC.ai marketplace asset."}
            </p>

            <p className="text-4xl font-black mt-6">
              {item.price || 0} credits
            </p>

            <div className="flex gap-3 mt-6">
              <button className="primary-button">
                Rent
              </button>

              <button className="secondary-button">
                Details
              </button>
            </div>
          </div>
        ))}

        {(!listings || listings.length === 0) && (
          <div className="glass-card p-10 text-gray-500 col-span-3">
            No marketplace listings yet.
          </div>
        )}
      </div>
    </Shell>
  );
}
