"use client";

import { useState } from "react";
import Link from "next/link";
import { supabaseBrowser } from "@/lib/supabase-browser";
import Logo from "@/components/unic/Logo";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");

  async function login() {
    setMsg("Logging in...");
    const { error } = await supabaseBrowser().auth.signInWithPassword({ email, password });
    if (error) return setMsg(error.message);
    window.location.href = "/dashboard";
  }

  return (
    <main className="relative grid min-h-screen place-items-center overflow-hidden bg-[#f0f0ee] p-6">
      <video className="video-soft absolute inset-0 h-full w-full object-cover" src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4" autoPlay muted loop playsInline />
      <div className="relative z-10 w-full max-w-sm rounded-2xl bg-[#EDEDED]/85 p-6 backdrop-blur-2xl">
        <div className="mb-6 flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white"><Logo /></div>
          <div>
            <p className="font-medium text-gray-900">UNIC.ai</p>
            <p className="text-[12px] text-gray-400">Initialize session</p>
          </div>
        </div>
        <input className="mb-3 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input className="mb-3 w-full rounded-xl border-0 bg-white/70 px-4 py-3 text-[13px] outline-none" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <button onClick={login} className="w-full rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition hover:bg-blue-500 hover:text-white">Login →</button>
        {msg && <p className="mt-3 text-[12px] text-gray-500">{msg}</p>}
        <Link href="/signup" className="mt-4 block text-[12px] text-blue-500">Create workspace →</Link>
      </div>
    </main>
  );
}
