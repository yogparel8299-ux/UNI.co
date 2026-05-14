export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { createComposioAuthLink } from "@/lib/composio/client";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const link = await createComposioAuthLink({
      userId: body.user_id,
      toolkit: body.toolkit,
      redirectUrl: body.redirect_url
    });

    await supabaseAdmin.from("connector_accounts").insert({
      company_id: body.company_id,
      provider: body.toolkit,
      connection_id: link.connected_account_id || link.connection_id || null,
      auth_provider: "composio",
      status: "pending",
      metadata: link
    });

    return NextResponse.json({ ok: true, link });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
