"use client";

import Link from "next/link";
import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function SignupPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function signup() {
    setMsg("Creating account...");
    const { error } = await supabaseBrowser().auth.signUp({ email, password });
    if (error) return setMsg(error.message);
    window.location.href = "/onboarding";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#031427] p-6 text-[#d3e4fe]">
      <div className="w-full max-w-md rounded border border-[#45474b]/50 bg-[#0b1c30] p-8">
        <p className="font-mono text-xs uppercase tracking-[0.22em] text-[#2fd9f4]">Join the Workforce</p>
        <h1 className="mt-4 text-5xl font-black tracking-[-0.06em]">Create Workspace</h1>
        <div className="mt-8 space-y-4">
          <input className="w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="w-full rounded border border-[#45474b] bg-[#000f21] px-4 py-3 text-[#d3e4fe]" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
          <button onClick={signup} className="w-full rounded bg-[#2fd9f4] px-4 py-3 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Create Account</button>
        </div>
        {msg && <p className="mt-4 font-mono text-xs text-[#c6c6cb]">{msg}</p>}
        <p className="mt-6 text-sm text-[#c6c6cb]">Already have account? <Link href="/login" className="text-[#2fd9f4]">Login</Link></p>
      </div>
    </main>
  );
}
