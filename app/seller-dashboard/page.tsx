import Shell from "@/components/Shell";
import Card from "@/components/Card";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function SellerDashboardPage() {
  const { data: payouts, count } = await supabaseAdmin.from("marketplace_payouts").select("*", { count: "exact" }).order("created_at", { ascending: false }).limit(100);
  const totalNet = (payouts || []).reduce((sum, payout) => sum + Number(payout.net_amount || 0), 0);
  return (
    <Shell title="Seller Dashboard" subtitle="Marketplace revenue, payouts, fees and asset monetization.">
      <div className="grid grid-cols-3 gap-6 mb-8">
        <Card title="Payout Records" value={count || 0} />
        <Card title="Net Revenue" value={totalNet.toFixed(2)} />
        <Card title="Platform Fee" value="20%" />
      </div>
      <DataTable rows={payouts || []} />
    </Shell>
  );
}
