"use client";
import { useState } from "react";

export default function DatasetLab() {
  const [companyId, setCompanyId] = useState("");
  const [datasetId, setDatasetId] = useState("");
  const [content, setContent] = useState("");
  const [query, setQuery] = useState("");
  const [result, setResult] = useState("");

  async function ingest() {
    const res = await fetch("/api/dataset-ingest", {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ company_id: companyId, dataset_id: datasetId, content })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  async function search() {
    const res = await fetch("/api/dataset-search", {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ company_id: companyId, query })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Dataset Lab</h1>
        <p className="page-subtitle">Ingest text, create chunks, embed them and search with RAG.</p>
        <div className="glass-card p-8 mt-10 max-w-4xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={e=>setCompanyId(e.target.value)} />
          <input className="input-box mt-4" placeholder="Dataset ID" value={datasetId} onChange={e=>setDatasetId(e.target.value)} />
          <textarea className="input-box mt-4 min-h-[160px]" placeholder="Dataset content" value={content} onChange={e=>setContent(e.target.value)} />
          <button className="primary-button mt-4" onClick={ingest}>Ingest Dataset</button>
          <textarea className="input-box mt-8 min-h-[100px]" placeholder="Search query" value={query} onChange={e=>setQuery(e.target.value)} />
          <button className="primary-button mt-4" onClick={search}>Search Dataset</button>
          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
