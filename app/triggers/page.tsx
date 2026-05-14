import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function TriggersPage() {
  const { data } = await supabaseAdmin.from("triggers").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Triggers" subtitle="Live events that fire agent actions automatically."><DataTable rows={data || []} /></Shell>;
}
