import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function LiveRuntimePage() {
  const { data } = await supabaseAdmin
    .from("realtime_streams")
    .select("*")
    .order("created_at", {
      ascending: false
    })
    .limit(150);

  return (
    <Shell
      title="Live Runtime"
      subtitle="Realtime execution stream for agents, workflows, tools and swarms."
    >
      <DataTable rows={data || []} />
    </Shell>
  );
}
