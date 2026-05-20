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
    const supabase = supabaseBrowser();
    const { data, error } = await supabase.auth.signUp({ email, password });

    if (error) {
      setMsg(error.message);
      return;
    }

    if (data.user?.id) {
      await fetch("/api/verify-user-email", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ user_id: data.user.id, email })
      }).catch(() => {});
    }

    setMsg("Account created. Go to dashboard.");
    setTimeout(() => {
      window.location.href = "/onboarding";
    }, 700);
  }

  return (
    <main className="page-shell min-h-screen grid place-items-center px-6">
      <div className="glass-card w-full max-w-md p-8">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Start UNIC.ai</h1>
        <p className="text-white/50 mt-3">Create your AI company operating system.</p>

        <input className="input-box mt-8" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="input-box mt-4" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

        <button className="primary-button mt-6 w-full" onClick={signup}>Create account</button>

        {msg && <p className="mt-4 text-sm text-white/60">{msg}</p>}

        <p className="mt-6 text-sm text-white/45">
          Already have an account? <Link className="text-white" href="/login">Login</Link>
        </p>
      </div>
    </main>
  );
}
