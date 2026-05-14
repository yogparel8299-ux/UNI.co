export const dynamic = "force-dynamic";
export const runtime = "nodejs";
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("integrations")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        display_name: body.display_name || body.provider,
        status: "connected",
        connection_type: body.connection_type || "api_key",
        config: body.config || {},
        secret_ref: body.secret_ref || null,
        connected_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, integration: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
