export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { enforceAiLimits } from "@/lib/ai-limits/enforce";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const result = await enforceAiLimits({
      companyId: body.company_id,
      userId: body.user_id || null,
      provider: body.provider || "openai",
      model: body.model || "gpt-4o-mini",
      estimatedTokens: body.estimated_tokens || 1000,
      source: body.source || "platform"
    });

    return NextResponse.json({
      ok: true,
      result
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "AI limit check failed."
      },
      { status: 500 }
    );
  }
}
