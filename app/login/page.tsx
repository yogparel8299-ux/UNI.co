"use client";
import Link from "next/link";
import { useState } from "react";
import { createBrowserClient } from "@supabase/ssr";

export default function LoginPage() {
  const [email,setEmail]=useState(""); const [password,setPassword]=useState(""); const [remember,setRemember]=useState(true); const [msg,setMsg]=useState("");
  async function login(){
    setMsg("Logging in...");
    const supabase=createBrowserClient(process.env.NEXT_PUBLIC_SUPABASE_URL||"",process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY||"");
    if(remember)localStorage.setItem("unic_remember_me","true"); else localStorage.removeItem("unic_remember_me");
    const {error}=await supabase.auth.signInWithPassword({email,password});
    if(error){setMsg(error.message);return;}
    window.location.href="/agents";
  }
  return <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6 text-black"><div className="w-full max-w-md rounded-[32px] border border-neutral-200 bg-white p-8 shadow-[0_24px_90px_rgba(15,23,42,.07)]"><h1 className="text-5xl font-black tracking-[-0.06em]">Login</h1><p className="mt-3 text-neutral-500">Access your AI company workspace.</p><div className="mt-8 space-y-4"><input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Email" value={email} onChange={(e)=>setEmail(e.target.value)}/><input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Password" type="password" value={password} onChange={(e)=>setPassword(e.target.value)}/><label className="flex items-center gap-3 text-sm font-semibold text-neutral-600"><input type="checkbox" checked={remember} onChange={(e)=>setRemember(e.target.checked)}/>Remember me on this device</label><button onClick={login} className="w-full rounded-xl bg-black px-4 py-3 font-black text-white">Login</button></div>{msg&&<p className="mt-4 text-sm text-neutral-500">{msg}</p>}<p className="mt-6 text-sm text-neutral-500">No account? <Link href="/signup" className="font-black text-black">Create workspace</Link></p></div></main>;
}
