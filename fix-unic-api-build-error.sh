#!/bin/bash
set -e

echo "Fixing UNIC.ai API build error..."

mkdir -p app/api/audit-log

cat > app/api/audit-log/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export const dynamic = "force-dynamic";
export const runtime = "nodejs";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.event_type) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id and event_type are required."
        },
        {
          status: 400
        }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("audit_events")
      .insert({
        company_id: body.company_id,
        actor_id: body.actor_id || null,
        event_type: body.event_type,
        risk_level: body.risk_level || "low",
        entity_type: body.entity_type || null,
        entity_id: body.entity_id || null,
        metadata: body.metadata || {},
        ip_address: body.ip_address || null,
        user_agent: body.user_agent || null
      })
      .select()
      .single();

    if (error) {
      throw error;
    }

    return NextResponse.json({
      ok: true,
      audit_event: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Audit log failed."
      },
      {
        status: 500
      }
    );
  }
}

export async function GET() {
  return NextResponse.json({
    ok: true,
    route: "audit-log",
    methods: ["POST"]
  });
}
TS

python3 - <<'PY'
from pathlib import Path

api_dirs = [
    "app/api/command/route.ts",
    "app/api/queue/route.ts",
    "app/api/onboarding/route.ts",
    "app/api/save-secret/route.ts",
    "app/api/router-run/route.ts",
    "app/api/connector-connect/route.ts",
    "app/api/composio-link/route.ts",
    "app/api/tool-execute/route.ts",
    "app/api/trigger-event/route.ts",
    "app/api/embed-text/route.ts",
    "app/api/rag-search/route.ts",
    "app/api/dataset-upload/route.ts",
    "app/api/dataset-ingest/route.ts",
    "app/api/dataset-search/route.ts",
    "app/api/stripe-checkout/route.ts",
    "app/api/stripe-webhook/route.ts",
    "app/api/razorpay-order/route.ts",
    "app/api/razorpay-webhook/route.ts",
    "app/api/marketplace-buy/route.ts",
    "app/api/marketplace-publish/route.ts",
    "app/api/marketplace-rent/route.ts",
    "app/api/marketplace-review/route.ts",
    "app/api/buy-credits/route.ts",
    "app/api/team-accept/route.ts",
    "app/api/workflow-run/route.ts",
    "app/api/swarm-run/route.ts",
    "app/api/rate-limit-check/route.ts",
    "app/api/command-save/route.ts",
    "app/api/company-settings/route.ts",
    "app/api/workflow-template-use/route.ts",
    "app/api/brain-query/route.ts",
    "app/api/connection-link/route.ts",
    "app/api/connection-callback/route.ts",
    "app/api/connection-tools/route.ts",
    "app/api/connection-tool-call/route.ts",
    "app/api/connection-sync/route.ts",
    "app/api/mcp/tools/route.ts",
    "app/api/mcp/call/route.ts",
    "app/api/enforce-limit/route.ts",
    "app/api/notify/route.ts",
    "app/api/stream-event/route.ts",
    "app/api/secret-list/route.ts",
    "app/api/secret-delete/route.ts",
    "app/api/worker-heartbeat/route.ts"
]

for file in api_dirs:
    path = Path(file)
    if not path.exists():
        continue

    text = path.read_text()

    if 'export const dynamic = "force-dynamic";' not in text:
        text = text.replace(
            'import ',
            'export const dynamic = "force-dynamic";\nexport const runtime = "nodejs";\n\nimport ',
            1
        )

    path.write_text(text)
PY

npm run build

git add .
git commit -m "Fix API route build error" || true

echo "DONE: API build error fixed."
