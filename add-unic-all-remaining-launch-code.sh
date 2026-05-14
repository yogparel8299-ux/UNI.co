#!/bin/bash
set -e

echo "Adding all remaining UNIC.ai launch code..."

mkdir -p app/{dataset-lab,marketplace-seller,notifications,usage-dashboard,worker-health,secret-manager,realtime-stream}
mkdir -p app/api/{dataset-ingest,dataset-search,stripe-checkout,stripe-webhook,razorpay-order,razorpay-webhook,marketplace-publish,marketplace-rent,marketplace-review,enforce-limit,notify,stream-event,secret-delete,secret-list,worker-heartbeat}
mkdir -p lib/{billing,datasets,limits,notifications,realtime}
mkdir -p workers

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json","utf8"));
pkg.dependencies = pkg.dependencies || {};
pkg.dependencies.stripe = "latest";
pkg.dependencies.razorpay = "latest";
pkg.dependencies.pdf_parse = "npm:pdf-parse";
pkg.dependencies.mammoth = "latest";
fs.writeFileSync("package.json", JSON.stringify(pkg,null,2));
NODE

cat > lib/datasets/chunk.ts <<'TS'
export function chunkText(text: string, size = 1200, overlap = 150) {
  const clean = text.replace(/\s+/g, " ").trim();
  const chunks: string[] = [];
  let index = 0;

  while (index < clean.length) {
    chunks.push(clean.slice(index, index + size));
    index += size - overlap;
  }

  return chunks.filter(Boolean);
}
TS

cat > lib/datasets/embed.ts <<'TS'
import OpenAI from "openai";

export async function embedText(text: string) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY missing.");

  const openai = new OpenAI({ apiKey });

  const res = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: text.slice(0, 8000)
  });

  return res.data[0].embedding;
}
TS

cat > lib/limits/enforce.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function enforceCompanyLimit(companyId: string, limitType: "agents" | "workflows" | "datasets" | "runs") {
  const { data: billing } = await supabaseAdmin
    .from("billing_accounts")
    .select("*")
    .eq("company_id", companyId)
    .single();

  const plan = billing?.plan || "starter";

  const { data: limits } = await supabaseAdmin
    .from("plan_limits")
    .select("*")
    .eq("plan_slug", plan)
    .single();

  if (!limits) return { allowed: true };

  const tableMap: any = {
    agents: "agents",
    workflows: "workflow_builders",
    datasets: "datasets",
    runs: "agent_runs"
  };

  const columnMap: any = {
    agents: "max_agents",
    workflows: "max_workflows",
    datasets: "max_datasets",
    runs: "max_monthly_runs"
  };

  const { count } = await supabaseAdmin
    .from(tableMap[limitType])
    .select("*", { count: "exact", head: true })
    .eq("company_id", companyId);

  const max = Number(limits[columnMap[limitType]] || 0);

  return {
    allowed: Number(count || 0) < max,
    used: count || 0,
    max,
    plan
  };
}
TS

cat > lib/notifications/create.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function createNotification(companyId: string, title: string, body: string, metadata: any = {}) {
  const { data } = await supabaseAdmin
    .from("notifications")
    .insert({
      company_id: companyId,
      title,
      body,
      metadata
    })
    .select()
    .single();

  return data;
}
TS

cat > lib/realtime/stream.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function streamEvent(companyId: string, event: string, payload: any, entityType?: string, entityId?: string) {
  const { data } = await supabaseAdmin.from("realtime_streams").insert({
    company_id: companyId,
    event,
    payload,
    entity_type: entityType || null,
    entity_id: entityId || null,
    stream_type: "runtime"
  }).select().single();

  return data;
}
TS

cat > app/api/dataset-ingest/route.ts <<'TS'
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
TS

