#!/bin/bash
set -e

echo "Adding UNIC.ai ownership, integrations, pricing packs and model provider layer..."

mkdir -p app/{integrations,models,packs,ownership}
mkdir -p app/api/{connect-integration,connect-model,register-asset,buy-pack}
mkdir -p components/platform

cat > app/integrations/page.tsx <<'PAGE'
import Shell from "@/components/Shell";

const integrations = [
  ["Slack", "Team alerts, agent updates, approvals and output delivery."],
  ["Zapier", "Connect UNIC.ai agents to thousands of apps."],
  ["Webhooks", "Trigger workflows from any external system."],
  ["Gmail", "Email agents, outreach, support and summaries."],
  ["Notion", "Knowledge base, docs, task logs and company brain."],
  ["HubSpot", "CRM, leads, sales workflows and customer history."],
  ["Google Drive", "Dataset uploads, files and company documents."],
  ["Discord", "Community, agent alerts and workspace updates."]
];

export default function Integrations() {
  return (
    <Shell title="Integrations" subtitle="Connect UNIC.ai to the tools your company already uses.">
      <div className="grid grid-cols-4 gap-6">
        {integrations.map(([name, text]) => (
          <div key={name} className="glass-card p-6">
            <h2 className="text-2xl font-black tracking-[-0.03em]">{name}</h2>
            <p className="text-gray-500 mt-3 leading-7">{text}</p>
            <button className="primary-button mt-6">Connect</button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
PAGE

cat > app/models/page.tsx <<'PAGE'
import Shell from "@/components/Shell";

const providers = [
  ["OpenAI / ChatGPT", "Use GPT models with user-owned API billing."],
  ["Anthropic / Claude", "Connect Claude models for reasoning and writing."],
  ["Google Gemini", "Use Gemini for multimodal and workspace tasks."],
  ["Groq", "Fast inference for cheap high-volume runs."],
  ["Mistral", "Open model provider for cost-efficient agents."],
  ["OpenRouter", "One gateway to many models."],
  ["Local Models", "Bring your own hosted model endpoint."],
  ["Custom API", "Connect any model API with headers and endpoint."]
];

export default function Models() {
  return (
    <Shell title="Model Providers" subtitle="Let each user pay for their own model usage while UNIC.ai profits from platform credits, workflow fees and marketplace fees.">
      <div className="grid grid-cols-4 gap-6">
        {providers.map(([name, text]) => (
          <div key={name} className="glass-card p-6">
            <h2 className="text-2xl font-black tracking-[-0.03em]">{name}</h2>
            <p className="text-gray-500 mt-3 leading-7">{text}</p>
            <button className="primary-button mt-6">Connect Provider</button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
PAGE

cat > app/packs/page.tsx <<'PAGE'
import Shell from "@/components/Shell";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Packs() {
  const { data: plans } = await supabaseAdmin.from("platform_pricing_plans").select("*").order("monthly_price");
  const { data: packs } = await supabaseAdmin.from("credit_packs").select("*").eq("active", true).order("price");

  return (
    <Shell title="Pricing & Packs" subtitle="Affordable entry pricing, user-paid model bills, and profitable UNIC.ai platform credits.">
      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">Plans</h2>
      <div className="grid grid-cols-4 gap-6 mb-12">
        {(plans || []).map((p) => (
          <div key={p.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">{p.name}</h3>
            <p className="text-4xl font-black mt-4">${p.monthly_price}</p>
            <p className="text-gray-500 mt-3">{p.included_credits} credits included</p>
            <p className="text-gray-500 mt-2">${p.overage_rate}/extra credit</p>
            <p className="text-green-600 font-bold mt-4">{p.ownership_model}</p>
          </div>
        ))}
      </div>

      <h2 className="text-3xl font-black tracking-[-0.04em] mb-6">Credit Packs</h2>
      <div className="grid grid-cols-4 gap-6">
        {(packs || []).map((p) => (
          <div key={p.id} className="glass-card p-6">
            <h3 className="text-2xl font-black">{p.name}</h3>
            <p className="text-4xl font-black mt-4">${p.price}</p>
            <p className="text-gray-500 mt-3">{p.credits} credits</p>
            <p className="text-green-600 font-bold mt-2">+{p.bonus_credits} bonus</p>
            <button className="primary-button mt-6">Buy Pack</button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
PAGE

cat > app/ownership/page.tsx <<'PAGE'
import Shell from "@/components/Shell";

export default function Ownership() {
  return (
    <Shell title="Ownership & Licensing" subtitle="UNIC.ai keeps platform-level ownership by default. Enterprise customers can negotiate ownership transfer.">
      <div className="grid grid-cols-3 gap-6">
        <div className="glass-card p-8">
          <h2 className="text-2xl font-black">Starter to Company</h2>
          <p className="text-gray-500 mt-4 leading-7">
            Agents, workflows, templates, runtime systems, generated structures and platform assets are owned by UNIC.ai. Users receive a usage license inside their workspace.
          </p>
        </div>

        <div className="glass-card p-8">
          <h2 className="text-2xl font-black">Enterprise</h2>
          <p className="text-gray-500 mt-4 leading-7">
            Enterprise contracts can include custom ownership terms, private infrastructure, data isolation, SSO, audit controls and asset-transfer rights.
          </p>
        </div>

        <div className="glass-card p-8">
          <h2 className="text-2xl font-black">Marketplace</h2>
          <p className="text-gray-500 mt-4 leading-7">
            Marketplace assets can be rented, licensed or sold based on listing terms. UNIC.ai keeps platform control and marketplace fee rights.
          </p>
        </div>
      </div>
    </Shell>
  );
}
PAGE

cat > app/api/connect-integration/route.ts <<'API'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("integrations")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        display_name: body.display_name || body.provider,
        status: "connected",
        connection_type: body.connection_type || "api_key",
        config: body.config || {},
        secret_ref: body.secret_ref || null,
        connected_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, integration: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
API

cat > app/api/connect-model/route.ts <<'API'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("model_providers")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        model_name: body.model_name,
        status: "connected",
        billing_mode: "user_pays_own_bill",
        secret_ref: body.secret_ref || null,
        config: body.config || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, provider: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
API

cat > app/api/register-asset/route.ts <<'API'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("asset_registry")
      .insert({
        company_id: body.company_id,
        asset_type: body.asset_type,
        asset_id: body.asset_id,
        title: body.title,
        ownership_model: body.ownership_model || "platform_owned",
        platform_owner: "UNIC.ai",
        customer_license: body.customer_license || "usage_license",
        enterprise_transferable: !!body.enterprise_transferable,
        metadata: body.metadata || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, asset: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
API

cat > app/api/buy-pack/route.ts <<'API'
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
API

python3 - <<'PY'
from pathlib import Path
p = Path("components/Nav.tsx")
s = p.read_text()
items = [
  '["Integrations", "/integrations"],',
  '["Models", "/models"],',
  '["Packs", "/packs"],',
  '["Ownership", "/ownership"],'
]
for item in items:
    if item not in s:
        s = s.replace('["Settings", "/settings"]', item + '\n  ["Settings", "/settings"]')
p.write_text(s)
PY

git add .
git commit -m "Add UNIC.ai platform ownership integrations pricing layer" || true

echo "DONE: Added platform layer."
