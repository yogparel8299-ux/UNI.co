"use client";

import { useState } from "react";

export default function ConnectorsPage() {
  const [companyId, setCompanyId] = useState("");
  const [provider, setProvider] = useState("slack");
  const [connectionId, setConnectionId] = useState("");
  const [result, setResult] = useState("");

  async function saveConnection() {
    const res = await fetch("/api/connector-connect", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        provider,
        connection_id: connectionId,
        auth_provider: "composio"
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Connectors</h1>
        <p className="page-subtitle">
          Store Composio/OAuth connection IDs so agents can use connected tools.
        </p>

        <div className="grid grid-cols-3 gap-6 mt-10">
          {["slack", "gmail", "notion", "github", "google_drive", "zapier", "hubspot", "calendar", "stripe"].map((p) => (
            <button key={p} onClick={() => setProvider(p)} className="glass-card p-6 text-left">
              <h2 className="text-2xl font-black capitalize">{p.replace("_", " ")}</h2>
              <p className="text-gray-500 mt-3">Connect via Composio/OAuth.</p>
            </button>
          ))}
        </div>

        <div className="glass-card p-8 mt-10 max-w-2xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={(e) => setCompanyId(e.target.value)} />
          <input className="input-box mt-4" placeholder="Provider" value={provider} onChange={(e) => setProvider(e.target.value)} />
          <input className="input-box mt-4" placeholder="Composio connection ID" value={connectionId} onChange={(e) => setConnectionId(e.target.value)} />

          <button className="primary-button mt-6" onClick={saveConnection}>
            Save Connector
          </button>

          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
