export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { requireProvider } from "@/lib/guards/providers";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createEmbedding } from "@/lib/memory/embedding";

export async function POST(req: NextRequest) {
  try {
    requireProvider("openai");
    const body = await req.json();
    const embedding = await createEmbedding(body.content);

    const { data, error } = await supabaseAdmin
      .from("memory_tree")
      .insert({
        company_id: body.company_id,
        source_type: body.source_type || "manual",
        source_provider: body.source_provider || "unic",
        source_id: body.source_id || null,
        title: body.title || "Memory",
        content: body.content,
        embedding,
        synced_at: new Date().toISOString(),
        metadata: body.metadata || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, memory: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
