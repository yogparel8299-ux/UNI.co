import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

function slugify(input: string) {
  return input.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_name || !body.user_id) {
      return NextResponse.json({ ok: false, error: "company_name and user_id required." }, { status: 400 });
    }

    const slug = `${slugify(body.company_name)}-${Date.now().toString().slice(-5)}`;

    const { data: company, error: companyError } = await supabaseAdmin
      .from("companies")
      .insert({
        name: body.company_name,
        slug,
        owner_id: body.user_id,
        plan: "free"
      })
      .select()
      .single();

    if (companyError) throw companyError;

    await supabaseAdmin.from("company_members").insert({
      company_id: company.id,
      user_id: body.user_id,
      role: "owner"
    });

    await supabaseAdmin.from("profiles").upsert({
      id: body.user_id,
      email: body.email,
      default_company_id: company.id
    });

    await supabaseAdmin.from("billing_accounts").insert({
      company_id: company.id,
      plan: "free",
      monthly_limit: 100,
      current_usage: 0
    });

    await supabaseAdmin.from("company_credit_wallets").insert({
      company_id: company.id,
      balance: 100,
      lifetime_purchased: 100
    });

    await supabaseAdmin.from("model_router_rules").insert({
      company_id: company.id,
      rule_name: "Default Model Router",
      primary_provider: "openai",
      primary_model: "gpt-4o-mini",
      fallback_provider: "openrouter",
      fallback_model: "openai/gpt-4o-mini",
      max_cost_per_run: 0.05,
      status: "active"
    });

    await supabaseAdmin.from("activity_logs").insert({
      company_id: company.id,
      actor_id: body.user_id,
      action: "company_onboarded",
      entity_type: "company",
      entity_id: company.id,
      metadata: { source: "onboarding" }
    });

    return NextResponse.json({ ok: true, company });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
