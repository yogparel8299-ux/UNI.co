import { NextRequest } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function protectApi(req: NextRequest, companyId?: string) {
  const userId = req.headers.get("x-unic-user-id") || req.headers.get("x-user-id");

  if (!companyId) {
    return { ok: false, status: 400, error: "company_id is required." };
  }

  if (!userId) {
    return { ok: false, status: 401, error: "Missing authenticated user id." };
  }

  const { data } = await supabaseAdmin
    .from("company_members")
    .select("id")
    .eq("company_id", companyId)
    .eq("user_id", userId)
    .maybeSingle();

  if (!data) {
    return { ok: false, status: 403, error: "User does not belong to this company." };
  }

  return { ok: true, userId };
}
