import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function RealtimeStream() {
  const { data } = await supabaseAdmin.from("realtime_streams").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Realtime Stream" subtitle="Live event feed for tasks, agents, workflows and tools."><DataTable rows={data || []} /></Shell>;
}
