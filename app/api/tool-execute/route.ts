export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { executeComposioTool } from "@/lib/composio/client";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { deductCredits } from "@/lib/billing/credits";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: execution } = await supabaseAdmin
      .from("tool_executions")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id || null,
        provider: body.toolkit,
        tool_slug: body.tool_slug,
        input: body.arguments || {},
        status: "running"
      })
      .select()
      .single();

    const output = await executeComposioTool({
      userId: body.user_id,
      toolkit: body.toolkit,
      toolSlug: body.tool_slug,
      argumentsJson: body.arguments || {}
    });

    await supabaseAdmin
      .from("tool_executions")
      .update({
        output,
        status: "completed",
        completed_at: new Date().toISOString()
      })
      .eq("id", execution.id);

    await deductCredits(body.company_id, 1, {
      type: "tool_execution",
      tool_slug: body.tool_slug
    });

    return NextResponse.json({ ok: true, output });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
