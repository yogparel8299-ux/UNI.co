import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function MarketplaceSeller() {
  const { data } = await supabaseAdmin.from("marketplace_payouts").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Marketplace Seller" subtitle="Seller payouts, revenue share and marketplace monetization."><DataTable rows={data || []} /></Shell>;
}
