import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  const body = await req.json();

  const { error } = await supabaseAdmin
    .from("encrypted_secrets")
    .update({ status: "revoked" })
    .eq("id", body.secret_id);

  if (error) return NextResponse.json({ ok: false, error: error.message }, { status: 500 });

  return NextResponse.json({ ok: true });
}
