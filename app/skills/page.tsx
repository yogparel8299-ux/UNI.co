"use client";

import { useState } from "react";

export default function SkillsPage() {
  const [companyId, setCompanyId] = useState("");
  const [title, setTitle] = useState("");
  const [category, setCategory] = useState("custom");
  const [description, setDescription] = useState("");
  const [systemPrompt, setSystemPrompt] = useState("");
  const [result, setResult] = useState("");

  async function createSkill() {
    const res = await fetch("/api/create-skill", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_id: companyId,
        title,
        category,
        description,
        system_prompt: systemPrompt
      })
    });

    const data = await res.json();
    setResult(JSON.stringify(data, null, 2));
  }

  return (
    <main className="page-shell">
      <section className="main">
        <h1 className="page-title">
          Skills
        </h1>

        <p className="page-subtitle">
          Create reusable skills that can be added to any agent.
        </p>

        <div className="glass-card p-8 mt-10 max-w-4xl">
          <h2 className="text-3xl font-black tracking-[-0.04em]">
            Create Custom Skill
          </h2>

          <input
            className="input-box mt-6"
            placeholder="Company ID"
            value={companyId}
            onChange={(e) => setCompanyId(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="Skill title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />

          <input
            className="input-box mt-4"
            placeholder="Category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
          />

          <textarea
            className="input-box mt-4 min-h-[100px]"
            placeholder="Description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />

          <textarea
            className="input-box mt-4 min-h-[180px]"
            placeholder="System prompt: what this skill makes the agent good at"
            value={systemPrompt}
            onChange={(e) => setSystemPrompt(e.target.value)}
          />

          <button className="primary-button mt-6" onClick={createSkill}>
            Create Skill
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
