"use client";

import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function Page() {
  const [company, setCompany] = useState("");
  const [msg, setMsg] = useState("");

  async function createWorkspace() {
    setMsg("Creating workspace...");
    const supabase = supabaseBrowser();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return (window.location.href = "/login");

    await fetch("/api/onboarding-create-company", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ company_name: company, user_id: user.id })
    });

    window.location.href = "/dashboard";
  }

  return (
    <main className="relative grid min-h-screen place-items-center overflow-hidden bg-[#f0f0ee] p-6">
      <video className="video-soft absolute inset-0 h-full w-full object-cover" src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4" autoPlay muted loop playsInline />
      <div className="relative z-10 w-full max-w-sm rounded-2xl bg-[#EDEDED]/85 p-6 backdrop-blur-2xl">
        <p className="text-[12px] font-medium text-blue-500">Workspace onboarding</p>
        <h1 className="mt-3 text-[1.75rem] font-medium leading-[1.15] tracking-tight text-gray-900">Name your AI company system.</h1>
        <input className="mt-6 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Company name" value={company} onChange={(e) => setCompany(e.target.value)} />
        <button onClick={createWorkspace} className="mt-3 w-full rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition hover:bg-blue-500 hover:text-white">Create workspace →</button>
        {msg && <p className="mt-3 text-[12px] text-gray-500">{msg}</p>}
      </div>
    </main>
  );
}
