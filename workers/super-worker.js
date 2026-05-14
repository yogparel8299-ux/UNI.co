const { createClient } = require("@supabase/supabase-js");
const OpenAI = require("openai");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const openai = process.env.OPENAI_API_KEY ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY }) : null;

async function embedMemory(companyId, title, content, sourceProvider = "worker") {
  if (!openai || !content) return;

  const emb = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: content.slice(0, 8000)
  });

  await supabase.from("memory_tree").insert({
    company_id: companyId,
    source_type: "worker_output",
    source_provider: sourceProvider,
    title,
    content,
    embedding: emb.data[0].embedding,
    synced_at: new Date().toISOString()
  });
}

async function syncMemory() {
  const { data: rows } = await supabase
    .from("runtime_events")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(20);

  for (const row of rows || []) {
    if (row.message) {
      await embedMemory(row.company_id, row.event_type, row.message, "runtime_events");
    }
  }
}

async function processTriggers() {
  const { data: events } = await supabase
    .from("trigger_events")
    .select("*")
    .eq("status", "received")
    .limit(10);

  for (const ev of events || []) {
    await supabase.from("trigger_events").update({ status: "processed" }).eq("id", ev.id);
  }
}

async function tick() {
  try {
    await processTriggers();
    await syncMemory();
    console.log("Super worker tick", new Date().toISOString());
  } catch (e) {
    console.error(e.message);
  }
}

setInterval(tick, 20 * 60 * 1000);
tick();