cat > app/api/dataset-search/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { embedText } from "@/lib/datasets/embed";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const embedding = await embedText(body.query);

    const { data, error } = await supabaseAdmin.rpc("match_dataset_chunks", {
      query_embedding: embedding,
      match_company_id: body.company_id,
      match_count: body.match_count || 10
    });

    if (error) throw error;

    return NextResponse.json({ ok: true, results: data || [] });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/stripe-checkout/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "");

    const session = await stripe.checkout.sessions.create({
      mode: body.mode || "payment",
      success_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?success=true`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/packs?cancel=true`,
      line_items: [{
        price_data: {
          currency: body.currency || "usd",
          product_data: { name: body.name || "UNIC.ai Credits" },
          unit_amount: Math.round(Number(body.amount || 10) * 100)
        },
        quantity: 1
      }],
      metadata: {
        company_id: body.company_id,
        pack_id: body.pack_id || "",
        credits: String(body.credits || 0)
      }
    });

    await supabaseAdmin.from("payment_checkouts").insert({
      company_id: body.company_id,
      provider: "stripe",
      checkout_type: body.mode || "payment",
      provider_session_id: session.id,
      amount: body.amount || 0,
      currency: body.currency || "usd",
      status: "created",
      metadata: { url: session.url, credits: body.credits || 0 }
    });

    return NextResponse.json({ ok: true, url: session.url });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/stripe-webhook/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "");
    const raw = await req.text();
    const sig = req.headers.get("stripe-signature") || "";
    const secret = process.env.STRIPE_WEBHOOK_SECRET || "";

    const event = secret
      ? stripe.webhooks.constructEvent(raw, sig, secret)
      : JSON.parse(raw);

    await supabaseAdmin.from("webhook_events").insert({
      provider: "stripe",
      event_type: event.type,
      payload: event,
      processed: false
    });

    if (event.type === "checkout.session.completed") {
      const session: any = event.data.object;
      const companyId = session.metadata?.company_id;
      const credits = Number(session.metadata?.credits || 0);

      if (companyId && credits > 0) {
        const { data: wallet } = await supabaseAdmin.from("company_credit_wallets").select("*").eq("company_id", companyId).single();
        const newBalance = Number(wallet?.balance || 0) + credits;

        if (wallet) {
          await supabaseAdmin.from("company_credit_wallets").update({
            balance: newBalance,
            lifetime_purchased: Number(wallet.lifetime_purchased || 0) + credits
          }).eq("company_id", companyId);
        } else {
          await supabaseAdmin.from("company_credit_wallets").insert({
            company_id: companyId,
            balance: credits,
            lifetime_purchased: credits
          });
        }

        await supabaseAdmin.from("credit_ledger").insert({
          company_id: companyId,
          event_type: "stripe_credit_purchase",
          amount: credits,
          balance_after: newBalance,
          metadata: { session_id: session.id }
        });
      }
    }

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 400 });
  }
}
TS

