export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: listing } = await supabaseAdmin.from("marketplace_listings").select("*").eq("id", body.listing_id).single();

    const { data: order } = await supabaseAdmin.from("marketplace_orders").insert({
      buyer_company_id: body.buyer_company_id,
      seller_company_id: listing.company_id,
      listing_id: listing.id,
      amount: listing.price,
      status: "completed"
    }).select().single();

    const { data: entitlement } = await supabaseAdmin.from("marketplace_entitlements").insert({
      company_id: body.buyer_company_id,
      listing_id: listing.id,
      order_id: order.id,
      entitlement_type: "rental",
      status: "active",
      expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
    }).select().single();

    await supabaseAdmin.from("marketplace_payouts").insert({
      seller_company_id: listing.company_id,
      order_id: order.id,
      gross_amount: listing.price,
      platform_fee: Number(listing.price || 0) * 0.2,
      net_amount: Number(listing.price || 0) * 0.8,
      status: "pending"
    });

    return NextResponse.json({ ok: true, order, entitlement });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
