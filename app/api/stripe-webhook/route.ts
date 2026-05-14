import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "");
    const raw = await req.text();
    const sig = req.headers.get("stripe-signature") || "";
    const secret = process.env.STRIPE_WEBHOOK_SECRET || "";

    const event = secret
      ? stripe.webhooks.constructEvent(raw, sig, secret)
      : JSON.parse(raw);

    await supabaseAdmin.from("webhook_events").insert({
      provider: "stripe",
      event_type: event.type,
      payload: event,
      processed: false
    });

    if (event.type === "checkout.session.completed") {
      const session: any = event.data.object;
      const companyId = session.metadata?.company_id;
      const credits = Number(session.metadata?.credits || 0);

      if (companyId && credits > 0) {
        const { data: wallet } = await supabaseAdmin.from("company_credit_wallets").select("*").eq("company_id", companyId).single();
        const newBalance = Number(wallet?.balance || 0) + credits;

        if (wallet) {
          await supabaseAdmin.from("company_credit_wallets").update({
            balance: newBalance,
            lifetime_purchased: Number(wallet.lifetime_purchased || 0) + credits
          }).eq("company_id", companyId);
        } else {
          await supabaseAdmin.from("company_credit_wallets").insert({
            company_id: companyId,
            balance: credits,
            lifetime_purchased: credits
          });
        }

        await supabaseAdmin.from("credit_ledger").insert({
          company_id: companyId,
          event_type: "stripe_credit_purchase",
          amount: credits,
          balance_after: newBalance,
          metadata: { session_id: session.id }
        });
      }
    }

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 400 });
  }
}
