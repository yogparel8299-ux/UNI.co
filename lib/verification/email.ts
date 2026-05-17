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
