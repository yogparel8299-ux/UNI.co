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
