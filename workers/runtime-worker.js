const { createClient } = require("@supabase/supabase-js");
const OpenAI = require("openai");
// Model router exists in app runtime. Worker keeps OpenAI fallback for now.

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const openai = process.env.OPENAI_API_KEY
  ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
  : null;

async function getAgent(agentId) {
  if (!agentId) return null;

  const { data } = await supabase
    .from("agents")
    .select("*")
    .eq("id", agentId)
    .single();

  return data;
}

async function processQueue() {
  const { data: jobs, error } = await supabase
    .from("execution_queue")
    .select("*")
    .eq("status", "pending")
    .order("created_at", { ascending: true })
    .limit(5);

  if (error) {
    console.error("Queue fetch error:", error.message);
    return;
  }

  for (const job of jobs || []) {
    let run = null;

    try {
      await supabase
        .from("execution_queue")
        .update({
          status: "running",
          attempts: (job.attempts || 0) + 1,
          locked_at: new Date().toISOString()
        })
        .eq("id", job.id);

      const agent = await getAgent(job.agent_id);

      const { data: createdRun, error: runError } = await supabase
        .from("agent_runs")
        .insert({
          company_id: job.company_id,
          agent_id: job.agent_id,
          task_id: job.task_id,
          status: "running",
          input: job.payload || {},
          started_at: new Date().toISOString()
        })
        .select()
        .single();

      if (runError) throw runError;
      run = createdRun;

      await supabase.from("runtime_events").insert({
        company_id: job.company_id,
        run_id: run.id,
        event_type: "started",
        message: "UNIC.ai worker started the command."
      });

      let output = "Command executed. OPENAI_API_KEY is not configured, so this is placeholder output.";

      if (openai && job.payload?.prompt) {
        const completion = await openai.chat.completions.create({
          model: job.payload?.model || agent?.model || "gpt-4o-mini",
          temperature: 0.4,
          messages: [
            {
              role: "system",
              content:
                agent?.system_prompt ||
                job.payload?.system_prompt ||
                "You are a UNIC.ai execution agent. Complete the user's requested work with structured, useful output."
            },
            {
              role: "user",
              content: job.payload.prompt
            }
          ]
        });

        output =
          completion.choices?.[0]?.message?.content ||
          "No output returned.";
      }

      await supabase
        .from("agent_runs")
        .update({
          status: "completed",
          output: { text: output },
          finished_at: new Date().toISOString()
        })
        .eq("id", run.id);

      if (job.task_id) {
        await supabase
          .from("tasks")
          .update({
            status: "completed",
            output,
            completed_at: new Date().toISOString()
          })
          .eq("id", job.task_id);
      }

      await supabase.from("runtime_events").insert({
        company_id: job.company_id,
        run_id: run.id,
        event_type: "completed",
        message: "UNIC.ai worker completed the command."
      });

      await supabase.from("usage_events").insert({
        company_id: job.company_id,
        event_type: "agent_run",
        quantity: 1,
        cost: 0.01,
        metadata: {
          job_id: job.id,
          run_id: run.id,
          task_id: job.task_id
        }
      });

      await supabase
        .from("execution_queue")
        .update({ status: "completed" })
        .eq("id", job.id);

      console.log("Completed job", job.id);
    } catch (err) {
      console.error("Job failed", job.id, err.message);

      if (run?.id) {
        await supabase
          .from("agent_runs")
          .update({
            status: "failed",
            error: err.message,
            finished_at: new Date().toISOString()
          })
          .eq("id", run.id);
      }

      await supabase
        .from("execution_queue")
        .update({
          status:
            (job.attempts || 0) + 1 >= (job.max_attempts || 3)
              ? "failed"
              : "pending"
        })
        .eq("id", job.id);
    }
  }
}

console.log("UNIC.ai AI Command Worker running...");
setInterval(processQueue, 10000);
