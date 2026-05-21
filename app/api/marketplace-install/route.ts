export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.asset_type || !body.asset_title) {
      return NextResponse.json(
        { ok: false, error: "company_id, asset_type and asset_title are required." },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("marketplace_installs")
      .insert({
        company_id: body.company_id,
        listing_id: body.listing_id || null,
        asset_type: body.asset_type,
        asset_title: body.asset_title,
        installed_by: body.user_id || null,
        status: "installed",
        metadata: body.metadata || {}
      })
      .select()
      .single();

    if (error) throw error;

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      event_type: "marketplace_asset_installed",
      message: `${body.asset_title} installed from marketplace.`,
      metadata: { install_id: data.id }
    }).then(() => {});

    return NextResponse.json({ ok: true, install: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
