"use client";
import { useState } from "react";

export default function RAGPage() {
  const [companyId, setCompanyId] = useState("");
  const [query, setQuery] = useState("");
  const [result, setResult] = useState("");

  async function search() {
    const res = await fetch("/api/rag-search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ company_id: companyId, query })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Vector Search / RAG</h1>
        <p className="page-subtitle">Search company memory using embeddings and pgvector.</p>
        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={e => setCompanyId(e.target.value)} />
          <textarea className="input-box mt-4 min-h-[140px]" placeholder="Ask your company brain..." value={query} onChange={e => setQuery(e.target.value)} />
          <button className="primary-button mt-6" onClick={search}>Search Memory</button>
          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
