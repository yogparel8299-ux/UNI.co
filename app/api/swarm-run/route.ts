export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import { runSwarm } from "@/lib/swarm/engine";

export async function POST(req: NextRequest) {
  try {
    requireProvider("openai");
    const body = await req.json();
    const jobs = await runSwarm(body.company_id, body.swarm_id, body.prompt);
    return NextResponse.json({ ok: true, jobs });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
