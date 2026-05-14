export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { protectApi } from "@/lib/auth/protect-api";

export async function POST(req: NextRequest) {
  const body = await req.json();

  const guard = await protectApi(req, body.company_id);

  if (!guard.ok) {
    return NextResponse.json(
      {
        ok: false,
        error: guard.error
      },
      {
        status: guard.status || 403
      }
    );
  }

  return NextResponse.json({
    ok: true,
    message: "Protected API check passed.",
    guard
  });
}
