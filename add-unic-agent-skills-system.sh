#!/bin/bash
set -e

echo "Adding UNIC.ai Agent Skills system..."

mkdir -p app/skills
mkdir -p app/agents/[id]/skills
mkdir -p app/api/{create-skill,assign-skill,remove-agent-skill,run-skill}
mkdir -p components/skills
mkdir -p lib/skills

cat > lib/skills/run-skill.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";
import { runRealModel } from "@/lib/models/real-router";

export async function runAgentSkill({
  companyId,
  agentId,
  skillAssignmentId,
  input
}: {
  companyId: string;
  agentId: string;
  skillAssignmentId: string;
  input: any;
}) {
  const { data: assignment, error: assignmentError } = await supabaseAdmin
    .from("agent_skill_assignments")
    .select("*, skill_library(*), company_skills(*)")
    .eq("id", skillAssignmentId)
    .eq("company_id", companyId)
    .eq("agent_id", agentId)
    .eq("enabled", true)
    .single();

  if (assignmentError) throw assignmentError;

  const skill = assignment.company_skills || assignment.skill_library;

  if (!skill) {
    throw new Error("Skill not found.");
  }

  const { data: run, error: runError } = await supabaseAdmin
    .from("skill_runs")
    .insert({
      company_id: companyId,
      agent_id: agentId,
      skill_assignment_id: skillAssignmentId,
      input,
      status: "running"
    })
    .select()
    .single();

  if (runError) throw runError;

  try {
    const result = await runRealModel({
      companyId,
      provider: input.provider || "openai",
      model: input.model || skill.default_model || skill.model || "gpt-4o-mini",
      systemPrompt: skill.system_prompt,
      prompt: input.prompt || JSON.stringify(input)
    });

    await supabaseAdmin
      .from("skill_runs")
      .update({
        output: result,
        status: "completed",
        completed_at: new Date().toISOString()
      })
      .eq("id", run.id);

    await supabaseAdmin.from("runtime_events").insert({
      company_id: companyId,
      run_id: null,
      event_type: "skill_completed",
      message: `${skill.title} skill completed.`,
      metadata: {
        skill_run_id: run.id,
        agent_id: agentId,
        skill_assignment_id: skillAssignmentId
      }
    });

    return {
      run_id: run.id,
      result
    };
  } catch (error: any) {
    await supabaseAdmin
      .from("skill_runs")
      .update({
        status: "failed",
        error: error.message,
        completed_at: new Date().toISOString()
      })
      .eq("id", run.id);

    throw error;
  }
}
TS

cat > app/api/create-skill/route.ts <<'TS'
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
TS

cat > app/api/assign-skill/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.agent_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id and agent_id are required."
        },
        { status: 400 }
      );
    }

    if (!body.skill_library_id && !body.company_skill_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "skill_library_id or company_skill_id is required."
        },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("agent_skill_assignments")
      .insert({
        company_id: body.company_id,
        agent_id: body.agent_id,
        skill_library_id: body.skill_library_id || null,
        company_skill_id: body.company_skill_id || null,
        enabled: true,
        priority: body.priority || 100,
        config: body.config || {}
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      assignment: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Assign skill failed."
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/remove-agent-skill/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.assignment_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "assignment_id is required."
        },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin
      .from("agent_skill_assignments")
      .update({
        enabled: false
      })
      .eq("id", body.assignment_id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      assignment: data
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Remove skill failed."
      },
      { status: 500 }
    );
  }
}
TS

cat > app/api/run-skill/route.ts <<'TS'
export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { runAgentSkill } from "@/lib/skills/run-skill";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.company_id || !body.agent_id || !body.skill_assignment_id) {
      return NextResponse.json(
        {
          ok: false,
          error: "company_id, agent_id and skill_assignment_id are required."
        },
        { status: 400 }
      );
    }

    const result = await runAgentSkill({
      companyId: body.company_id,
      agentId: body.agent_id,
      skillAssignmentId: body.skill_assignment_id,
      input: body.input || {}
    });

    return NextResponse.json({
      ok: true,
      ...result
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Run skill failed."
      },
      { status: 500 }
    );
  }
}
TS

