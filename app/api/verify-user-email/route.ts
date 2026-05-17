export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { verifyEmailForSignup } from "@/lib/verification/email";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.user_id || !body.email) {
      return NextResponse.json(
        {
          ok: false,
          error: "user_id and email are required."
        },
        { status: 400 }
      );
    }

    const status = await verifyEmailForSignup(body.user_id, body.email);

    return NextResponse.json({
      ok: true,
      status
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Verification failed."
      },
      { status: 500 }
    );
  }
}
