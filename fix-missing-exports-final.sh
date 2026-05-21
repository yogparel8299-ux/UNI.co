#!/bin/bash
set -e

echo "Fixing missing exports and compatibility layer..."

mkdir -p lib/guards lib/billing lib/composio

cat > lib/guards/providers.ts <<'TS'
export function envReady(name: string) {
  const value = process.env[name];

  return (
    !!value &&
    value.trim() !== "" &&
    value !== "pending" &&
    value !== "placeholder"
  );
}

export function getProviderStatus() {
  return {
    openai: envReady("OPENAI_API_KEY"),
    stripe: envReady("STRIPE_SECRET_KEY"),
    razorpay:
      envReady("RAZORPAY_KEY_ID") &&
      envReady("RAZORPAY_KEY_SECRET"),
    composio: envReady("COMPOSIO_API_KEY"),
    supabase:
      envReady("NEXT_PUBLIC_SUPABASE_URL") &&
      envReady("NEXT_PUBLIC_SUPABASE_ANON_KEY") &&
      envReady("SUPABASE_SERVICE_ROLE_KEY")
  };
}

export function requireProvider(provider: string) {
  const providers = getProviderStatus();

  const exists =
    provider === "openai"
      ? providers.openai
      : provider === "stripe"
      ? providers.stripe
      : provider === "razorpay"
      ? providers.razorpay
      : provider === "composio"
      ? providers.composio
      : false;

  if (!exists) {
    throw new Error(
      `${provider.toUpperCase()} provider is not configured.`
    );
  }

  return true;
}
TS

cat > lib/billing/credits.ts <<'TS'
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
TS

cat > lib/composio/client.ts <<'TS'
export async function callComposioTool({
  connectedAccountId,
  action,
  payload
}: {
  connectedAccountId?: string;
  action: string;
  payload?: any;
}) {
  if (!process.env.COMPOSIO_API_KEY) {
    throw new Error("COMPOSIO_API_KEY missing.");
  }

  const res = await fetch(
    "https://backend.composio.dev/api/v3/tools/execute",
    {
      method: "POST",
      headers: {
        "x-api-key": process.env.COMPOSIO_API_KEY!,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        connected_account_id: connectedAccountId,
        tool_slug: action,
        arguments: payload || {}
      })
    }
  );

  const text = await res.text();

  let json: any;

  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }

  if (!res.ok) {
    throw new Error(
      json?.message ||
        json?.error ||
        "Composio execution failed."
    );
  }

  return json;
}

export async function executeComposioTool(args: any) {
  return callComposioTool(args);
}

export async function createComposioAuthLink({
  userId,
  toolkit
}: {
  userId: string;
  toolkit: string;
}) {
  if (!process.env.COMPOSIO_API_KEY) {
    throw new Error("COMPOSIO_API_KEY missing.");
  }

  const appUrl =
    process.env.NEXT_PUBLIC_APP_URL ||
    "http://localhost:3000";

  const res = await fetch(
    "https://backend.composio.dev/api/v3/connected_accounts/initiate",
    {
      method: "POST",
      headers: {
        "x-api-key": process.env.COMPOSIO_API_KEY!,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        toolkit,
        user_id: userId,
        callback_url:
          `${appUrl}/connection-layer`
      })
    }
  );

  const text = await res.text();

  let json: any;

  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }

  if (!res.ok) {
    throw new Error(
      json?.message ||
        json?.error ||
        "Composio auth failed."
    );
  }

  return json;
}
TS

npm run build
git add .
git commit -m "Fix compatibility exports and provider layer" || true
git push origin main

echo "DONE"
