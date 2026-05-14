export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { createNotification } from "@/lib/notifications/create";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const notification = await createNotification(body.company_id, body.title, body.body, body.metadata || {});
    return NextResponse.json({ ok: true, notification });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