cat > app/api/razorpay-order/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import Razorpay from "razorpay";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || "",
      key_secret: process.env.RAZORPAY_KEY_SECRET || ""
    });

    const order = await razorpay.orders.create({
      amount: Math.round(Number(body.amount || 100) * 100),
      currency: body.currency || "INR",
      receipt: `unic_${Date.now()}`,
      notes: {
        company_id: body.company_id,
        credits: String(body.credits || 0)
      }
    });

    await supabaseAdmin.from("payment_checkouts").insert({
      company_id: body.company_id,
      provider: "razorpay",
      checkout_type: "payment",
      provider_session_id: order.id,
      amount: body.amount || 0,
      currency: body.currency || "INR",
      status: "created",
      metadata: { order, credits: body.credits || 0 }
    });

    return NextResponse.json({ ok: true, order });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/razorpay-webhook/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const payload = await req.json();

    await supabaseAdmin.from("webhook_events").insert({
      provider: "razorpay",
      event_type: payload.event || "unknown",
      payload,
      processed: false
    });

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/marketplace-publish/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin.from("marketplace_listings").insert({
      company_id: body.company_id,
      agent_id: body.agent_id || null,
      dataset_id: body.dataset_id || null,
      listing_type: body.listing_type,
      title: body.title,
      description: body.description,
      price: body.price || 0,
      status: "active"
    }).select().single();

    if (error) throw error;

    return NextResponse.json({ ok: true, listing: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/marketplace-rent/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data: listing } = await supabaseAdmin.from("marketplace_listings").select("*").eq("id", body.listing_id).single();

    const { data: order } = await supabaseAdmin.from("marketplace_orders").insert({
      buyer_company_id: body.buyer_company_id,
      seller_company_id: listing.company_id,
      listing_id: listing.id,
      amount: listing.price,
      status: "completed"
    }).select().single();

    const { data: entitlement } = await supabaseAdmin.from("marketplace_entitlements").insert({
      company_id: body.buyer_company_id,
      listing_id: listing.id,
      order_id: order.id,
      entitlement_type: "rental",
      status: "active",
      expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
    }).select().single();

    await supabaseAdmin.from("marketplace_payouts").insert({
      seller_company_id: listing.company_id,
      order_id: order.id,
      gross_amount: listing.price,
      platform_fee: Number(listing.price || 0) * 0.2,
      net_amount: Number(listing.price || 0) * 0.8,
      status: "pending"
    });

    return NextResponse.json({ ok: true, order, entitlement });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/marketplace-review/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    const { data, error } = await supabaseAdmin.from("marketplace_reviews").insert({
      listing_id: body.listing_id,
      company_id: body.company_id,
      rating: body.rating,
      review: body.review
    }).select().single();

    if (error) throw error;

    return NextResponse.json({ ok: true, review: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/enforce-limit/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { enforceCompanyLimit } from "@/lib/limits/enforce";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const result = await enforceCompanyLimit(body.company_id, body.limit_type);
    return NextResponse.json({ ok: true, result });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/notify/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { createNotification } from "@/lib/notifications/create";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const notification = await createNotification(body.company_id, body.title, body.body, body.metadata || {});
    return NextResponse.json({ ok: true, notification });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/stream-event/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { streamEvent } from "@/lib/realtime/stream";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const event = await streamEvent(body.company_id, body.event, body.payload || {}, body.entity_type, body.entity_id);
    return NextResponse.json({ ok: true, event });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/secret-list/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  const body = await req.json();

  const { data, error } = await supabaseAdmin
    .from("encrypted_secrets")
    .select("id, company_id, provider, secret_name, secret_type, status, created_at")
    .eq("company_id", body.company_id)
    .order("created_at", { ascending: false });

  if (error) return NextResponse.json({ ok: false, error: error.message }, { status: 500 });

  return NextResponse.json({ ok: true, secrets: data || [] });
}
TS

cat > app/api/secret-delete/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  const body = await req.json();

  const { error } = await supabaseAdmin
    .from("encrypted_secrets")
    .update({ status: "revoked" })
    .eq("id", body.secret_id);

  if (error) return NextResponse.json({ ok: false, error: error.message }, { status: 500 });

  return NextResponse.json({ ok: true });
}
TS

cat > app/api/worker-heartbeat/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  const body = await req.json();

  const { data, error } = await supabaseAdmin.from("worker_health").upsert({
    worker_name: body.worker_name,
    status: body.status || "online",
    last_heartbeat: new Date().toISOString(),
    metadata: body.metadata || {}
  }, { onConflict: "worker_name" }).select().single();

  if (error) return NextResponse.json({ ok: false, error: error.message }, { status: 500 });

  return NextResponse.json({ ok: true, worker: data });
}
TS

cat > app/dataset-lab/page.tsx <<'TSX'
"use client";
import { useState } from "react";

