"use client";

import { useState } from "react";

export default function BrainSearchPage() {
  const [companyId, setCompanyId] = useState("");
  const [query, setQuery] = useState("");
  const [result, setResult] = useState("");

  async function search() {
    const response = await fetch("/api/brain-query", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        query
      })
    });

    setResult(JSON.stringify(await response.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Brain Search
        </h1>

        <p className="page-subtitle">
          Ask your company brain across memories, datasets and embeddings.
        </p>

        <div className="glass-card p-8 mt-10 max-w-4xl">
          <input
            className="input-box"
            placeholder="Company ID"
            value={companyId}
            onChange={(event) => setCompanyId(event.target.value)}
          />

          <textarea
            className="input-box mt-4 min-h-[160px]"
            placeholder="Ask your company brain..."
            value={query}
            onChange={(event) => setQuery(event.target.value)}
          />

          <button className="primary-button mt-6" onClick={search}>
            Search Brain
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
