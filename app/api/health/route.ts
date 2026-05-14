export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    ok: true,
    service: "UNIC.ai",
    status: "online",
    time: new Date().toISOString()
  });
}
