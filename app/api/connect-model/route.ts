import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("model_providers")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        model_name: body.model_name,
        status: "connected",
        billing_mode: "user_pays_own_bill",
        secret_ref: body.secret_ref || null,
        config: body.config || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, provider: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
