"use client";

import Link from "next/link";
import { useState } from "react";
import { createBrowserClient } from "@supabase/ssr";

export default function SignupPage() {
  const [companyName, setCompanyName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(true);
  const [msg, setMsg] = useState("");

  async function signup() {
    setMsg("Creating workspace...");

    const supabase = createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL || "",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ""
    );

    if (remember) localStorage.setItem("unic_remember_me", "true");

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { company_name: companyName } }
    });

    if (error) {
      setMsg(error.message);
      return;
    }

    if (data.user?.id) {
      await fetch("/api/verify-user-email", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user_id: data.user.id, email })
      }).catch(() => {});
    }

    window.location.href = "/onboarding";
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6 text-black">
      <div className="w-full max-w-md rounded-[32px] border border-neutral-200 bg-white p-8 shadow-[0_24px_90px_rgba(15,23,42,.07)]">
        <h1 className="text-5xl font-black tracking-[-0.06em]">Create workspace</h1>
        <p className="mt-3 text-neutral-500">Start your AI company operating system.</p>

        <div className="mt-8 space-y-4">
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Company name" value={companyName} onChange={(e) => setCompanyName(e.target.value)} />
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />

          <label className="flex items-center gap-3 text-sm font-semibold text-neutral-600">
            <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
            Remember me on this device
          </label>

          <button onClick={signup} className="w-full rounded-xl bg-black px-4 py-3 font-black text-white">Create workspace</button>
        </div>

        {msg && <p className="mt-4 text-sm text-neutral-500">{msg}</p>}

        <p className="mt-6 text-sm text-neutral-500">
          Already have account? <Link href="/login" className="font-black text-black">Login</Link>
        </p>
      </div>
    </main>
  );
}
