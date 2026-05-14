import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function MCPGatewayPage() {
  const { data: tools } = await supabaseAdmin
    .from("tool_registry")
    .select("*")
    .order("provider", { ascending: true });

  return (
    <Shell
      title="MCP Gateway"
      subtitle="Expose connected tools to AI agents through a universal MCP-style gateway."
    >
      <DataTable rows={tools || []} />
    </Shell>
  );
}
