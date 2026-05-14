export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin.from("marketplace_reviews").insert({
      listing_id: body.listing_id,
      company_id: body.company_id,
      rating: body.rating,
      review: body.review
    }).select().single();

    if (error) throw error;

    return NextResponse.json({ ok: true, review: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
