import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function RealtimePage() {
  const { data } = await supabaseAdmin.from("runtime_events").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Realtime Runtime" subtitle="Live execution stream and runtime event feed."><DataTable rows={data || []} /></Shell>;
}
