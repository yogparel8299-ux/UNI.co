"use client";

import { useState } from "react";

export default function VaultPage() {
  const [companyId, setCompanyId] = useState("");
  const [provider, setProvider] = useState("openai");
  const [secret, setSecret] = useState("");
  const [result, setResult] = useState("");

  async function saveSecret() {
    const res = await fetch("/api/save-secret", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        provider,
        secret_name: `${provider}_api_key`,
        secret_value: secret
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">API Key Vault</h1>
        <p className="page-subtitle">
          Store user-owned OpenAI, Claude and OpenRouter keys securely for routing.
        </p>

        <div className="glass-card p-8 mt-10 max-w-2xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={(e) => setCompanyId(e.target.value)} />

          <select className="input-box mt-4" value={provider} onChange={(e) => setProvider(e.target.value)}>
            <option value="openai">OpenAI / ChatGPT</option>
            <option value="anthropic">Anthropic / Claude</option>
            <option value="openrouter">OpenRouter</option>
          </select>

          <input className="input-box mt-4" placeholder="API Key" value={secret} onChange={(e) => setSecret(e.target.value)} />

          <button className="primary-button mt-6" onClick={saveSecret}>
            Save Key
          </button>

          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
