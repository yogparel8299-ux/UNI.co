import { supabaseAdmin } from "@/lib/supabase-admin";

export async function createNotification(companyId: string, title: string, body: string, metadata: any = {}) {
  const { data } = await supabaseAdmin
    .from("notifications")
    .insert({
      company_id: companyId,
      title,
      body,
      metadata
    })
    .select()
    .single();

  return data;
}
