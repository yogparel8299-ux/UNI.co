import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("command_history")
      .insert({
        company_id: body.company_id,
        user_id: body.user_id || null,
        command: body.command,
        response: body.response || {},
        status: body.status || "completed"
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      command: data
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
