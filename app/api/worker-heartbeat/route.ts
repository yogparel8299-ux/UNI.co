import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  const body = await req.json();

  const { data, error } = await supabaseAdmin.from("worker_health").upsert({
    worker_name: body.worker_name,
    status: body.status || "online",
    last_heartbeat: new Date().toISOString(),
    metadata: body.metadata || {}
  }, { onConflict: "worker_name" }).select().single();

  if (error) return NextResponse.json({ ok: false, error: error.message }, { status: 500 });

  return NextResponse.json({ ok: true, worker: data });
}
