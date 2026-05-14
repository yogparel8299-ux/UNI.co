import { supabaseAdmin } from "@/lib/supabase-admin";

export async function deductCredits(companyId: string, amount: number, metadata: any = {}) {
  const { data: wallet } = await supabaseAdmin
    .from("company_credit_wallets")
    .select("*")
    .eq("company_id", companyId)
    .single();

  if (!wallet) throw new Error("Credit wallet missing.");
  if (Number(wallet.balance) < amount) throw new Error("Insufficient credits.");

  const newBalance = Number(wallet.balance) - amount;

  await supabaseAdmin
    .from("company_credit_wallets")
    .update({
      balance: newBalance,
      lifetime_used: Number(wallet.lifetime_used || 0) + amount
    })
    .eq("company_id", companyId);

  await supabaseAdmin.from("credit_ledger").insert({
    company_id: companyId,
    event_type: "usage_deduction",
    amount: -amount,
    balance_after: newBalance,
    metadata
  });

  return newBalance;
}
