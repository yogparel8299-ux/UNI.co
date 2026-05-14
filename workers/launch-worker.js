const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function heartbeat(name) {
  await supabase.from("worker_health").upsert({
    worker_name: name,
    status: "online",
    last_heartbeat: new Date().toISOString(),
    metadata: { pid: process.pid }
  }, { onConflict: "worker_name" });
}

async function tick() {
  await heartbeat("launch-worker");
  console.log("launch-worker heartbeat", new Date().toISOString());
}

setInterval(tick, 30000);
tick();
