export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.suggestion_id || !body.decision) {
      return NextResponse.json(
        { ok: false, error: "company_id, suggestion_id and decision are required." },
        { status: 400 }
      );
    }

    const status = body.decision === "approve" ? "approved" : "rejected";

    const { data, error } = await supabaseAdmin
      .from("agent_evolution_suggestions")
      .update({
        status,
        reviewed_by: body.user_id || null,
        reviewed_at: new Date().toISOString()
      })
      .eq("id", body.suggestion_id)
      .eq("company_id", body.company_id)
      .select()
      .single();

    if (error) throw error;

    if (status === "approved" && data?.agent_id && data?.after_config) {
      await supabaseAdmin
        .from("agent_versions")
        .insert({
          company_id: body.company_id,
          agent_id: data.agent_id,
          version_notes: data.title,
          config_snapshot: data.after_config
        })
        .then(() => {});
    }

    return NextResponse.json({ ok: true, suggestion: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
