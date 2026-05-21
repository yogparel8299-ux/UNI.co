"use client";
import { useState } from "react";
import { createBrowserClient } from "@supabase/ssr";

export default function OnboardingPage(){
  const [companyName,setCompanyName]=useState(""); const [industry,setIndustry]=useState(""); const [msg,setMsg]=useState("");
  async function createCompany(){
    setMsg("Creating workspace...");
    const supabase=createBrowserClient(process.env.NEXT_PUBLIC_SUPABASE_URL||"",process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY||"");
    const {data:{user}}=await supabase.auth.getUser();
    if(!user){window.location.href="/login";return;}
    const res=await fetch("/api/onboarding-create-company",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({user_id:user.id,company_name:companyName,industry})});
    const json=await res.json(); if(!json.ok){setMsg(json.error||"Failed.");return;}
    window.location.href="/agents";
  }
  return <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6"><div className="w-full max-w-lg rounded-[32px] border border-neutral-200 bg-white p-8 shadow-sm"><h1 className="text-5xl font-black tracking-[-0.06em]">Create workspace</h1><p className="mt-3 text-neutral-500">Set up your company workspace.</p><div className="mt-8 space-y-4"><input className="w-full rounded-xl border border-neutral-200 px-4 py-3" placeholder="Company name" value={companyName} onChange={(e)=>setCompanyName(e.target.value)}/><input className="w-full rounded-xl border border-neutral-200 px-4 py-3" placeholder="Industry" value={industry} onChange={(e)=>setIndustry(e.target.value)}/><button onClick={createCompany} className="w-full rounded-xl bg-black px-4 py-3 font-black text-white">Create Workspace</button></div>{msg&&<p className="mt-4 text-sm text-neutral-500">{msg}</p>}</div></main>;
}
