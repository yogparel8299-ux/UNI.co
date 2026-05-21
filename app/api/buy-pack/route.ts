export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function GET() {
  return NextResponse.json({ ok: true, route: "buy-pack", methods: ["POST"] });
}

export async function POST(req: NextRequest) {
  try {
    requireProvider("stripe");
    const body = await req.json();

    if (!body.company_id || !body.pack_id) {
      return NextResponse.json({ ok: false, error: "company_id and pack_id are required." }, { status: 400 });
    }

    const { data: pack, error: packError } = await supabaseAdmin
      .from("credit_packs")
      .select("*")
      .eq("id", body.pack_id)
      .single();

    if (packError) throw packError;

    const totalCredits = Number(pack.credits || 0) + Number(pack.bonus_credits || 0);

    return NextResponse.json({
      ok: true,
      message: "Use Stripe/Razorpay webhook to confirm payment before adding credits.",
      pack,
      totalCredits
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message || "Buy pack failed." }, { status: 500 });
  }
}
