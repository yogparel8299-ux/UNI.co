"use client";

import { useState } from "react";

const providers = [
  ["slack", "Slack", "Messages, alerts, approvals, team updates"],
  ["gmail", "Gmail", "Email search, send, classify, reply"],
  ["google_drive", "Google Drive", "Files, documents, datasets"],
  ["notion", "Notion", "Docs, knowledge base, memory sync"],
  ["github", "GitHub", "Issues, repos, code tasks"],
  ["hubspot", "HubSpot", "CRM, leads, contacts"],
  ["zapier", "Zapier", "Webhook automation layer"],
  ["stripe", "Stripe", "Charges, invoices, financial events"]
];

export default function ConnectionLayerPage() {
  const [companyId, setCompanyId] = useState("");
  const [userId, setUserId] = useState("");
  const [result, setResult] = useState("");

  async function connect(provider: string) {
    const res = await fetch("/api/connection-link", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        user_id: userId,
        provider,
        redirect_url: `${window.location.origin}/connection-layer`
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));

    const url = data?.link?.redirect_url || data?.link?.url || data?.link?.link;

    if (url) {
      window.open(url, "_blank");
    }
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Connection Layer</h1>
        <p className="page-subtitle">
          One-click OAuth-style connections for Slack, Gmail, Notion, GitHub, Drive, HubSpot, Zapier and Stripe.
          Connected apps become agent tools, memory sources, profile signals and trigger sources.
        </p>

        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input
            className="input-box"
            placeholder="Company ID"
            value={companyId}
            onChange={(e) => setCompanyId(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="User ID"
            value={userId}
            onChange={(e) => setUserId(e.target.value)}
          />
        </div>

        <div className="grid grid-cols-4 gap-6 mt-10">
          {providers.map(([provider, name, text]) => (
            <div key={provider} className="glass-card p-6">
              <h2 className="text-2xl font-black tracking-[-0.03em]">{name}</h2>
              <p className="text-gray-500 mt-3 leading-7">{text}</p>
              <button className="primary-button mt-6" onClick={() => connect(provider)}>
                Connect
              </button>
            </div>
          ))}
        </div>

        {result && (
          <pre className="mt-10 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">
            {result}
          </pre>
        )}
      </section>
    </main>
  );
}
