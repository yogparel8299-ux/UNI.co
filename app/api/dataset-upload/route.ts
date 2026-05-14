import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const form = await req.formData();
    const companyId = String(form.get("company_id"));
    const datasetId = String(form.get("dataset_id"));
    const file = form.get("file") as File;

    if (!companyId || !datasetId || !file) {
      return NextResponse.json({ ok: false, error: "company_id, dataset_id and file required." }, { status: 400 });
    }

    const path = `${companyId}/${datasetId}/${Date.now()}-${file.name}`;
    const arrayBuffer = await file.arrayBuffer();

    const { error } = await supabaseAdmin.storage
      .from("datasets")
      .upload(path, Buffer.from(arrayBuffer), {
        contentType: file.type,
        upsert: true
      });

    if (error) throw error;

    const { data } = await supabaseAdmin.from("dataset_files").insert({
      company_id: companyId,
      dataset_id: datasetId,
      file_name: file.name,
      file_url: path,
      file_type: file.type,
      status: "uploaded"
    }).select().single();

    await supabaseAdmin.from("storage_files").insert({
      company_id: companyId,
      bucket: "datasets",
      path,
      file_name: file.name,
      file_type: file.type,
      size_bytes: file.size
    });

    return NextResponse.json({ ok: true, file: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
