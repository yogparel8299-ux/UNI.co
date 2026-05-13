import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.prompt) {
      return NextResponse.json(
        { ok: false, error: "company_id and prompt are required." },
        { status: 400 }
      );
    }

    const { data: task, error: taskError } = await supabaseAdmin
      .from("tasks")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        title: body.title || "AI Command Task",
        input: body.prompt,
        status: "queued"
      })
      .select()
      .single();

    if (taskError) throw taskError;

    const { data: job, error: jobError } = await supabaseAdmin
      .from("execution_queue")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        task_id: task.id,
        payload: {
          prompt: body.prompt,
          model: body.model || "gpt-4o-mini"
        },
        status: "pending"
      })
      .select()
      .single();

    if (jobError) throw jobError;

    return NextResponse.json({
      ok: true,
      task,
      job
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
