export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import Razorpay from "razorpay";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || "",
      key_secret: process.env.RAZORPAY_KEY_SECRET || ""
    });

    const order = await razorpay.orders.create({
      amount: Math.round(Number(body.amount || 100) * 100),
      currency: body.currency || "INR",
      receipt: `unic_${Date.now()}`,
      notes: {
        company_id: body.company_id,
        credits: String(body.credits || 0)
      }
    });

    await supabaseAdmin.from("payment_checkouts").insert({
      company_id: body.company_id,
      provider: "razorpay",
      checkout_type: "payment",
      provider_session_id: order.id,
      amount: body.amount || 0,
      currency: body.currency || "INR",
      status: "created",
      metadata: { order, credits: body.credits || 0 }
    });

    return NextResponse.json({ ok: true, order });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
