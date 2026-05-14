import { supabaseAdmin } from "@/lib/supabase-admin";

export async function auditLog({
  companyId,
  actorId,
  eventType,
  riskLevel = "low",
  entityType,
  entityId,
  metadata = {}
}: any) {
  await supabaseAdmin.from("audit_events").insert({
    company_id: companyId,
    actor_id: actorId || null,
    event_type: eventType,
    risk_level: riskLevel,
    entity_type: entityType || null,
    entity_id: entityId || null,
    metadata
  });
}
