import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function GET() {
  const { data, error } = await supabaseAdmin
    .from("tool_registry")
    .select("*")
    .eq("enabled", true)
    .order("provider", { ascending: true });

  if (error) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }

  return NextResponse.json({
    ok: true,
    tools: (data || []).map((tool) => ({
      name: `${tool.provider}.${tool.tool_slug}`,
      description: tool.description,
      input_schema: tool.input_schema || {}
    }))
  });
}
