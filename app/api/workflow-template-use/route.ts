import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: template, error: templateError } = await supabaseAdmin
      .from("workflow_templates")
      .select("*")
      .eq("id", body.template_id)
      .single();

    if (templateError) throw templateError;

    const { data: workflow, error: workflowError } = await supabaseAdmin
      .from("workflow_builders")
      .insert({
        company_id: body.company_id,
        name: template.title,
        graph: template.template_graph,
        status: "draft"
      })
      .select()
      .single();

    if (workflowError) throw workflowError;

    return NextResponse.json({
      ok: true,
      workflow
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      {
        status: 500
      }
    );
  }
}
