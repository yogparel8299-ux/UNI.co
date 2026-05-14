import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function FinalOnboardingPage() {
  const { data } = await supabaseAdmin
    .from("onboarding_checklist")
    .select("*")
    .limit(100);

  return (
    <Shell
      title="Onboarding Progress"
      subtitle="Track every workspace setup step from first agent to first paid workflow."
    >
      <DataTable rows={data || []} />
    </Shell>
  );
}
