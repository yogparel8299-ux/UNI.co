export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createConnectionLink } from "@/lib/connection/composio";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.user_id || !body.provider) {
      return NextResponse.json(
        { ok: false, error: "company_id, user_id and provider are required." },
        { status: 400 }
      );
    }

    const link = await createConnectionLink({
      userId: body.user_id,
      toolkit: body.provider,
      redirectUrl: body.redirect_url || `${process.env.NEXT_PUBLIC_APP_URL}/connection-layer`
    });

    const { data: session, error } = await supabaseAdmin
      .from("connector_sessions")
      .insert({
        company_id: body.company_id,
        user_id: body.user_id,
        provider: body.provider,
        auth_provider: "composio",
        external_connection_id: link.connected_account_id || link.connection_id || null,
        status: "pending",
        metadata: link
      })
      .select()
      .single();

    if (error) throw error;

    await supabaseAdmin.from("connector_sync_jobs").insert({
      company_id: body.company_id,
      connector_session_id: session.id,
      provider: body.provider,
      sync_type: "memory",
      status: "pending",
      next_sync_at: new Date().toISOString()
    });

    return NextResponse.json({
      ok: true,
      session,
      link
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
