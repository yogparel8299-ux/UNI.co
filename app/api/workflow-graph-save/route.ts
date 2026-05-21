export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.title || !body.graph) {
      return NextResponse.json(
        { ok: false, error: "company_id, title and graph are required." },
        { status: 400 }
      );
    }

    const payload = {
      company_id: body.company_id,
      title: body.title,
      graph: body.graph,
      status: body.status || "draft",
      updated_at: new Date().toISOString()
    };

    let result;

    if (body.id) {
      result = await supabaseAdmin
        .from("workflow_graphs")
        .update(payload)
        .eq("id", body.id)
        .eq("company_id", body.company_id)
        .select()
        .single();
    } else {
      result = await supabaseAdmin
        .from("workflow_graphs")
        .insert(payload)
        .select()
        .single();
    }

    if (result.error) throw result.error;

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      event_type: "workflow_saved",
      message: `${body.title} workflow graph saved.`,
      metadata: { workflow_graph_id: result.data.id }
    }).then(() => {});

    return NextResponse.json({ ok: true, workflow: result.data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
