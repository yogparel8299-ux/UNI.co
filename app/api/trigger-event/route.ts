export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: trigger } = await supabaseAdmin
      .from("triggers")
      .select("*")
      .eq("company_id", body.company_id)
      .eq("source_provider", body.source_provider)
      .eq("event_type", body.event_type)
      .eq("enabled", true)
      .limit(1)
      .single();

    const { data: event } = await supabaseAdmin
      .from("trigger_events")
      .insert({
        company_id: body.company_id,
        trigger_id: trigger?.id || null,
        source_provider: body.source_provider,
        event_type: body.event_type,
        payload: body.payload || {},
        status: "received"
      })
      .select()
      .single();

    if (trigger?.agent_id) {
      await supabaseAdmin.from("execution_queue").insert({
        company_id: body.company_id,
        agent_id: trigger.agent_id,
        payload: {
          prompt: `A trigger fired: ${body.event_type}. Handle this event: ${JSON.stringify(body.payload || {})}`,
          trigger_event_id: event.id
        },
        status: "pending"
      });
    }

    return NextResponse.json({ ok: true, event });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
