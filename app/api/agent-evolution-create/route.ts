export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.agent_id || !body.title) {
      return NextResponse.json(
        { ok: false, error: "company_id, agent_id and title are required." },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("agent_evolution_suggestions")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id,
        title: body.title,
        description: body.description || "",
        suggestion_type: body.suggestion_type || "prompt_improvement",
        before_config: body.before_config || {},
        after_config: body.after_config || {},
        status: "pending"
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, suggestion: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
