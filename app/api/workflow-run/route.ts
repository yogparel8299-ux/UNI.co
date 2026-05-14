export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { startWorkflowRun } from "@/lib/workflow/engine";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const run = await startWorkflowRun(body.company_id, body.workflow_id, body.input || {});
    return NextResponse.json({ ok: true, run });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
