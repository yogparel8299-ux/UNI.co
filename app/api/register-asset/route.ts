import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin
      .from("asset_registry")
      .insert({
        company_id: body.company_id,
        asset_type: body.asset_type,
        asset_id: body.asset_id,
        title: body.title,
        ownership_model: body.ownership_model || "platform_owned",
        platform_owner: "UNIC.ai",
        customer_license: body.customer_license || "usage_license",
        enterprise_transferable: !!body.enterprise_transferable,
        metadata: body.metadata || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, asset: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
