import { NextRequest, NextResponse } from "next/server";
import { ragSearch } from "@/lib/rag/search";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const results = await ragSearch(body.company_id, body.query);
    return NextResponse.json({ ok: true, results });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
