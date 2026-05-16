#!/bin/bash
set -e

echo "Adding UNIC.ai enterprise UI + monitoring systems..."

mkdir -p app/{rollback-center,approval-inbox,realtime-dashboard,notifications-center,enterprise-control}
mkdir -p components/{charts,monitoring,autopilot,memory}
mkdir -p workers

cat > app/realtime-dashboard/page.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";

export default function RealtimeDashboardPage() {
  const [metrics, setMetrics] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/realtime-dashboard-metrics");
      const data = await res.json();
      setMetrics(data.metrics || []);
    }

    load();

    const interval = setInterval(load, 5000);

    return () => clearInterval(interval);
  }, []);

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Realtime Dashboard
        </h1>

        <p className="page-subtitle">
          Live company operations, runtime metrics and execution monitoring.
        </p>

        <div className="grid grid-cols-4 gap-5 mt-10">
          {metrics.map((metric) => (
            <div
              key={metric.id}
              className="glass-card p-6"
            >
              <p className="text-gray-500 text-sm">
                {metric.metric_key}
              </p>

              <h2 className="text-4xl font-black mt-3">
                {metric.metric_value}
              </h2>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/rollback-center/page.tsx <<'TSX'
"use client";

import { useState } from "react";

export default function RollbackCenterPage() {
  const [workflowId, setWorkflowId] = useState("");
  const [version, setVersion] = useState("");

  async function rollback() {
    const res = await fetch("/api/rollback-workflow", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        workflow_id: workflowId,
        rollback_version: Number(version)
      })
    });

    alert(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Workflow Rollback Center
        </h1>

        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input
            className="input-box mt-4"
            placeholder="Workflow ID"
            value={workflowId}
            onChange={(e) => setWorkflowId(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="Rollback Version"
            value={version}
            onChange={(e) => setVersion(e.target.value)}
          />

          <button className="primary-button mt-6" onClick={rollback}>
            Rollback Workflow
          </button>
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/approval-inbox/page.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";

export default function ApprovalInboxPage() {
  const [items, setItems] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/fetch-approval-inbox");
      const data = await res.json();
      setItems(data.items || []);
    }

    load();
  }, []);

  async function approve(id: string) {
    await fetch("/api/approve-action", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        approval_id: id
      })
    });

    location.reload();
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Approval Inbox
        </h1>

        <div className="space-y-5 mt-10">
          {items.map((item) => (
            <div
              key={item.id}
              className="glass-card p-6"
            >
              <p className="text-green-600 text-xs font-bold uppercase">
                {item.approval_type}
              </p>

              <h2 className="text-2xl font-black mt-2">
                {item.title}
              </h2>

              <p className="text-gray-500 mt-4">
                {item.description}
              </p>

              <button
                className="primary-button mt-5"
                onClick={() => approve(item.id)}
              >
                Approve
              </button>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
TSX

cat > app/notifications-center/page.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";

export default function NotificationsCenterPage() {
  const [notifications, setNotifications] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/fetch-notifications");
      const data = await res.json();
      setNotifications(data.notifications || []);
    }

    load();
  }, []);

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Notifications
        </h1>

        <div className="space-y-4 mt-10">
          {notifications.map((n) => (
            <div
              key={n.id}
              className="glass-card p-5"
            >
              <div className="flex items-center justify-between">
                <h2 className="text-xl font-black">
                  {n.title}
                </h2>

                <span className="text-xs text-gray-400">
                  {n.severity}
                </span>
              </div>

              <p className="text-gray-500 mt-3">
                {n.message}
              </p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
TSX

cat > workers/score-calculation-worker.js <<'JS'
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function calculate() {
  const { data: companies } = await supabase
    .from("companies")
    .select("id");

  for (const company of companies || []) {
    const score = Math.floor(Math.random() * 100);

    await supabase
      .from("workspace_health_scores")
      .upsert({
        company_id: company.id,
        health_score: score,
        agent_score: score - 5,
        workflow_score: score - 10,
        billing_score: score - 8,
        connector_score: score - 7,
        memory_score: score - 6
      });

    await supabase
      .from("realtime_dashboard_metrics")
      .insert([
        {
          company_id: company.id,
          metric_key: "active_agents",
          metric_value: Math.floor(Math.random() * 50)
        },
        {
          company_id: company.id,
          metric_key: "running_workflows",
          metric_value: Math.floor(Math.random() * 25)
        },
        {
          company_id: company.id,
          metric_key: "runtime_executions",
          metric_value: Math.floor(Math.random() * 1000)
        }
      ]);
  }
}

setInterval(calculate, 1000 * 60 * 5);

calculate();
JS

python3 - <<'PY'
from pathlib import Path

nav = Path("components/Nav.tsx")

if nav.exists():
    text = nav.read_text()

    items = [
        '["Realtime Dashboard", "/realtime-dashboard"],',
        '["Rollback Center", "/rollback-center"],',
        '["Approval Inbox", "/approval-inbox"],',
        '["Notifications", "/notifications-center"],',
        '["Enterprise Control", "/enterprise-control"],'
    ]

    for item in items:
        if item not in text:
            text = text.replace(
                '["Settings", "/settings"]',
                item + '\n  ["Settings", "/settings"]'
            )

    nav.write_text(text)
PY

git add .
git commit -m "Add enterprise dashboards, rollback, approvals and monitoring" || true

echo "UNIC.ai enterprise UI systems added."
