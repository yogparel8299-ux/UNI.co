#!/bin/bash
set -e

echo "Fixing bad substitution and completing approved pages..."

make_page_cards () {
  ROUTE="$1"
  TITLE="$2"
  SUBTITLE="$3"

  mkdir -p "app/$ROUTE"

  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" subtitle="$SUBTITLE">
      <div className="grid gap-4 md:grid-cols-3">
        {["Create", "Configure", "Monitor", "Review", "Run", "Export"].map((x) => (
          <div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{x}</h2>
            <p className="mt-3 text-sm text-neutral-500">
              Workspace action for this module.
            </p>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX
}

make_page_table () {
  ROUTE="$1"
  TITLE="$2"
  SUBTITLE="$3"

  mkdir -p "app/$ROUTE"

  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" subtitle="$SUBTITLE">
      <div className="rounded-2xl border border-neutral-200 bg-white p-6">
        <div className="space-y-3">
          {["Workspace updated", "Agent assigned", "Workflow synced", "Approval reviewed"].map((x) => (
            <div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4">
              <span className="font-bold">{x}</span>
              <span className="text-sm text-neutral-500">live</span>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
TSX
}

make_page_kanban () {
  ROUTE="$1"
  TITLE="$2"
  SUBTITLE="$3"

  mkdir -p "app/$ROUTE"

  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" subtitle="$SUBTITLE">
      <div className="grid gap-4 md:grid-cols-3">
        {["Backlog", "Running", "Completed"].map((col) => (
          <div key={col} className="rounded-2xl border border-neutral-200 bg-white p-5">
            <h2 className="text-2xl font-black">{col}</h2>
            <div className="mt-5 space-y-3">
              {["Task one", "Task two", "Task three"].map((x) => (
                <div key={x} className="rounded-xl bg-neutral-100 p-4 text-sm font-bold">
                  {x}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX
}

make_page_plans () {
  ROUTE="$1"
  TITLE="$2"
  SUBTITLE="$3"

  mkdir -p "app/$ROUTE"

  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" subtitle="$SUBTITLE">
      <div className="grid gap-4 md:grid-cols-4">
        {["Starter", "Builder", "Company", "Enterprise"].map((x) => (
          <div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{x}</h2>
            <p className="mt-3 text-sm text-neutral-500">
              Credit-based workspace plan.
            </p>
            <button className="mt-6 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">
              Select
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
TSX
}

make_page_cards team "Team" "Members, roles, invites and workspace access."
make_page_cards goals "Goals" "Company goals and agent alignment."
make_page_kanban tasks "Tasks" "Task queue, ownership and execution status."
make_page_cards usage "Usage" "Credits, runtime consumption and workspace limits."
make_page_cards agents "Agents" "Create and manage AI employees."
make_page_cards skills "Skills" "Reusable capabilities attached to agents."
make_page_cards swarms "Swarms" "Multi-agent teams and delegation systems."
make_page_plans billing "Billing" "Plans, invoices, credits and payment status."
make_page_cards budgets "Budgets" "Agent, workflow and company spending controls."
make_page_cards builder "Builder" "Create agents, workflows and company systems."
make_page_table activity "Activity" "Audit trail and workspace event feed."
make_page_cards datasets "Datasets" "Upload and index company knowledge."
make_page_cards dataset-sell "Dataset Sell" "Package and sell approved datasets."
make_page_cards settings "Settings" "Workspace, model keys, security and controls."
make_page_table approvals "Approvals" "Human approval inbox for sensitive actions."
make_page_cards companies "Companies" "Company profiles, workspaces and operating units."
make_page_table schedules "Schedules" "Recurring tasks and automation schedules."
make_page_cards marketplace "Marketplace" "Buy, sell and install agents, skills and workflows."
make_page_cards brain "Company Brain" "Memory, RAG and company knowledge graph."
make_page_table realtime-dashboard "Realtime" "Runtime events, worker health and execution streams."
make_page_table live-runtime "Live Runtime" "Live agent and workflow execution monitor."
make_page_cards agent-evolution "Agent Evolution" "Review agent improvements and version suggestions."

npm run build
git add .
git commit -m "Fix final UI page generation script" || true
git push origin main

echo "DONE"
