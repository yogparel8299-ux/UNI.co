import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Notifications() {
  const { data } = await supabaseAdmin.from("notifications").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Notifications" subtitle="System alerts, workflow updates, billing notices and agent events."><DataTable rows={data || []} /></Shell>;
}
