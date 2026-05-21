export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import { runRealModel } from "@/lib/models/real-router";

export async function POST(req: NextRequest) {
  try {
    requireProvider("openai");
    const body = await req.json();

    if (!body.company_id || !body.prompt) {
      return NextResponse.json({ ok: false, error: "company_id and prompt required" }, { status: 400 });
    }

    const result = await runRealModel({
      companyId: body.company_id,
      prompt: body.prompt,
      systemPrompt: body.system_prompt,
      provider: body.provider,
      model: body.model
    });

    return NextResponse.json({ ok: true, result });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
