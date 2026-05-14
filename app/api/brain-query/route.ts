import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { embedText } from "@/lib/datasets/embed";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const embedding = await embedText(body.query);

    const memory = await supabaseAdmin.rpc("match_memory", {
      query_embedding: embedding,
      match_company_id: body.company_id,
      match_count: body.match_count || 8
    });

    const datasets = await supabaseAdmin.rpc("match_dataset_chunks", {
      query_embedding: embedding,
      match_company_id: body.company_id,
      match_count: body.match_count || 8
    });

    return NextResponse.json({
      ok: true,
      memory: memory.data || [],
      datasets: datasets.data || []
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message
      },
      {
        status: 500
      }
    );
  }
}
