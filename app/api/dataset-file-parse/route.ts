export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { parseUploadedFile } from "@/lib/datasets/parse-file";
import { chunkText } from "@/lib/datasets/chunk";
import { embedText } from "@/lib/datasets/embed";

export async function POST(req: NextRequest) {
  try {
    const form = await req.formData();
    const companyId = String(form.get("company_id") || "");
    const datasetId = String(form.get("dataset_id") || "");
    const file = form.get("file") as File | null;

    if (!companyId || !datasetId || !file) {
      return NextResponse.json({ ok: false, error: "company_id, dataset_id and file are required." }, { status: 400 });
    }

    const text = await parseUploadedFile(file);

    const { data: job, error: jobError } = await supabaseAdmin
      .from("ingestion_jobs")
      .insert({
        company_id: companyId,
        dataset_id: datasetId,
        status: "running",
        file_type: file.type || "unknown",
        metadata: { file_name: file.name }
      })
      .select()
      .single();

    if (jobError) throw jobError;

    const chunks = chunkText(text);
    let created = 0;

    for (let i = 0; i < chunks.length; i++) {
      const embedding = await embedText(chunks[i]);

      await supabaseAdmin.from("dataset_chunks").insert({
        company_id: companyId,
        dataset_id: datasetId,
        chunk_index: i,
        content: chunks[i],
        token_count: Math.ceil(chunks[i].length / 4),
        embedding,
        metadata: { ingestion_job_id: job.id, file_name: file.name }
      });

      created++;
    }

    await supabaseAdmin
      .from("ingestion_jobs")
      .update({ status: "completed", completed_at: new Date().toISOString() })
      .eq("id", job.id);

    return NextResponse.json({ ok: true, file_name: file.name, chunks: created });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message || "File parse failed." }, { status: 500 });
  }
}
