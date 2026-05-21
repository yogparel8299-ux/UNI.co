#!/bin/bash
set -e

echo "Adding final wiring layer for UNIC.ai..."

mkdir -p lib/server
mkdir -p app/api/{workflow-graph-save,marketplace-install,dataset-upload-record,agent-evolution-create,agent-evolution-review}
mkdir -p app/{workflow-studio,marketplace,datasets,agent-evolution}

cat > lib/server/workspace.ts <<'TS'
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

export async function createServerSupabase() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "",
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll() {}
      }
    }
  );
}

export async function getWorkspace() {
  const supabase = await createServerSupabase();

  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { supabase, user: null, companyId: null, company: null };
  }

  const { data: member } = await supabase
    .from("company_members")
    .select("company_id, companies(*)")
    .eq("user_id", user.id)
    .limit(1)
    .maybeSingle();

  return {
    supabase,
    user,
    companyId: member?.company_id || null,
    company: member?.companies || null
  };
}
TS

cat > app/api/workflow-graph-save/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.title || !body.graph) {
      return NextResponse.json(
        { ok: false, error: "company_id, title and graph are required." },
        { status: 400 }
      );
    }

    const payload = {
      company_id: body.company_id,
      title: body.title,
      graph: body.graph,
      status: body.status || "draft",
      updated_at: new Date().toISOString()
    };

    let result;

    if (body.id) {
      result = await supabaseAdmin
        .from("workflow_graphs")
        .update(payload)
        .eq("id", body.id)
        .eq("company_id", body.company_id)
        .select()
        .single();
    } else {
      result = await supabaseAdmin
        .from("workflow_graphs")
        .insert(payload)
        .select()
        .single();
    }

    if (result.error) throw result.error;

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      event_type: "workflow_saved",
      message: `${body.title} workflow graph saved.`,
      metadata: { workflow_graph_id: result.data.id }
    }).then(() => {});

    return NextResponse.json({ ok: true, workflow: result.data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/marketplace-install/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.asset_type || !body.asset_title) {
      return NextResponse.json(
        { ok: false, error: "company_id, asset_type and asset_title are required." },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("marketplace_installs")
      .insert({
        company_id: body.company_id,
        listing_id: body.listing_id || null,
        asset_type: body.asset_type,
        asset_title: body.asset_title,
        installed_by: body.user_id || null,
        status: "installed",
        metadata: body.metadata || {}
      })
      .select()
      .single();

    if (error) throw error;

    await supabaseAdmin.from("runtime_events").insert({
      company_id: body.company_id,
      event_type: "marketplace_asset_installed",
      message: `${body.asset_title} installed from marketplace.`,
      metadata: { install_id: data.id }
    }).then(() => {});

    return NextResponse.json({ ok: true, install: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/dataset-upload-record/route.ts <<'TS'
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
TS

cat > app/api/agent-evolution-create/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.agent_id || !body.title) {
      return NextResponse.json(
        { ok: false, error: "company_id, agent_id and title are required." },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("agent_evolution_suggestions")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id,
        title: body.title,
        description: body.description || "",
        suggestion_type: body.suggestion_type || "prompt_improvement",
        before_config: body.before_config || {},
        after_config: body.after_config || {},
        status: "pending"
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ ok: true, suggestion: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/api/agent-evolution-review/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.suggestion_id || !body.decision) {
      return NextResponse.json(
        { ok: false, error: "company_id, suggestion_id and decision are required." },
        { status: 400 }
      );
    }

    const status = body.decision === "approve" ? "approved" : "rejected";

    const { data, error } = await supabaseAdmin
      .from("agent_evolution_suggestions")
      .update({
        status,
        reviewed_by: body.user_id || null,
        reviewed_at: new Date().toISOString()
      })
      .eq("id", body.suggestion_id)
      .eq("company_id", body.company_id)
      .select()
      .single();

    if (error) throw error;

    if (status === "approved" && data?.agent_id && data?.after_config) {
      await supabaseAdmin
        .from("agent_versions")
        .insert({
          company_id: body.company_id,
          agent_id: data.agent_id,
          version_notes: data.title,
          config_snapshot: data.after_config
        })
        .then(() => {});
    }

    return NextResponse.json({ ok: true, suggestion: data });
  } catch (error: any) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
TS

cat > app/workflow-studio/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";

export default async function WorkflowStudioPage() {
  const { supabase, user, companyId } = await getWorkspace();

  if (!user) {
    return (
      <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6">
        <div className="rounded-3xl border border-neutral-200 bg-white p-10 text-center">
          <h1 className="text-4xl font-black">Login required</h1>
          <p className="mt-3 text-neutral-500">Login to access Workflow Studio.</p>
        </div>
      </main>
    );
  }

  const { data: workflows } = companyId
    ? await supabase.from("workflow_graphs").select("*").eq("company_id", companyId).order("updated_at", { ascending: false }).limit(10)
    : { data: [] };

  return (
    <AppShell
      title="Workflow Studio"
      subtitle="Save and load workflow graphs from Supabase."
      right={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[.16em] text-neutral-400">Graph Save</p>
          <h2 className="mt-3 text-xl font-black">Persistence enabled</h2>
          <p className="mt-4 text-sm leading-6 text-neutral-500">
            Workflow graph JSON is saved into workflow_graphs.
          </p>
          <p className="mt-4 text-xs text-neutral-400 break-all">
            company_id: {companyId || "missing workspace"}
          </p>
        </div>
      }
    >
      <div className="mb-5 grid gap-5 lg:grid-cols-[.75fr_1.25fr]">
        <div className="rounded-2xl border border-neutral-200 bg-white p-5">
          <h2 className="text-2xl font-black">Saved Graphs</h2>
          <div className="mt-5 space-y-3">
            {(workflows || []).map((wf: any) => (
              <div key={wf.id} className="rounded-xl border border-neutral-200 p-4">
                <p className="font-black">{wf.title}</p>
                <p className="mt-1 text-xs text-neutral-500">{wf.status}</p>
              </div>
            ))}
            {(!workflows || workflows.length === 0) && (
              <p className="text-sm text-neutral-500">No saved workflow graphs yet.</p>
            )}
          </div>
        </div>

        <div className="relative h-[680px] overflow-hidden rounded-2xl border border-neutral-200 bg-white">
          <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />
          <svg className="absolute inset-0 h-full w-full">
            <path d="M250 170 C330 170 310 235 365 235" fill="none" stroke="#111" strokeWidth="2" />
            <path d="M570 235 C640 235 600 150 665 150" fill="none" stroke="#111" strokeWidth="2" />
            <path d="M570 235 C640 235 600 385 665 385" fill="none" stroke="#111" strokeWidth="2" />
          </svg>
          {[
            ["Trigger", "Command", "left-[70px] top-[120px]"],
            ["Agent", "AI Worker", "left-[365px] top-[190px]"],
            ["Memory", "Company Brain", "left-[665px] top-[95px]"],
            ["Approval", "Human Review", "left-[665px] top-[330px]"]
          ].map(([type,label,pos]) => (
            <div key={label} className={`absolute ${pos} w-[190px] rounded-xl border border-neutral-300 bg-white p-4 shadow-lg`}>
              <p className="text-[11px] font-black uppercase tracking-[.14em] text-neutral-400">{type}</p>
              <h3 className="mt-2 font-black">{label}</h3>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
TSX

cat > app/marketplace/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";

const demoAssets = [
  ["AI Sales Team", "agent_pack"],
  ["Support Desk", "workflow_pack"],
  ["Research OS", "company_template"],
  ["Content Factory", "workflow_pack"],
  ["Finance Analyst", "agent_pack"],
  ["Hiring Pipeline", "workflow_pack"]
];

export default async function MarketplacePage() {
  const { supabase, user, companyId } = await getWorkspace();

  const { data: installs } = user && companyId
    ? await supabase.from("marketplace_installs").select("*").eq("company_id", companyId).order("created_at", { ascending: false })
    : { data: [] };

  return (
    <AppShell title="Marketplace" subtitle="Install agents, workflows and company systems.">
      <div className="grid gap-4 md:grid-cols-3">
        {demoAssets.map(([title, type]) => (
          <div key={title} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <div className="mb-5 h-28 rounded-2xl bg-gradient-to-br from-blue-50 to-purple-50" />
            <h2 className="text-2xl font-black">{title}</h2>
            <p className="mt-2 text-sm text-neutral-500">{type}</p>
            <button className="mt-5 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">
              Install
            </button>
          </div>
        ))}
      </div>

      <div className="mt-8 rounded-2xl border border-neutral-200 bg-white p-6">
        <h2 className="text-2xl font-black">Installed Assets</h2>
        <div className="mt-4 space-y-3">
          {(installs || []).map((x: any) => (
            <div key={x.id} className="rounded-xl border border-neutral-200 p-4">
              <p className="font-black">{x.asset_title}</p>
              <p className="text-sm text-neutral-500">{x.asset_type}</p>
            </div>
          ))}
          {(!installs || installs.length === 0) && <p className="text-sm text-neutral-500">No marketplace installs yet.</p>}
        </div>
      </div>
    </AppShell>
  );
}
TSX

cat > app/datasets/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";
import { getProviderStatus } from "@/lib/guards/providers";

export default async function DatasetsPage() {
  const { supabase, user, companyId } = await getWorkspace();
  const providers = getProviderStatus();

  const { data: datasets } = user && companyId
    ? await supabase.from("datasets").select("*").eq("company_id", companyId).order("created_at", { ascending: false })
    : { data: [] };

  return (
    <AppShell title="Datasets" subtitle="Upload, ingest and embed company knowledge.">
      {!providers.openai && (
        <div className="mb-6 rounded-2xl border border-amber-200 bg-amber-50 p-5">
          <p className="font-black text-amber-800">Embeddings disabled</p>
          <p className="mt-2 text-sm text-amber-700">
            OPENAI_API_KEY is missing. Upload records can be created, but embedding generation will stay disabled.
          </p>
        </div>
      )}

      <div className="rounded-2xl border-2 border-dashed border-blue-200 bg-blue-50/40 p-12 text-center">
        <h2 className="text-3xl font-black">Upload company knowledge</h2>
        <p className="mt-4 text-neutral-500">PDF, DOCX, CSV, TXT and structured data.</p>
        <button className="mt-7 rounded-xl bg-black px-6 py-4 text-sm font-bold text-white">Upload Dataset</button>
      </div>

      <div className="mt-8 grid gap-4 md:grid-cols-3">
        {(datasets || []).map((d: any) => (
          <div key={d.id} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{d.title}</h2>
            <p className="mt-3 text-sm text-neutral-500">{d.status}</p>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX

cat > app/agent-evolution/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";

export default async function AgentEvolutionPage() {
  const { supabase, user, companyId } = await getWorkspace();

  const { data: suggestions } = user && companyId
    ? await supabase.from("agent_evolution_suggestions").select("*, agents(name)").eq("company_id", companyId).order("created_at", { ascending: false })
    : { data: [] };

  return (
    <AppShell title="Agent Evolution" subtitle="Agent improvements require human approval.">
      <div className="space-y-4">
        {(suggestions || []).map((s: any) => (
          <div key={s.id} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <div className="flex justify-between gap-4">
              <div>
                <p className="text-xs font-black uppercase text-blue-600">{s.suggestion_type}</p>
                <h2 className="mt-2 text-2xl font-black">{s.title}</h2>
                <p className="mt-2 text-sm text-neutral-500">{s.description}</p>
              </div>
              <span className="h-fit rounded-full bg-neutral-100 px-3 py-1 text-xs font-black">{s.status}</span>
            </div>
          </div>
        ))}

        {(!suggestions || suggestions.length === 0) && (
          <div className="rounded-2xl border border-neutral-200 bg-white p-10 text-center">
            <h2 className="text-3xl font-black">No evolution suggestions yet</h2>
            <p className="mt-3 text-neutral-500">Agents will suggest improvements after execution history exists.</p>
          </div>
        )}
      </div>
    </AppShell>
  );
}
TSX

npm run build
git add .
git commit -m "Add final wiring layer for workflows marketplace datasets and evolution" || true
git push origin main

echo "DONE"
