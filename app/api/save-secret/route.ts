export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { encryptSecret } from "@/lib/crypto";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.provider || !body.secret_value) {
      return NextResponse.json({ ok: false, error: "company_id, provider and secret_value required." }, { status: 400 });
    }

    const encrypted = encryptSecret(body.secret_value);

    const { data, error } = await supabaseAdmin
      .from("encrypted_secrets")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        secret_name: body.secret_name || `${body.provider}_key`,
        encrypted_value: encrypted,
        secret_type: "api_key",
        status: "active"
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      secret_id: data.id,
      provider: data.provider
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
