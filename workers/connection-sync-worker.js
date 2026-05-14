const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function runConnectionSync() {
  const { data: jobs, error } = await supabase
    .from("connector_sync_jobs")
    .select("*")
    .eq("status", "pending")
    .lte("next_sync_at", new Date().toISOString())
    .limit(25);

  if (error) {
    console.error("Sync job error:", error.message);
    return;
  }

  for (const job of jobs || []) {
    await supabase.from("memory_tree").insert({
      company_id: job.company_id,
      source_type: "connector_auto_sync",
      source_provider: job.provider,
      title: `${job.provider} auto sync`,
      content: `Auto-sync placeholder for ${job.provider}. Replace with provider-specific Composio tool fetch.`,
      metadata: {
        sync_job_id: job.id
      },
      synced_at: new Date().toISOString()
    });

    await supabase
      .from("connector_sync_jobs")
      .update({
        status: "pending",
        last_synced_at: new Date().toISOString(),
        next_sync_at: new Date(Date.now() + 20 * 60 * 1000).toISOString()
      })
      .eq("id", job.id);

    console.log("Synced connector job", job.id);
  }
}

console.log("UNIC.ai connection sync worker running...");
setInterval(runConnectionSync, 20 * 60 * 1000);
runConnectionSync();
