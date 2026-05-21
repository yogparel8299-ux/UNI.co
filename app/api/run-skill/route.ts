export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import { runAgentSkill } from "@/lib/skills/run-skill";

export async function POST(req: NextRequest) {
  try {
    requireProvider("openai");
    const body = await req.json();

    if (!body.company_id || !body.agent_id || !body.skill_assignment_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id, agent_id and skill_assignment_id are required."
        },
        { status: 400 }
      );
    }

    const result = await runAgentSkill({
      companyId: body.company_id,
      agentId: body.agent_id,
      skillAssignmentId: body.skill_assignment_id,
      input: body.input || {}
    });

    return NextResponse.json({
      ok: true,
      ...result
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Run skill failed."
      },
      { status: 500 }
    );
  }
}