export default function DatasetLab() {
  const [companyId, setCompanyId] = useState("");
  const [datasetId, setDatasetId] = useState("");
  const [content, setContent] = useState("");
  const [query, setQuery] = useState("");
  const [result, setResult] = useState("");

  async function ingest() {
    const res = await fetch("/api/dataset-ingest", {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ company_id: companyId, dataset_id: datasetId, content })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  async function search() {
    const res = await fetch("/api/dataset-search", {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ company_id: companyId, query })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Dataset Lab</h1>
        <p className="page-subtitle">Ingest text, create chunks, embed them and search with RAG.</p>
        <div className="glass-card p-8 mt-10 max-w-4xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={e=>setCompanyId(e.target.value)} />
          <input className="input-box mt-4" placeholder="Dataset ID" value={datasetId} onChange={e=>setDatasetId(e.target.value)} />
          <textarea className="input-box mt-4 min-h-[160px]" placeholder="Dataset content" value={content} onChange={e=>setContent(e.target.value)} />
          <button className="primary-button mt-4" onClick={ingest}>Ingest Dataset</button>
          <textarea className="input-box mt-8 min-h-[100px]" placeholder="Search query" value={query} onChange={e=>setQuery(e.target.value)} />
          <button className="primary-button mt-4" onClick={search}>Search Dataset</button>
          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/marketplace-seller/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function MarketplaceSeller() {
  const { data } = await supabaseAdmin.from("marketplace_payouts").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Marketplace Seller" subtitle="Seller payouts, revenue share and marketplace monetization."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > app/notifications/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function Notifications() {
  const { data } = await supabaseAdmin.from("notifications").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Notifications" subtitle="System alerts, workflow updates, billing notices and agent events."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > app/usage-dashboard/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import Card from "@/components/Card";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function UsageDashboard() {
  const tables = ["usage_events", "credit_ledger", "agent_runs", "tool_executions"];
  const counts: any = {};

  for (const table of tables) {
    const { count } = await supabaseAdmin.from(table).select("*", { count: "exact", head: true });
    counts[table] = count || 0;
  }

  return (
    <Shell title="Usage Dashboard" subtitle="Credits, runs, tool executions and cost control.">
      <div className="grid grid-cols-4 gap-6">
        <Card title="Usage Events" value={counts.usage_events} />
        <Card title="Credit Ledger" value={counts.credit_ledger} />
        <Card title="Agent Runs" value={counts.agent_runs} />
        <Card title="Tool Executions" value={counts.tool_executions} />
      </div>
    </Shell>
  );
}
TSX

cat > app/worker-health/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function WorkerHealth() {
  const { data } = await supabaseAdmin.from("worker_health").select("*").order("last_heartbeat", { ascending: false });
  return <Shell title="Worker Health" subtitle="Runtime, super-worker and connection-worker status."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > app/secret-manager/page.tsx <<'TSX'
"use client";
import { useState } from "react";

export default function SecretManager() {
  const [companyId, setCompanyId] = useState("");
  const [result, setResult] = useState("");

  async function load() {
    const res = await fetch("/api/secret-list", {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ company_id: companyId })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Secret Manager</h1>
        <p className="page-subtitle">View masked provider keys and revoke them safely.</p>
        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={e=>setCompanyId(e.target.value)} />
          <button className="primary-button mt-4" onClick={load}>Load Secrets</button>
          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/realtime-stream/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import DataTable from "@/components/DataTable";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function RealtimeStream() {
  const { data } = await supabaseAdmin.from("realtime_streams").select("*").order("created_at", { ascending: false }).limit(100);
  return <Shell title="Realtime Stream" subtitle="Live event feed for tasks, agents, workflows and tools."><DataTable rows={data || []} /></Shell>;
}
TSX

cat > workers/launch-worker.js <<'JS'
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function heartbeat(name) {
  await supabase.from("worker_health").upsert({
    worker_name: name,
    status: "online",
    last_heartbeat: new Date().toISOString(),
    metadata: { pid: process.pid }
  }, { onConflict: "worker_name" });
}

async function tick() {
  await heartbeat("launch-worker");
  console.log("launch-worker heartbeat", new Date().toISOString());
}

setInterval(tick, 30000);
tick();
JS

python3 - <<'PY'
from pathlib import Path
p = Path("components/Nav.tsx")
s = p.read_text()
items = [
  '["Dataset Lab", "/dataset-lab"],',
  '["Marketplace Seller", "/marketplace-seller"],',
  '["Notifications", "/notifications"],',
  '["Usage Dashboard", "/usage-dashboard"],',
  '["Worker Health", "/worker-health"],',
  '["Secret Manager", "/secret-manager"],',
  '["Realtime Stream", "/realtime-stream"],'
]
for item in items:
    if item not in s:
        s = s.replace('["Settings", "/settings"]', item + '\n  ["Settings", "/settings"]')
p.write_text(s)
PY

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json","utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts["launch-worker"] = "node workers/launch-worker.js";
fs.writeFileSync("package.json", JSON.stringify(pkg,null,2));
NODE

npm install

git add .
git commit -m "Add all remaining UNIC.ai launch code systems" || true

echo "DONE: all remaining UNIC.ai launch code added."
