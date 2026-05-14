export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: sessions, error } = await supabaseAdmin
      .from("connector_sessions")
      .select("*")
      .eq("company_id", body.company_id)
      .eq("status", "connected");

    if (error) throw error;

    for (const session of sessions || []) {
      await supabaseAdmin.from("memory_tree").insert({
        company_id: session.company_id,
        source_type: "connector_sync",
        source_provider: session.provider,
        source_id: session.external_connection_id,
        title: `${session.provider} sync`,
        content: `Synced connection metadata for ${session.provider}. Real content sync requires provider-specific Composio tools.`,
        metadata: session.metadata || {},
        synced_at: new Date().toISOString()
      });

      await supabaseAdmin
        .from("connector_sync_jobs")
        .update({
          status: "completed",
          last_synced_at: new Date().toISOString(),
          next_sync_at: new Date(Date.now() + 20 * 60 * 1000).toISOString()
        })
        .eq("connector_session_id", session.id);
    }

    return NextResponse.json({
      ok: true,
      synced: sessions?.length || 0
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
