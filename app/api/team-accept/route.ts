export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: invite, error } = await supabaseAdmin
      .from("team_invites")
      .select("*")
      .eq("id", body.invite_id)
      .eq("status", "pending")
      .single();

    if (error) throw error;

    await supabaseAdmin.from("company_members").insert({
      company_id: invite.company_id,
      user_id: body.user_id,
      role: invite.role || "member"
    });

    await supabaseAdmin.from("team_invites").update({ status: "accepted" }).eq("id", invite.id);

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
