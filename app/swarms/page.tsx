import Shell from "@/components/Shell";
import Card from "@/components/Card";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Page() {
  const { data, count } = await supabaseAdmin
    .from("swarms")
    .select("*", { count: "exact" })
    .order("created_at", { ascending: false })
    .limit(50);

  return (
    <Shell title="Swarms">
      <div className="grid grid-cols-3 gap-6 mb-8">
        <Card title="Total Records" value={count || 0} />
        <Card title="Database Table" value="swarms" />
        <Card title="Status" value="Live" />
      </div>

      <DataTable rows={data || []} />
    </Shell>
  );
}
