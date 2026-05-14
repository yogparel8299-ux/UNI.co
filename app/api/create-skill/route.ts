export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

function slugify(input: string) {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.title || !body.system_prompt) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id, title and system_prompt are required."
        },
        { status: 400 }
      );
    }

    const slug = body.slug || slugify(body.title);

    const { data, error } = await supabaseAdmin
      .from("company_skills")
      .insert({
        company_id: body.company_id,
        title: body.title,
        slug,
        category: body.category || "custom",
        description: body.description || "",
        system_prompt: body.system_prompt,
        tools: body.tools || [],
        model: body.model || "gpt-4o-mini",
        visibility: body.visibility || "private",
        created_by: body.user_id || null,
        active: true
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      skill: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Create skill failed."
      },
      { status: 500 }
    );
  }
}
