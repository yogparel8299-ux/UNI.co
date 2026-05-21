export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import Stripe from "stripe";

export async function POST(req: NextRequest) {
  try {
    requireProvider("stripe");
    const body = await req.json();
    const stripeKey = process.env.STRIPE_SECRET_KEY;

    if (!stripeKey) {
      return NextResponse.json({
        ok: false,
        error: "STRIPE_SECRET_KEY missing. Add Stripe key to enable checkout."
      }, { status: 400 });
    }

    const stripe = new Stripe(stripeKey);

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      success_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?success=true`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?canceled=true`,
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: body.name || "UNIC.ai Credit Pack"
            },
            unit_amount: Math.round(Number(body.amount || 1000) * 100)
          },
          quantity: 1
        }
      ],
      metadata: {
        company_id: body.company_id,
        pack_id: body.pack_id || ""
      }
    });

    return NextResponse.json({ ok: true, url: session.url });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
