export const dynamic = "force-dynamic";
export const runtime = "nodejs";

import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { createCommandPlan } from "@/lib/command-planner";

function slugify(input: string) {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 50);
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const command = body.command as string;

    if (!command) {
      return NextResponse.json(
        { ok: false, error: "Command is required." },
        { status: 400 }
      );
    }

    const plan = await createCommandPlan(command);

    let companyId = body.company_id || null;
    let company: any = null;

    if (!companyId && plan.company?.name) {
      const slugBase = plan.company.slug || slugify(plan.company.name);
      const slug = `${slugBase}-${Date.now().toString().slice(-5)}`;

      const { data, error } = await supabaseAdmin
        .from("companies")
        .insert({
          name: plan.company.name,
          slug,
          plan: "free"
        })
        .select()
        .single();

      if (error) throw error;

      company = data;
      companyId = data.id;

      await supabaseAdmin.from("billing_accounts").insert({
        company_id: companyId,
        plan: "free",
        monthly_limit: 100,
        current_usage: 0
      });

      await supabaseAdmin.from("activity_logs").insert({
        company_id: companyId,
        action: "company_created_by_ai_command",
        entity_type: "company",
        entity_id: companyId,
        metadata: { command }
      });
    }

    if (!companyId) {
      return NextResponse.json(
        {
          ok: false,
          error: "No company_id found and command did not create a company."
        },
        { status: 400 }
      );
    }

    const createdAgents: any[] = [];

    for (const agent of plan.agents || []) {
      const { data, error } = await supabaseAdmin
        .from("agents")
        .insert({
          company_id: companyId,
          name: agent.name,
          description: agent.description,
          system_prompt: agent.system_prompt,
          model: agent.model || "gpt-4o-mini",
          status: "active"
        })
        .select()
        .single();

      if (!error && data) {
        createdAgents.push(data);

        await supabaseAdmin.from("activity_logs").insert({
          company_id: companyId,
          action: "agent_created_by_ai_command",
          entity_type: "agent",
          entity_id: data.id,
          metadata: { agent }
        });
      }
    }

    const createdWorkflows: any[] = [];

    for (const workflow of plan.workflows || []) {
      const { data, error } = await supabaseAdmin
        .from("workflow_builders")
        .insert({
          company_id: companyId,
          name: workflow.name,
          graph: workflow.graph || {},
          status: "active"
        })
        .select()
        .single();

      if (!error && data) {
        createdWorkflows.push(data);

        await supabaseAdmin.from("activity_logs").insert({
          company_id: companyId,
          action: "workflow_created_by_ai_command",
          entity_type: "workflow_builder",
          entity_id: data.id,
          metadata: { workflow }
        });
      }
    }

    const createdTasks: any[] = [];
    const queuedJobs: any[] = [];

    for (const task of plan.tasks || []) {
      const selectedAgent =
        createdAgents.find((a) => a.name === task.agent_name) ||
        createdAgents[0] ||
        null;

      const { data: taskData, error: taskError } = await supabaseAdmin
        .from("tasks")
        .insert({
          company_id: companyId,
          agent_id: selectedAgent?.id || null,
          title: task.title,
          input: task.input,
          status: "queued"
        })
        .select()
        .single();

      if (!taskError && taskData) {
        createdTasks.push(taskData);

        const { data: queueData } = await supabaseAdmin
          .from("execution_queue")
          .insert({
            company_id: companyId,
            agent_id: selectedAgent?.id || null,
            task_id: taskData.id,
            payload: {
              prompt: task.input,
              task_title: task.title,
              agent_name: selectedAgent?.name,
              system_prompt: selectedAgent?.system_prompt,
              model: selectedAgent?.model || "gpt-4o-mini"
            },
            status: "pending"
          })
          .select()
          .single();

        if (queueData) queuedJobs.push(queueData);

        await supabaseAdmin.from("activity_logs").insert({
          company_id: companyId,
          action: "task_queued_by_ai_command",
          entity_type: "task",
          entity_id: taskData.id,
          metadata: { task }
        });
      }
    }

    return NextResponse.json({
      ok: true,
      response: plan.response,
      company,
      company_id: companyId,
      agents: createdAgents,
      workflows: createdWorkflows,
      tasks: createdTasks,
      queued_jobs: queuedJobs
    });
  } catch (error: any) {
    console.error(error);

    return NextResponse.json(
      {
        ok: false,
        error: error.message || "Command failed."
      },
      { status: 500 }
    );
  }
}
