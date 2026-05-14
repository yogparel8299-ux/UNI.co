import { NextRequest, NextResponse } from "next/server";
import { auditLog } from "@/lib/security/audit";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    await auditLog({
      companyId: body.company_id,
      actorId: body.actor_id,
      eventType: body.event_type,
      riskLevel: body.risk_level,
      entityType: body.entity_type,
      entityId: body.entity_id,
      metadata: body.metadata || {}
    });

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
