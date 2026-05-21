export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

function chunkText(text: string, size = 1200) {
  const chunks: string[] = [];
  for (let i = 0; i < text.length; i += size) {
    chunks.push(text.slice(i, i + size));
  }
  return chunks;
}

async function embed(text: string) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) return null;

  const res = await fetch("https://api.openai.com/v1/embeddings", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: "text-embedding-3-small",
      input: text
    })
  });

  const json = await res.json();
  return json?.data?.[0]?.embedding || null;
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.dataset_id || !body.text) {
      return NextResponse.json(
        { ok: false, error: "company_id, dataset_id and text are required." },
        { status: 400 }
      );
    }

    const chunks = chunkText(body.text);

    for (let i = 0; i < chunks.length; i++) {
      const content = chunks[i];
      const embedding = await embed(content);

      await supabaseAdmin.from("dataset_chunks").insert({
        company_id: body.company_id,
        dataset_id: body.dataset_id,
        chunk_index: i,
        content,
        embedding,
        metadata: { embedding_created: !!embedding }
      });
    }

    await supabaseAdmin
      .from("datasets")
      .update({ status: process.env.OPENAI_API_KEY ? "embedded" : "chunked_no_embedding_key" })
      .eq("id", body.dataset_id)
      .eq("company_id", body.company_id);

    return NextResponse.json({ ok: true, chunks: chunks.length, embedded: !!process.env.OPENAI_API_KEY });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
