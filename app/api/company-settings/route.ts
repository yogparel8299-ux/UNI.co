import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("company_settings")
      .upsert(
        {
          company_id: body.company_id,
          brand_name: body.brand_name || "UNIC.ai",
          theme: body.theme || "light",
          default_model_provider: body.default_model_provider || "openai",
          default_model: body.default_model || "gpt-4o-mini",
          enable_marketplace: body.enable_marketplace ?? true,
          enable_connectors: body.enable_connectors ?? true,
          enable_swarm_mode: body.enable_swarm_mode ?? true,
          enable_billing: body.enable_billing ?? true,
          settings: body.settings || {}
        },
        {
          onConflict: "company_id"
        }
      )
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      settings: data
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
