import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function SecurityPage() {
  const { data } = await supabaseAdmin.from("audit_events").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Security & Audit" subtitle="Enterprise logs for governance, risk and compliance."><DataTable rows={data || []} /></Shell>;
}
