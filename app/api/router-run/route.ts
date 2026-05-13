import { NextRequest, NextResponse } from "next/server";
import { runModelRouter } from "@/lib/models/model-router";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.prompt) {
      return NextResponse.json({ ok: false, error: "company_id and prompt required." }, { status: 400 });
    }

    const result = await runModelRouter({
      companyId: body.company_id,
      provider: body.provider,
      model: body.model,
      prompt: body.prompt,
      systemPrompt: body.system_prompt
    });

    return NextResponse.json({
      ok: true,
      result
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
