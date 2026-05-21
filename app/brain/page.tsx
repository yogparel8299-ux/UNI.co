import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function BrainPage() {
  const { data } = await supabaseAdmin
    .from("memory_tree")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(100);

  return (
    <Shell title="Company Brain" subtitle="Long-term memory, synced knowledge and personalization signals.">
      <DataTable rows={data || []} />
    </Shell>
  );
}
