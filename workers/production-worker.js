const { createClient } = require("@supabase/supabase-js");
const OpenAI = require("openai");

function required(name) {
  if (!process.env[name]) throw new Error(`Missing env: ${name}`);
  return process.env[name];
}

const supabase = createClient(
  required("NEXT_PUBLIC_SUPABASE_URL"),
  required("SUPABASE_SERVICE_ROLE_KEY"),
  { auth: { persistSession: false } }
);

const openai = new OpenAI({ apiKey: required("OPENAI_API_KEY") });

async function heartbeat(workerName) {
  await supabase.from("worker_health").upsert({
    worker_name: workerName,
    status: "online",
    last_heartbeat: new Date().toISOString(),
    metadata: { pid: process.pid }
  }, { onConflict: "worker_name" });
}

async function claimJobs() {
  const { data: jobs, error } = await supabase
    .from("execution_queue")
    .select("*")
    .eq("status", "pending")
    .order("created_at", { ascending: true })
    .limit(3);

  if (error) throw error;

  const claimed = [];
  for (const job of jobs || []) {
    const { data, error: updateError } = await supabase
      .from("execution_queue")
      .update({ status: "running", attempts: (job.attempts || 0) + 1, locked_at: new Date().toISOString() })
      .eq("id", job.id)
      .eq("status", "pending")
      .select()
      .single();

    if (!updateError && data) claimed.push(data);
  }

  return claimed;
}

async function runJob(job) {
  let run = null;

  try {
    const { data: createdRun, error: runError } = await supabase.from("agent_runs").insert({
      company_id: job.company_id,
      agent_id: job.agent_id,
      task_id: job.task_id,
      status: "running",
      input: job.payload || {},
      started_at: new Date().toISOString()
    }).select().single();

    if (runError) throw runError;
    run = createdRun;

    await supabase.from("runtime_events").insert({
      company_id: job.company_id,
      run_id: run.id,
      event_type: "started",
      message: "Production worker started task.",
      metadata: { job_id: job.id }
    });

    const prompt = job.payload?.prompt || JSON.stringify(job.payload || {});
    const completion = await openai.chat.completions.create({
      model: job.payload?.model || "gpt-4o-mini",
      messages: [
        { role: "system", content: job.payload?.system_prompt || "You are a UNIC.ai production execution agent." },
        { role: "user", content: prompt }
      ]
    });

    const output = completion.choices?.[0]?.message?.content || "";
    const chunks = output.match(/[\s\S]{1,1500}/g) || [];

    for (let i = 0; i < chunks.length; i++) {
      await supabase.from("task_output_chunks").insert({
        company_id: job.company_id,
        task_id: job.task_id,
        run_id: run.id,
        chunk_index: i,
        content: chunks[i]
      });
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      output: { text: output },
      finished_at: new Date().toISOString()
    }).eq("id", run.id);

    if (job.task_id) {
      await supabase.from("tasks").update({
        status: "completed",
        output,
        completed_at: new Date().toISOString()
      }).eq("id", job.task_id);
    }

    await supabase.from("execution_queue").update({ status: "completed" }).eq("id", job.id);

    await supabase.from("realtime_streams").insert({
      company_id: job.company_id,
      stream_type: "runtime",
      entity_type: "task",
      entity_id: job.task_id,
      event: "task_completed",
      payload: { job_id: job.id, run_id: run.id }
    });

    console.log("Completed job", job.id);
  } catch (error) {
    console.error("Job failed", job.id, error.message);

    if (run?.id) {
      await supabase.from("agent_runs").update({
        status: "failed",
        error: error.message,
        finished_at: new Date().toISOString()
      }).eq("id", run.id);
    }

    await supabase.from("execution_queue").update({
      status: (job.attempts || 0) + 1 >= (job.max_attempts || 3) ? "failed" : "pending"
    }).eq("id", job.id);
  }
}

async function loop() {
  const workerName = "unic-production-worker";
  while (true) {
    try {
      await heartbeat(workerName);
      const jobs = await claimJobs();
      for (const job of jobs) await runJob(job);
    } catch (error) {
      console.error("Worker loop error:", error.message);
    }
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }
}

loop();
