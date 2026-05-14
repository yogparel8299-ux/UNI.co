import { NextRequest, NextResponse } from "next/server";
import { enforceCompanyLimit } from "@/lib/limits/enforce";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const result = await enforceCompanyLimit(body.company_id, body.limit_type);
    return NextResponse.json({ ok: true, result });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
