"use client";
import { useState } from "react";

export default function SecretManager() {
  const [companyId, setCompanyId] = useState("");
  const [result, setResult] = useState("");

  async function load() {
    const res = await fetch("/api/secret-list", {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ company_id: companyId })
    });
    setResult(JSON.stringify(await res.json(), null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">Secret Manager</h1>
        <p className="page-subtitle">View masked provider keys and revoke them safely.</p>
        <div className="glass-card p-8 mt-10 max-w-3xl">
          <input className="input-box" placeholder="Company ID" value={companyId} onChange={e=>setCompanyId(e.target.value)} />
          <button className="primary-button mt-4" onClick={load}>Load Secrets</button>
          {result && <pre className="mt-6 bg-gray-950 text-green-300 p-5 rounded-2xl overflow-auto text-xs">{result}</pre>}
        </div>
      </section>
    </main>
  );
}
