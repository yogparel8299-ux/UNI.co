#!/bin/bash
set -e

echo "Adding provider safety locks for missing keys..."

mkdir -p lib/guards app/api/provider-status

cat > lib/guards/providers.ts <<'TS'
export function envReady(name: string) {
  const value = process.env[name];
  return !!value && value.trim() !== "" && value !== "pending" && value !== "placeholder";
}

export function getProviderStatus() {
  return {
    openai: envReady("OPENAI_API_KEY"),
    stripe: envReady("STRIPE_SECRET_KEY"),
    razorpay: envReady("RAZORPAY_KEY_ID") && envReady("RAZORPAY_KEY_SECRET"),
    composio: envReady("COMPOSIO_API_KEY"),
    supabase:
      envReady("NEXT_PUBLIC_SUPABASE_URL") &&
      envReady("NEXT_PUBLIC_SUPABASE_ANON_KEY") &&
      envReady("SUPABASE_SERVICE_ROLE_KEY")
  };
}

export function requireProvider(provider: "openai" | "stripe" | "razorpay" | "composio") {
  const status = getProviderStatus();

  if (!status[provider]) {
    throw new Error(
      `${provider.toUpperCase()} is not configured yet. This action is disabled until the platform owner adds the required keys.`
    );
  }

  return true;
}
TS

cat > app/api/provider-status/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextResponse } from "next/server";
import { getProviderStatus } from "@/lib/guards/providers";

export async function GET() {
  const status = getProviderStatus();

  return NextResponse.json({
    ok: true,
    status,
    disabled: {
      payments: !status.stripe && !status.razorpay,
      stripeCheckout: !status.stripe,
      razorpayOrders: !status.razorpay,
      platformAi: !status.openai,
      connectors: !status.composio
    }
  });
}
TS

python3 - <<'PY'
from pathlib import Path

routes = {
  "app/api/stripe-checkout/route.ts": ("stripe", "Stripe checkout is disabled until Stripe keys are configured."),
  "app/api/buy-pack/route.ts": ("stripe", "Pack purchase is disabled until payment keys are configured."),
  "app/api/buy-credits/route.ts": ("stripe", "Credit purchase is disabled until payment keys are configured."),
  "app/api/marketplace-buy/route.ts": ("stripe", "Marketplace purchase is disabled until payment keys are configured."),
  "app/api/marketplace-rent/route.ts": ("stripe", "Marketplace rental is disabled until payment keys are configured."),
  "app/api/razorpay-order/route.ts": ("razorpay", "Razorpay orders are disabled until Razorpay keys are configured."),
  "app/api/router-run/route.ts": ("openai", "Platform AI execution is disabled until OpenAI key is configured."),
  "app/api/embed-text/route.ts": ("openai", "Embedding generation is disabled until OpenAI key is configured."),
  "app/api/swarm-run/route.ts": ("openai", "Swarm execution is disabled until OpenAI key is configured."),
  "app/api/run-skill/route.ts": ("openai", "Skill execution is disabled until OpenAI key is configured."),
  "app/api/tool-execute/route.ts": ("composio", "External tool execution is disabled until Composio key is configured."),
  "app/api/connection-tool-call/route.ts": ("composio", "Connector tool calls are disabled until Composio key is configured."),
}

for file, (provider, message) in routes.items():
    p = Path(file)
    if not p.exists():
        continue

    text = p.read_text()

    if "@/lib/guards/providers" not in text:
        text = text.replace(
            'import { NextRequest, NextResponse } from "next/server";',
            'import { NextRequest, NextResponse } from "next/server";\nimport { requireProvider } from "@/lib/guards/providers";'
        )
        text = text.replace(
            "import { NextResponse } from \"next/server\";",
            "import { NextResponse } from \"next/server\";\nimport { requireProvider } from \"@/lib/guards/providers\";"
        )

    if "requireProvider(" not in text:
        marker = "try {"
        if marker in text:
            text = text.replace(marker, f'try {{\n    requireProvider("{provider}");', 1)
        else:
            text = text.replace("export async function POST", f'// {message}\nexport async function POST')

    p.write_text(text)
PY

cat > app/billing/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import { getProviderStatus } from "@/lib/guards/providers";

export default function BillingPage() {
  const status = getProviderStatus();
  const paymentsReady = status.stripe || status.razorpay;

  return (
    <AppShell title="Billing" subtitle="Plans, credits and payment status.">
      {!paymentsReady && (
        <div className="mb-6 rounded-2xl border border-amber-200 bg-amber-50 p-5">
          <p className="font-black text-amber-800">Payments are not active yet</p>
          <p className="mt-2 text-sm text-amber-700">
            Stripe/Razorpay keys are not configured. Checkout, starter packs and credit purchases are disabled until the owner adds payment keys.
          </p>
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-4">
        {["Starter", "Builder", "Company", "Enterprise"].map((plan) => (
          <div key={plan} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{plan}</h2>
            <p className="mt-4 text-sm text-neutral-500">Credit-based workspace plan.</p>
            <button
              disabled={!paymentsReady}
              className={
                paymentsReady
                  ? "mt-6 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white"
                  : "mt-6 rounded-xl bg-neutral-200 px-5 py-3 text-sm font-bold text-neutral-500"
              }
            >
              {paymentsReady ? "Select" : "Disabled"}
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX

cat > app/billing-center/page.tsx <<'TSX'
export { default } from "../billing/page";
TSX

npm run build
git add .
git commit -m "Add safety locks for missing providers and disabled billing" || true
git push origin main
