import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.session_id) {
      return NextResponse.json(
        { ok: false, error: "session_id is required." },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("connector_sessions")
      .update({
        status: "connected",
        external_connection_id: body.external_connection_id || null,
        scopes: body.scopes || [],
        metadata: body.metadata || {},
        connected_at: new Date().toISOString()
      })
      .eq("id", body.session_id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      session: data
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
