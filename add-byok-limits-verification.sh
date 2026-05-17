#!/bin/bash
set -e

echo "Adding BYOK limits, verification, and anti-temp-mail protection..."

mkdir -p app/api/{verify-user-email,check-ai-limits}
mkdir -p lib/{verification,ai-limits}

cat > lib/verification/email.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function verifyEmailForSignup(userId: string, email: string) {
  const domain = email.split("@")[1]?.toLowerCase();

  if (!domain) {
    throw new Error("Invalid email.");
  }

  const { data: blocked } = await supabaseAdmin
    .from("blocked_email_domains")
    .select("*")
    .eq("domain", domain)
    .eq("active", true)
    .maybeSingle();

  const tempBlocked = !!blocked;

  const riskScore = tempBlocked ? 90 : 10;

  const { data, error } = await supabaseAdmin
    .from("user_verification_status")
    .upsert(
      {
        user_id: userId,
        email,
        email_verified: !tempBlocked,
        temp_email_blocked: tempBlocked,
        risk_score: riskScore,
        verification_level: tempBlocked ? "blocked" : "basic",
        can_use_free_credits: !tempBlocked,
        can_run_autopilot: false,
        metadata: {
          domain
        }
      },
      {
        onConflict: "user_id"
      }
    )
    .select()
    .single();

  if (error) throw error;

  return data;
}
TS

cat > lib/ai-limits/enforce.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function enforceAiLimits({
  companyId,
  userId,
  provider,
  model,
  estimatedTokens,
  source
}: {
  companyId: string;
  userId?: string | null;
  provider: string;
  model?: string;
  estimatedTokens: number;
  source: "platform" | "byok";
}) {
  const { data: billing } = await supabaseAdmin
    .from("billing_accounts")
    .select("*")
    .eq("company_id", companyId)
    .maybeSingle();

  const plan = billing?.plan || "free";

  const { data: limits } = await supabaseAdmin
    .from("plan_ai_limits")
    .select("*")
    .eq("plan_slug", plan)
    .maybeSingle();

  if (!limits) {
    throw new Error("Plan limits not configured.");
  }

  if (limits.byok_required && source !== "byok") {
    await supabaseAdmin.from("ai_usage_rate_events").insert({
      company_id: companyId,
      user_id: userId || null,
      provider,
      model,
      tokens_used: estimatedTokens,
      source,
      allowed: false,
      blocked_reason: "BYOK required on this plan."
    });

    return {
      allowed: false,
      reason: "BYOK required on this plan."
    };
  }

  if (source === "platform") {
    const dayStart = new Date();
    dayStart.setHours(0, 0, 0, 0);

    const { data: usage } = await supabaseAdmin
      .from("ai_usage_rate_events")
      .select("tokens_used")
      .eq("company_id", companyId)
      .eq("source", "platform")
      .gte("created_at", dayStart.toISOString());

    const usedToday = (usage || []).reduce((sum, row) => sum + Number(row.tokens_used || 0), 0);

    if (usedToday + estimatedTokens > Number(limits.daily_platform_tokens || 0)) {
      await supabaseAdmin.from("ai_usage_rate_events").insert({
        company_id: companyId,
        user_id: userId || null,
        provider,
        model,
        tokens_used: estimatedTokens,
        source,
        allowed: false,
        blocked_reason: "Daily platform token limit exceeded."
      });

      return {
        allowed: false,
        reason: "Daily platform token limit exceeded."
      };
    }
  }

  await supabaseAdmin.from("ai_usage_rate_events").insert({
    company_id: companyId,
    user_id: userId || null,
    provider,
    model,
    tokens_used: estimatedTokens,
    source,
    allowed: true
  });

  return {
    allowed: true
  };
}
TS

cat > app/api/verify-user-email/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { verifyEmailForSignup } from "@/lib/verification/email";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.user_id || !body.email) {
      return NextResponse.json(
        {
          ok: false,
          error: "user_id and email are required."
        },
        { status: 400 }
      );
    }

    const status = await verifyEmailForSignup(body.user_id, body.email);

    return NextResponse.json({
      ok: true,
      status
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Verification failed."
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/check-ai-limits/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { enforceAiLimits } from "@/lib/ai-limits/enforce";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const result = await enforceAiLimits({
      companyId: body.company_id,
      userId: body.user_id || null,
      provider: body.provider || "openai",
      model: body.model || "gpt-4o-mini",
      estimatedTokens: body.estimated_tokens || 1000,
      source: body.source || "platform"
    });

    return NextResponse.json({
      ok: true,
      result
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "AI limit check failed."
      },
      { status: 500 }
    );
  }
}
TS

python3 - <<'PY'
from pathlib import Path

router = Path("lib/models/real-router.ts")
if router.exists():
    text = router.read_text()
    if "enforceAiLimits" not in text:
        text = text.replace(
            'import { decryptSecret } from "@/lib/crypto";',
            'import { decryptSecret } from "@/lib/crypto";\nimport { enforceAiLimits } from "@/lib/ai-limits/enforce";'
        )

        text = text.replace(
            'const selectedProvider = provider || "openai";',
            '''
  const selectedProvider = provider || "openai";
  const source = provider ? "byok" : "platform";

  const limitCheck = await enforceAiLimits({
    companyId,
    provider: selectedProvider,
    model,
    estimatedTokens: Math.ceil((prompt.length + (systemPrompt || "").length) / 3),
    source: source as "platform" | "byok"
  });

  if (!limitCheck.allowed) {
    throw new Error(limitCheck.reason || "AI usage blocked by plan limits.");
  }
'''
        )
        router.write_text(text)
PY

git add .
git commit -m "Add BYOK limits and anti-temp-mail verification" || true

echo "DONE: BYOK limits and verification added."
