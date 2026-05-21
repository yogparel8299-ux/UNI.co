export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { getProviderStatus } from "@/lib/guards/providers";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.title) {
      return NextResponse.json(
        { ok: false, error: "company_id and title are required." },
        { status: 400 }
      );
    }

    const providerStatus = getProviderStatus();

    const { data, error } = await supabaseAdmin
      .from("datasets")
      .insert({
        company_id: body.company_id,
        title: body.title,
        description: body.description || "",
        status: providerStatus.openai ? "queued_for_embedding" : "uploaded_no_embedding_key",
        storage_path: body.storage_path || null,
        metadata: {
          file_type: body.file_type || "unknown",
          size_bytes: body.size_bytes || 0,
          embedding_ready: providerStatus.openai
        }
      })
      .select()
      .single();

    if (error) throw error;

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      event_type: "dataset_uploaded",
      message: `${body.title} dataset record created.`,
      metadata: { dataset_id: data.id, embedding_ready: providerStatus.openai }
    }).then(() => {});

    return NextResponse.json({
      ok: true,
      dataset: data,
      embedding_enabled: providerStatus.openai
    });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
