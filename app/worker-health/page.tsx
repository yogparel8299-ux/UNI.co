import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function WorkerHealth() {
  const { data } = await supabaseAdmin.from("worker_health").select("*").order("last_heartbeat", { ascending: false });
  return <Shell title="Worker Health" subtitle="Runtime, super-worker and connection-worker status."><DataTable rows={data || []} /></Shell>;
}
