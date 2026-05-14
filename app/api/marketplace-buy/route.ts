export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { deductCredits } from "@/lib/billing/credits";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: listing, error } = await supabaseAdmin
      .from("marketplace_listings")
      .select("*")
      .eq("id", body.listing_id)
      .single();

    if (error) throw error;

    await deductCredits(body.buyer_company_id, Number(listing.price || 0), {
      type: "marketplace_purchase",
      listing_id: listing.id
    });

    const { data: order } = await supabaseAdmin.from("marketplace_orders").insert({
      buyer_company_id: body.buyer_company_id,
      seller_company_id: listing.company_id,
      listing_id: listing.id,
      amount: listing.price || 0,
      status: "completed"
    }).select().single();

    const { data: entitlement } = await supabaseAdmin.from("marketplace_entitlements").insert({
      company_id: body.buyer_company_id,
      listing_id: listing.id,
      order_id: order.id,
      entitlement_type: body.entitlement_type || "license",
      status: "active"
    }).select().single();

    return NextResponse.json({ ok: true, order, entitlement });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
