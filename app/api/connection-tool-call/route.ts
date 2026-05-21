export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { executeTool } from "@/lib/connection/composio";

export async function POST(req: NextRequest) {
  try {
    requireProvider("composio");
    const body = await req.json();

    if (!body.company_id || !body.user_id || !body.provider || !body.tool_slug) {
      return NextResponse.json(
        { ok: false, error: "company_id, user_id, provider and tool_slug are required." },
        { status: 400 }
      );
    }

    const { data: execution, error: insertError } = await supabaseAdmin
      .from("tool_executions")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        provider: body.provider,
        tool_slug: body.tool_slug,
        input: body.arguments || {},
        status: "running"
      })
      .select()
      .single();

    if (insertError) throw insertError;

    const output = await executeTool({
      userId: body.user_id,
      toolkit: body.provider,
      toolSlug: body.tool_slug,
      args: body.arguments || {}
    });

    await supabaseAdmin
      .from("tool_executions")
      .update({
        output,
        status: "completed",
        completed_at: new Date().toISOString()
      })
      .eq("id", execution.id);

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      run_id: null,
      event_type: "tool_executed",
      message: `${body.provider}.${body.tool_slug} executed.`,
      metadata: {
        execution_id: execution.id
      }
    });

    return NextResponse.json({
      ok: true,
      execution_id: execution.id,
      output
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
