export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    ok: true,
    route: "audit-log",
    status: "ready"
  });
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.event_type) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id and event_type are required."
        },
        { status: 400 }
      );
    }

    const { supabaseAdmin } = await import("@/lib/supabase-admin");

    const { data, error } = await supabaseAdmin
      .from("audit_events")
      .insert({
        company_id: body.company_id,
        actor_id: body.actor_id || null,
        event_type: body.event_type,
        risk_level: body.risk_level || "low",
        entity_type: body.entity_type || null,
        entity_id: body.entity_id || null,
        metadata: body.metadata || {},
        ip_address: body.ip_address || null,
        user_agent: body.user_agent || null
      })
      .select()
      .single();

    if (error) {
      throw error;
    }

    return NextResponse.json({
      ok: true,
      audit_event: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Audit log failed."
      },
      { status: 500 }
    );
  }
}