cat > components/skills/SkillAssignmentPanel.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function SkillAssignmentPanel({
  companyId,
  agentId,
  publicSkills,
  companySkills,
  assignedSkills
}: {
  companyId: string;
  agentId: string;
  publicSkills: any[];
  companySkills: any[];
  assignedSkills: any[];
}) {
  const [result, setResult] = useState("");

  async function assignPublicSkill(skillId: string) {
    const res = await fetch("/api/assign-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        agent_id: agentId,
        skill_library_id: skillId
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  async function assignCompanySkill(skillId: string) {
    const res = await fetch("/api/assign-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        agent_id: agentId,
        company_skill_id: skillId
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  async function removeSkill(assignmentId: string) {
    const res = await fetch("/api/remove-agent-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        assignment_id: assignmentId
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  async function runSkill(assignmentId: string) {
    const prompt = window.prompt("What should this skill do?");

    if (!prompt) return;

    const res = await fetch("/api/run-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        agent_id: agentId,
        skill_assignment_id: assignmentId,
        input: {
          prompt
        }
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <div className="space-y-8">
      <div className="glass-card p-8">
        <h2 className="text-3xl font-black tracking-[-0.04em]">
          Assigned Skills
        </h2>

        <div className="grid grid-cols-3 gap-5 mt-6">
          {(assignedSkills || []).map((assignment) => {
            const skill = assignment.company_skills || assignment.skill_library;

            return (
              <div key={assignment.id} className="rounded-3xl border border-black/10 p-5 bg-white">
                <p className="text-green-600 font-bold text-xs uppercase">
                  {skill?.category || "skill"}
                </p>

                <h3 className="text-xl font-black mt-2">
                  {skill?.title || "Unnamed Skill"}
                </h3>

                <p className="text-gray-500 mt-3 text-sm leading-6">
                  {skill?.description || "No description."}
                </p>

                <div className="flex gap-2 mt-5">
                  <button className="primary-button" onClick={() => runSkill(assignment.id)}>
                    Run
                  </button>

                  <button className="secondary-button" onClick={() => removeSkill(assignment.id)}>
                    Disable
                  </button>
                </div>
              </div>
            );
          })}

          {(!assignedSkills || assignedSkills.length === 0) && (
            <p className="text-gray-500 col-span-3">
              No skills assigned yet.
            </p>
          )}
        </div>
      </div>

      <div className="glass-card p-8">
        <h2 className="text-3xl font-black tracking-[-0.04em]">
          Public Skill Library
        </h2>

        <div className="grid grid-cols-4 gap-5 mt-6">
          {(publicSkills || []).map((skill) => (
            <div key={skill.id} className="rounded-3xl border border-black/10 p-5 bg-white">
              <p className="text-green-600 font-bold text-xs uppercase">
                {skill.category}
              </p>

              <h3 className="text-xl font-black mt-2">
                {skill.title}
              </h3>

              <p className="text-gray-500 mt-3 text-sm leading-6">
                {skill.description}
              </p>

              <button className="primary-button mt-5" onClick={() => assignPublicSkill(skill.id)}>
                Add to Agent
              </button>
            </div>
          ))}
        </div>
      </div>

      <div className="glass-card p-8">
        <h2 className="text-3xl font-black tracking-[-0.04em]">
          Company Skills
        </h2>

        <div className="grid grid-cols-4 gap-5 mt-6">
          {(companySkills || []).map((skill) => (
            <div key={skill.id} className="rounded-3xl border border-black/10 p-5 bg-white">
              <p className="text-green-600 font-bold text-xs uppercase">
                {skill.category}
              </p>

              <h3 className="text-xl font-black mt-2">
                {skill.title}
              </h3>

              <p className="text-gray-500 mt-3 text-sm leading-6">
                {skill.description}
              </p>

              <button className="primary-button mt-5" onClick={() => assignCompanySkill(skill.id)}>
                Add to Agent
              </button>
            </div>
          ))}

          {(!companySkills || companySkills.length === 0) && (
            <p className="text-gray-500 col-span-4">
              No company custom skills yet.
            </p>
          )}
        </div>
      </div>

      {result && (
        <pre className="bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">
          {result}
        </pre>
      )}
    </div>
  );
}
TSX

cat > app/skills/page.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function SkillsPage() {
  const [companyId, setCompanyId] = useState("");
  const [title, setTitle] = useState("");
  const [category, setCategory] = useState("custom");
  const [description, setDescription] = useState("");
  const [systemPrompt, setSystemPrompt] = useState("");
  const [result, setResult] = useState("");

  async function createSkill() {
    const res = await fetch("/api/create-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        title,
        category,
        description,
        system_prompt: systemPrompt
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Skills
        </h1>

        <p className="page-subtitle">
          Create reusable skills that can be added to any agent.
        </p>

        <div className="glass-card p-8 mt-10 max-w-4xl">
          <h2 className="text-3xl font-black tracking-[-0.04em]">
            Create Custom Skill
          </h2>

          <input
            className="input-box mt-6"
            placeholder="Company ID"
            value={companyId}
            onChange={(e) => setCompanyId(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="Skill title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="Category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
          />

          <textarea
            className="input-box mt-4 min-h-[100px]"
            placeholder="Description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />

          <textarea
            className="input-box mt-4 min-h-[180px]"
            placeholder="System prompt: what this skill makes the agent good at"
            value={systemPrompt}
            onChange={(e) => setSystemPrompt(e.target.value)}
          />

          <button className="primary-button mt-6" onClick={createSkill}>
            Create Skill
          </button>

          {result && (
            <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">
              {result}
            </pre>
          )}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/agents/[id]/skills/page.tsx <<'TSX'
import Shell from "@/components/Shell";
import SkillAssignmentPanel from "@/components/skills/SkillAssignmentPanel";
import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function AgentSkillsPage({
  params,
  searchParams
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ company_id?: string }>;
}) {
  const resolvedParams = await params;
  const resolvedSearch = await searchParams;

  const agentId = resolvedParams.id;
  const companyId = resolvedSearch.company_id || "";

  const { data: publicSkills } = await supabaseAdmin
    .from("skill_library")
    .select("*")
    .eq("active", true)
    .eq("is_public", true)
    .order("category", { ascending: true });

  const { data: companySkills } = companyId
    ? await supabaseAdmin
        .from("company_skills")
        .select("*")
        .eq("company_id", companyId)
        .eq("active", true)
        .order("created_at", { ascending: false })
    : { data: [] as any[] };

  const { data: assignedSkills } = companyId
    ? await supabaseAdmin
        .from("agent_skill_assignments")
        .select("*, skill_library(*), company_skills(*)")
        .eq("company_id", companyId)
        .eq("agent_id", agentId)
        .eq("enabled", true)
        .order("priority", { ascending: true })
    : { data: [] as any[] };

  return (
    <Shell
      title="Agent Skills"
      subtitle="Add reusable skills to this agent. Use ?company_id=YOUR_COMPANY_ID in the URL."
    >
      {!companyId && (
        <div className="glass-card p-6 mb-8 text-gray-500">
          Add company_id in the URL to assign skills:
          <br />
          /agents/{agentId}/skills?company_id=YOUR_COMPANY_ID
        </div>
      )}

      <SkillAssignmentPanel
        companyId={companyId}
        agentId={agentId}
        publicSkills={publicSkills || []}
        companySkills={companySkills || []}
        assignedSkills={assignedSkills || []}
      />
    </Shell>
  );
}
TSX

python3 - <<'PY'
from pathlib import Path

nav = Path("components/Nav.tsx")
if nav.exists():
    text = nav.read_text()
    item = '["Skills", "/skills"],'
    if item not in text:
        text = text.replace('["Settings", "/settings"]', item + '\n  ["Settings", "/settings"]')
    nav.write_text(text)

# Add verification lines if verifier exists
verify = Path("verify-unic-codespaces.sh")
if verify.exists():
    text = verify.read_text()
    additions = [
        'check_dir "app/skills"',
        'check_dir "app/api/create-skill"',
        'check_dir "app/api/assign-skill"',
        'check_dir "app/api/remove-agent-skill"',
        'check_dir "app/api/run-skill"',
        'check_file "components/skills/SkillAssignmentPanel.tsx"',
        'check_file "lib/skills/run-skill.ts"'
    ]
    marker = 'echo ""\necho "== Important components/libs/workers =="'
    block = '\n'.join(additions) + '\n\n'
    if 'app/api/create-skill' not in text and marker in text:
        text = text.replace(marker, block + marker)
    verify.write_text(text)
PY

git add .
git commit -m "Add UNIC.ai agent skills system" || true

echo "DONE: Agent Skills system added."
