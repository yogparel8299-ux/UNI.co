import { NextRequest, NextResponse } from "next/server";
import { checkRateLimit } from "@/lib/rate-limit/check";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const result = await checkRateLimit({
      companyId: body.company_id,
      route: body.route || "unknown",
      identifier: body.identifier || "anonymous",
      limit: body.limit || 100,
      windowMinutes: body.window_minutes || 60
    });

    return NextResponse.json({
      ok: true,
      result
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      {
        status: 500
      }
    );
  }
}
