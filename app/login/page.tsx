"use client";

import Link from "next/link";
import { useState } from "react";
import { supabaseBrowser } from "@/lib/supabase-browser";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function login() {
    setMsg("Logging in...");
    const supabase = supabaseBrowser();
    const { error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      setMsg(error.message);
      return;
    }

    window.location.href = "/dashboard";
  }

  return (
    <main className="page-shell min-h-screen grid place-items-center px-6">
      <div className="glass-card w-full max-w-md p-8">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Login</h1>
        <p className="text-white/50 mt-3">Access your UNIC.ai workspace.</p>

        <input className="input-box mt-8" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="input-box mt-4" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

        <button className="primary-button mt-6 w-full" onClick={login}>Login</button>

        {msg && <p className="mt-4 text-sm text-white/60">{msg}</p>}

        <p className="mt-6 text-sm text-white/45">
          New here? <Link className="text-white" href="/signup">Create account</Link>
        </p>
      </div>
    </main>
  );
}
