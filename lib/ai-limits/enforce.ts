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
