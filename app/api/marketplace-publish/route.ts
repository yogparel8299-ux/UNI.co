import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin.from("marketplace_listings").insert({
      company_id: body.company_id,
      agent_id: body.agent_id || null,
      dataset_id: body.dataset_id || null,
      listing_type: body.listing_type,
      title: body.title,
      description: body.description,
      price: body.price || 0,
      status: "active"
    }).select().single();

    if (error) throw error;

    return NextResponse.json({ ok: true, listing: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
