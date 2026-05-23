"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function OnboardingPage() {
  const [company, setCompany] = useState("");
  const [msg, setMsg] = useState("");

  async function createWorkspace() {
    const supabase = supabaseBrowser();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return (window.location.href = "/login");

    setMsg("Creating workspace...");
    await fetch("/api/onboarding-create-company", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ user_id: user.id, company_name: company })
    });
    window.location.href = "/dashboard";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#031427] p-6 text-[#d3e4fe]">
      <div className="w-full max-w-lg rounded border border-[#45474b]/50 bg-[#0b1c30] p-8">
        <p className="font-mono text-xs uppercase tracking-[0.22em] text-[#2fd9f4]">Workspace Provisioning</p>
        <h1 className="mt-4 text-5xl font-black tracking-[-0.06em]">Create Company OS</h1>
        <input className="mt-8 w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Company name" value={company} onChange={(e) => setCompany(e.target.value)} />
        <button onClick={createWorkspace} className="mt-4 w-full rounded bg-[#2fd9f4] px-4 py-3 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Provision Workspace</button>
        {msg && <p className="mt-4 font-mono text-xs text-[#c6c6cb]">{msg}</p>}
      </div>
    </main>
  );
}
