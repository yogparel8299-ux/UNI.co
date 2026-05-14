import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    let query = supabaseAdmin
      .from("tool_registry")
      .select("*")
      .eq("enabled", true);

    if (body.provider) {
      query = query.eq("provider", body.provider);
    }

    const { data, error } = await query.order("provider", { ascending: true });

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      tools: data || []
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
