import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.provider) {
      return NextResponse.json({ ok: false, error: "company_id and provider required." }, { status: 400 });
    }

    const { data, error } = await supabaseAdmin
      .from("connector_accounts")
      .insert({
        company_id: body.company_id,
        provider: body.provider,
        connection_id: body.connection_id,
        auth_provider: body.auth_provider || "composio",
        status: "connected",
        scopes: body.scopes || [],
        metadata: body.metadata || {},
        connected_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      connector: data
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
