export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "");

    const session = await stripe.checkout.sessions.create({
      mode: body.mode || "payment",
      success_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?success=true`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?cancel=true`,
      line_items: [{
        price_data: {
          currency: body.currency || "usd",
          product_data: { name: body.name || "UNIC.ai Credits" },
          unit_amount: Math.round(Number(body.amount || 10) * 100)
        },
        quantity: 1
      }],
      metadata: {
        company_id: body.company_id,
        pack_id: body.pack_id || "",
        credits: String(body.credits || 0)
      }
    });

    await supabaseAdmin.from("payment_checkouts").insert({
      company_id: body.company_id,
      provider: "stripe",
      checkout_type: body.mode || "payment",
      provider_session_id: session.id,
      amount: body.amount || 0,
      currency: body.currency || "usd",
      status: "created",
      metadata: { url: session.url, credits: body.credits || 0 }
    });

    return NextResponse.json({ ok: true, url: session.url });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
