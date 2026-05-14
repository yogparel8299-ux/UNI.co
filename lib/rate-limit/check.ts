import { supabaseAdmin } from "@/lib/supabase-admin";

export async function checkRateLimit({
  companyId,
  route,
  identifier,
  limit = 100,
  windowMinutes = 60
}: {
  companyId: string;
  route: string;
  identifier: string;
  limit?: number;
  windowMinutes?: number;
}) {
  const since = new Date(Date.now() - windowMinutes * 60 * 1000).toISOString();

  const { count } = await supabaseAdmin
    .from("rate_limit_events")
    .select("*", {
      count: "exact",
      head: true
    })
    .eq("company_id", companyId)
    .eq("route", route)
    .eq("identifier", identifier)
    .gte("created_at", since);

  const requestCount = Number(count || 0) + 1;
  const allowed = requestCount <= limit;

  await supabaseAdmin.from("rate_limit_events").insert({
    company_id: companyId,
    route,
    identifier,
    allowed,
    request_count: requestCount,
    limit_count: limit
  });

  return {
    allowed,
    requestCount,
    limit,
    remaining: Math.max(0, limit - requestCount)
  };
}
