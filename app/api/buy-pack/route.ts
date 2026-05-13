import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: pack, error: packError } = await supabaseAdmin
      .from("credit_packs")
      .select("*")
      .eq("id", body.pack_id)
      .single();

    if (packError) throw packError;

    const totalCredits = Number(pack.credits) + Number(pack.bonus_credits || 0);

    const { data: wallet } = await supabaseAdmin
      .from("company_credit_wallets")
      .select("*")
      .eq("company_id", body.company_id)
      .single();

    let newBalance = totalCredits;

    if (wallet) {
      newBalance = Number(wallet.balance || 0) + totalCredits;

      await supabaseAdmin
        .from("company_credit_wallets")
        .update({
          balance: newBalance,
          lifetime_purchased: Number(wallet.lifetime_purchased || 0) + totalCredits
        })
        .eq("company_id", body.company_id);
    } else {
      await supabaseAdmin
        .from("company_credit_wallets")
        .insert({
          company_id: body.company_id,
          balance: totalCredits,
          lifetime_purchased: totalCredits
        });
    }

    await supabaseAdmin.from("credit_ledger").insert({
      company_id: body.company_id,
      event_type: "pack_purchase",
      amount: totalCredits,
      balance_after: newBalance,
      metadata: { pack_id: pack.id, pack_name: pack.name, price: pack.price }
    });

    return NextResponse.json({
      ok: true,
      message: "Pack added. Replace this placeholder with Stripe/Razorpay payment confirmation before production.",
      credits_added: totalCredits,
      balance_after: newBalance
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
