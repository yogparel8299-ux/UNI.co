"use client";

import { useState } from "react";

export default function RouterPage() {
  const [companyId, setCompanyId] = useState("");
  const [provider, setProvider] = useState("openai");
  const [model, setModel] = useState("gpt-4o-mini");
  const [prompt, setPrompt] = useState("");
  const [result, setResult] = useState("");

  async function run() {
    const res = await fetch("/api/router-run", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        provider,
        model,
        prompt
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Model Router</h1>
        <p className="page-subtitle">
          Route tasks between OpenAI, Claude and OpenRouter using user-owned keys.
        </p>

        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={(e) => setCompanyId(e.target.value)} />

          <select className="input-box mt-4" value={provider} onChange={(e) => setProvider(e.target.value)}>
            <option value="openai">OpenAI</option>
            <option value="anthropic">Claude</option>
            <option value="openrouter">OpenRouter</option>
          </select>

          <input className="input-box mt-4" placeholder="Model" value={model} onChange={(e) => setModel(e.target.value)} />

          <textarea className="input-box mt-4 min-h-[160px]" placeholder="Prompt" value={prompt} onChange={(e) => setPrompt(e.target.value)} />

          <button className="primary-button mt-6" onClick={run}>
            Run Model
          </button>

          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
