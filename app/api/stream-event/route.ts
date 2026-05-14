import { NextRequest, NextResponse } from "next/server";
import { streamEvent } from "@/lib/realtime/stream";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const event = await streamEvent(body.company_id, body.event, body.payload || {}, body.entity_type, body.entity_id);
    return NextResponse.json({ ok: true, event });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
