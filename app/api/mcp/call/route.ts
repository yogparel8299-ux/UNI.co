export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { executeTool } from "@/lib/connection/composio";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const [provider, toolSlug] = String(body.name || "").split(".");

    if (!provider || !toolSlug) {
      return NextResponse.json(
        { ok: false, error: "Tool name must be provider.tool_slug." },
        { status: 400 }
      );
    }

    const output = await executeTool({
      userId: body.user_id,
      toolkit: provider,
      toolSlug,
      args: body.arguments || {}
    });

    return NextResponse.json({
      ok: true,
      output
    });
  } catch (error: any) {
    return NextResponse.json(
      { ok: false, error: error.message },
      { status: 500 }
    );
  }
}
