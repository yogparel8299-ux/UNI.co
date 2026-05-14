import { supabaseAdmin } from "@/lib/supabase-admin";
import { createEmbedding } from "@/lib/memory/embedding";

export async function ragSearch(companyId: string, query: string) {
  const embedding = await createEmbedding(query);

  const { data, error } = await supabaseAdmin.rpc("match_memory", {
    query_embedding: embedding,
    match_company_id: companyId,
    match_count: 10
  });

  if (error) throw error;

  return data || [];
}
