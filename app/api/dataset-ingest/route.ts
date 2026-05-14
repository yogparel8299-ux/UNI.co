import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { chunkText } from "@/lib/datasets/chunk";
import { embedText } from "@/lib/datasets/embed";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.dataset_id || !body.content) {
      return NextResponse.json({ ok: false, error: "company_id, dataset_id and content required." }, { status: 400 });
    }

    const { data: job } = await supabaseAdmin.from("ingestion_jobs").insert({
      company_id: body.company_id,
      dataset_id: body.dataset_id,
      status: "running",
      file_type: body.file_type || "text",
      metadata: body.metadata || {}
    }).select().single();

    const chunks = chunkText(body.content);
    const inserted = [];

    for (let i = 0; i < chunks.length; i++) {
      const embedding = await embedText(chunks[i]);

      const { data } = await supabaseAdmin.from("dataset_chunks").insert({
        company_id: body.company_id,
        dataset_id: body.dataset_id,
        chunk_index: i,
        content: chunks[i],
        token_count: Math.ceil(chunks[i].length / 4),
        embedding,
        metadata: { ingestion_job_id: job.id }
      }).select().single();

      inserted.push(data);
    }

    await supabaseAdmin.from("ingestion_jobs").update({
      status: "completed",
      completed_at: new Date().toISOString()
    }).eq("id", job.id);

    return NextResponse.json({ ok: true, job, chunks: inserted.length });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
