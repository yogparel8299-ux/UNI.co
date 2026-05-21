import { supabaseAdmin } from "@/lib/supabase-admin";

export const PLAN_CREDITS: Record<string, number> = {
  starter: 100000,
  builder: 300000,
  company: 1000000,
  enterprise: 5000000
};

export async function activatePlanAndCredits({
  companyId,
  userId,
  plan,
  provider,
  providerPaymentId,
  amount,
  currency
}: {
  companyId: string;
  userId?: string | null;
  plan: string;
  provider: "stripe" | "razorpay";
  providerPaymentId: string;
  amount?: number;
  currency?: string;
}) {
  const normalizedPlan = plan.toLowerCase();

  const credits =
    PLAN_CREDITS[normalizedPlan] ||
    PLAN_CREDITS.starter;

  await supabaseAdmin
    .from("company_subscriptions")
    .upsert(
      {
        company_id: companyId,
        plan: normalizedPlan,
        status: "active",
        provider,
        provider_payment_id: providerPaymentId,
        current_period_started_at:
          new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      { onConflict: "company_id" }
    );

  await supabaseAdmin
    .from("credit_wallets")
    .upsert(
      {
        company_id: companyId,
        balance: credits,
        plan_included_credits: credits,
        updated_at: new Date().toISOString()
      },
      { onConflict: "company_id" }
    );

  await supabaseAdmin
    .from("credit_ledger")
    .insert({
      company_id: companyId,
      amount: credits,
      type: "credit",
      reason: "plan_activation",
      metadata: {
        plan: normalizedPlan,
        provider,
        providerPaymentId
      }
    });

  return {
    plan: normalizedPlan,
    credits
  };
}

export async function deductCredits({
  companyId,
  amount,
  reason
}: {
  companyId: string;
  amount: number;
  reason?: string;
}) {
  const { data: wallet } = await supabaseAdmin
    .from("credit_wallets")
    .select("*")
    .eq("company_id", companyId)
    .single();

  if (!wallet) {
    throw new Error("Credit wallet not found.");
  }

  const nextBalance =
    Number(wallet.balance || 0) - Number(amount);

  if (nextBalance < 0) {
    throw new Error("Insufficient credits.");
  }

  await supabaseAdmin
    .from("credit_wallets")
    .update({
      balance: nextBalance,
      updated_at: new Date().toISOString()
    })
    .eq("company_id", companyId);

  await supabaseAdmin
    .from("credit_ledger")
    .insert({
      company_id: companyId,
      amount: -Math.abs(amount),
      type: "debit",
      reason: reason || "runtime_usage"
    });

  return {
    success: true,
    balance: nextBalance
  };
}
