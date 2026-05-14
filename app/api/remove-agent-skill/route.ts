export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.assignment_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "assignment_id is required."
        },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("agent_skill_assignments")
      .update({
        enabled: false
      })
      .eq("id", body.assignment_id)
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
        error: error.message || "Remove skill failed."
      },
      { status: 500 }
    );
  }
}
