import { supabaseAdmin } from "@/lib/supabase-admin";

export async function streamEvent(companyId: string, event: string, payload: any, entityType?: string, entityId?: string) {
  const { data } = await supabaseAdmin.from("realtime_streams").insert({
    company_id: companyId,
    event,
    payload,
    entity_type: entityType || null,
    entity_id: entityId || null,
    stream_type: "runtime"
  }).select().single();

  return data;
}
