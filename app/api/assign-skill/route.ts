export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.agent_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id and agent_id are required."
        },
        { status: 400 }
      );
    }

    if (!body.skill_library_id && !body.company_skill_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "skill_library_id or company_skill_id is required."
        },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("agent_skill_assignments")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id,
        skill_library_id: body.skill_library_id || null,
        company_skill_id: body.company_skill_id || null,
        enabled: true,
        priority: body.priority || 100,
        config: body.config || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      assignment: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Assign skill failed."
      },
      { status: 500 }
    );
  }
}
