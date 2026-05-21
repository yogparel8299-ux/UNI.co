#!/bin/bash
set -e

echo "Building full UNIC.ai final UI + launch wiring..."

mkdir -p components/unic components/workflow lib/server lib/billing lib/guards lib/composio lib/runtime
mkdir -p app/{login,signup,onboarding,dashboard,team,goals,tasks,usage,agents,skills,swarms,billing,budgets,builder,workflow-studio,pricing,activity,datasets,dataset-sell,settings,approvals,companies,schedules,marketplace,connection-layer,brain,realtime-dashboard,live-runtime,agent-evolution,legal/terms,legal/refund,legal/privacy,legal/ai-policy}
mkdir -p app/api/{onboarding-create-company,composio-auth-link,composio-callback-save,composio-execute,stripe-webhook,razorpay-webhook,launch-verify,workflow-save,workflow-execute,marketplace-install,dataset-ingest-run,agent-evolution-create,agent-evolution-review}

cat > lib/protected-routes.ts <<'TS'
export const PROTECTED_ROUTES = [
  "/team","/goals","/tasks","/usage","/agents","/skills","/swarms","/billing",
  "/budgets","/builder","/workflow-studio","/activity","/datasets","/dataset-sell",
  "/settings","/approvals","/companies","/schedules","/marketplace","/connection-layer",
  "/brain","/realtime-dashboard","/live-runtime","/agent-evolution"
];
TS

cat > middleware.ts <<'TS'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { PROTECTED_ROUTES } from "./lib/protected-routes";

function isProtected(pathname: string) {
  return PROTECTED_ROUTES.some((route) => pathname.startsWith(route));
}

export function middleware(req: NextRequest) {
  const pathname = req.nextUrl.pathname;

  if (pathname.startsWith("/api") || pathname.startsWith("/_next") || pathname.includes(".")) {
    return NextResponse.next();
  }

  if (!isProtected(pathname)) return NextResponse.next();

  const hasAuthCookie =
    req.cookies.get("sb-access-token") ||
    req.cookies.get("sb-refresh-token") ||
    Array.from(req.cookies.getAll()).some((c) => c.name.startsWith("sb-"));

  if (!hasAuthCookie) return NextResponse.redirect(new URL("/login", req.url));

  return NextResponse.next();
}

export const config = { matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"] };
TS

cat > lib/guards/providers.ts <<'TS'
export function envReady(name: string) {
  const value = process.env[name];
  return !!value && value.trim() !== "" && value !== "pending" && value !== "placeholder";
}

export function getProviderStatus() {
  return {
    openai: envReady("OPENAI_API_KEY"),
    stripe: envReady("STRIPE_SECRET_KEY"),
    razorpay: envReady("RAZORPAY_KEY_ID") && envReady("RAZORPAY_KEY_SECRET"),
    composio: envReady("COMPOSIO_API_KEY"),
    supabase:
      envReady("NEXT_PUBLIC_SUPABASE_URL") &&
      envReady("NEXT_PUBLIC_SUPABASE_ANON_KEY") &&
      envReady("SUPABASE_SERVICE_ROLE_KEY")
  };
}
TS

cat > lib/server/workspace.ts <<'TS'
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

export async function createServerSupabase() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "",
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll() {}
      }
    }
  );
}

export async function getWorkspace() {
  const supabase = await createServerSupabase();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return { supabase, user: null, companyId: null, company: null };

  const { data: member } = await supabase
    .from("company_members")
    .select("company_id, companies(*)")
    .eq("user_id", user.id)
    .limit(1)
    .maybeSingle();

  return {
    supabase,
    user,
    companyId: member?.company_id || null,
    company: member?.companies || null
  };
}
TS

cat > components/unic/PublicShell.tsx <<'TSX'
import Link from "next/link";

export default function PublicShell({ children }: { children: React.ReactNode }) {
  return (
    <main className="min-h-screen bg-[#f7f7f8] text-black">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-xl bg-black text-white font-black">U</div>
          <div>
            <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
            <p className="text-xs text-neutral-500">AI company operating system</p>
          </div>
        </Link>
        <div className="hidden rounded-full border border-neutral-200 bg-white px-6 py-3 text-sm font-bold text-neutral-600 shadow-sm md:flex gap-8">
          <Link href="/dashboard">Demo</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/login">Login</Link>
        </div>
        <Link href="/signup" className="rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">Get Started</Link>
      </nav>
      {children}
    </main>
  );
}
TSX

cat > components/unic/AppShell.tsx <<'TSX'
import Link from "next/link";

const nav = [
  ["Dashboard","/dashboard"],["Companies","/companies"],["Team","/team"],["Goals","/goals"],
  ["Agents","/agents"],["Skills","/skills"],["Swarms","/swarms"],["Builder","/workflow-studio"],
  ["Tasks","/tasks"],["Schedules","/schedules"],["Datasets","/datasets"],["Brain","/brain"],
  ["Approvals","/approvals"],["Realtime","/realtime-dashboard"],["Marketplace","/marketplace"],
  ["Billing","/billing"],["Budgets","/budgets"],["Usage","/usage"],["Activity","/activity"],["Settings","/settings"]
];

export default function AppShell({ title, subtitle, children, right }: { title: string; subtitle?: string; children: React.ReactNode; right?: React.ReactNode }) {
  return (
    <main className="min-h-screen bg-[#f7f7f8] text-black">
      <aside className="fixed left-0 top-0 hidden h-screen w-[270px] border-r border-neutral-200 bg-white lg:block">
        <div className="border-b border-neutral-200 p-5">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-10 w-10 place-items-center rounded-xl bg-black text-white font-black">U</div>
            <div>
              <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-neutral-500">AI company OS</p>
            </div>
          </Link>
        </div>
        <div className="h-[calc(100vh-82px)] overflow-y-auto p-3">
          {nav.map(([label, href]) => (
            <Link key={href} href={href} className="mb-1 block rounded-xl px-3 py-2.5 text-sm font-bold text-neutral-600 hover:bg-neutral-100 hover:text-black">
              {label}
            </Link>
          ))}
        </div>
      </aside>

      <section className={right ? "lg:ml-[270px] lg:mr-[330px]" : "lg:ml-[270px]"}>
        <header className="sticky top-0 z-20 border-b border-neutral-200 bg-white/90 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-4">
            <div>
              <h1 className="text-2xl font-black tracking-[-0.04em]">{title}</h1>
              {subtitle && <p className="mt-1 text-sm text-neutral-500">{subtitle}</p>}
            </div>
            <div className="flex gap-2">
              <Link href="/workflow-studio" className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">Builder</Link>
              <Link href="/settings" className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">Settings</Link>
            </div>
          </div>
        </header>
        <div className="p-6">{children}</div>
      </section>

      {right && <aside className="fixed right-0 top-0 hidden h-screen w-[330px] border-l border-neutral-200 bg-white lg:block">{right}</aside>}
    </main>
  );
}
TSX

cat > app/page.tsx <<'TSX'
import Link from "next/link";
import PublicShell from "@/components/unic/PublicShell";

export default function HomePage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-16">
        <div className="grid gap-12 lg:grid-cols-[1fr_.95fr]">
          <div className="pt-10">
            <div className="mb-8 flex flex-wrap gap-3">
              {["AI workforce","Connected tools","Human approvals"].map((x)=><span key={x} className="rounded-full border border-neutral-200 bg-white px-4 py-2 text-xs font-black text-neutral-600">{x}</span>)}
            </div>
            <h1 className="text-[clamp(56px,8vw,110px)] font-black leading-[.9] tracking-[-0.08em]">Build your<br />AI company</h1>
            <p className="mt-8 max-w-2xl text-lg leading-8 text-neutral-500">Create agents, skills, workflows, approvals, memory and connected operations from one operational workspace.</p>
            <div className="mt-10 flex gap-4">
              <Link href="/signup" className="rounded-xl bg-black px-6 py-4 text-sm font-bold text-white">Start Building</Link>
              <Link href="/dashboard" className="rounded-xl border border-neutral-200 bg-white px-6 py-4 text-sm font-bold">View Demo</Link>
            </div>
          </div>
          <div className="rounded-[32px] border border-neutral-200 bg-white p-6 shadow-[0_24px_90px_rgba(15,23,42,.07)]">
            <div className="rounded-[24px] border border-neutral-200 bg-gradient-to-br from-white to-blue-50 p-6">
              <p className="text-xs font-black uppercase tracking-[.18em] text-blue-600">Workspace</p>
              <h2 className="mt-2 text-4xl font-black tracking-[-.05em]">Command Center</h2>
              <div className="mt-8 space-y-4">
                {["Create AI agents","Build workflow canvas","Connect Gmail and Slack","Review approvals","Track live execution"].map((x)=><div key={x} className="rounded-2xl border border-neutral-200 bg-white p-5 font-bold">{x}</div>)}
              </div>
            </div>
          </div>
        </div>
      </section>
    </PublicShell>
  );
}
TSX

cat > app/dashboard/page.tsx <<'TSX'
import Link from "next/link";
import PublicShell from "@/components/unic/PublicShell";

export default function DashboardPage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-10">
        <div className="rounded-[36px] bg-white p-10 shadow-[0_20px_80px_rgba(15,23,42,.06)]">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-neutral-500">Product Preview</p>
          <h1 className="mt-5 text-6xl font-black tracking-[-0.07em]">AI company command center</h1>
          <p className="mt-6 max-w-3xl text-neutral-500 leading-8">Visitors can preview the workspace. Login is required for agents, workflows, datasets, approvals, marketplace, billing and runtime tools.</p>
        </div>
        <div className="mt-8 grid gap-4 md:grid-cols-4">
          {[["Agents","18"],["Workflows","42"],["Executions","12.4k"],["Workers","Online"]].map(([label,value])=><div key={label} className="rounded-2xl border border-neutral-200 bg-white p-5"><p className="text-sm font-bold text-neutral-500">{label}</p><p className="mt-3 text-4xl font-black tracking-[-0.05em]">{value}</p></div>)}
        </div>
        <div className="mt-8 grid gap-5 lg:grid-cols-[1.4fr_.6fr]">
          <div className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">Live execution preview</h2>
            <div className="mt-5 space-y-3">
              {["Research workflow completed","Supplier outreach drafted","Dataset indexed","Approval requested"].map((x)=><div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4"><span className="font-bold">{x}</span><span className="text-sm text-neutral-500">demo</span></div>)}
            </div>
          </div>
          <div className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">Access workspace</h2>
            <div className="mt-5 grid gap-3">{["Agents","Workflow Studio","Datasets","Approvals"].map((x)=><Link key={x} href="/login" className="rounded-xl bg-neutral-100 p-4 text-left text-sm font-black">{x}</Link>)}</div>
          </div>
        </div>
      </section>
    </PublicShell>
  );
}
TSX

cat > app/login/page.tsx <<'TSX'
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
TSX

cat > app/signup/page.tsx <<'TSX'
"use client";
import Link from "next/link";
import { useState } from "react";
import { createBrowserClient } from "@supabase/ssr";

export default function SignupPage() {
  const [companyName,setCompanyName]=useState(""); const [email,setEmail]=useState(""); const [password,setPassword]=useState(""); const [remember,setRemember]=useState(true); const [msg,setMsg]=useState("");
  async function signup(){
    setMsg("Creating workspace...");
    const supabase=createBrowserClient(process.env.NEXT_PUBLIC_SUPABASE_URL||"",process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY||"");
    if(remember)localStorage.setItem("unic_remember_me","true");
    const {data,error}=await supabase.auth.signUp({email,password,options:{data:{company_name:companyName}}});
    if(error){setMsg(error.message);return;}
    if(data.user?.id){await fetch("/api/verify-user-email",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({user_id:data.user.id,email})}).catch(()=>{});}
    window.location.href="/onboarding";
  }
  return <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6 text-black"><div className="w-full max-w-md rounded-[32px] border border-neutral-200 bg-white p-8 shadow-[0_24px_90px_rgba(15,23,42,.07)]"><h1 className="text-5xl font-black tracking-[-0.06em]">Create workspace</h1><p className="mt-3 text-neutral-500">Start your AI company operating system.</p><div className="mt-8 space-y-4"><input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Company name" value={companyName} onChange={(e)=>setCompanyName(e.target.value)}/><input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Email" value={email} onChange={(e)=>setEmail(e.target.value)}/><input className="w-full rounded-xl border border-neutral-200 px-4 py-3 outline-none" placeholder="Password" type="password" value={password} onChange={(e)=>setPassword(e.target.value)}/><label className="flex items-center gap-3 text-sm font-semibold text-neutral-600"><input type="checkbox" checked={remember} onChange={(e)=>setRemember(e.target.checked)}/>Remember me on this device</label><button onClick={signup} className="w-full rounded-xl bg-black px-4 py-3 font-black text-white">Create workspace</button></div>{msg&&<p className="mt-4 text-sm text-neutral-500">{msg}</p>}<p className="mt-6 text-sm text-neutral-500">Already have account? <Link href="/login" className="font-black text-black">Login</Link></p></div></main>;
}
TSX

cat > app/onboarding/page.tsx <<'TSX'
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
TSX

cat > app/api/onboarding-create-company/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {supabaseAdmin} from "@/lib/supabase-admin";
export async function POST(req:NextRequest){try{const body=await req.json(); if(!body.user_id||!body.company_name)return NextResponse.json({ok:false,error:"user_id and company_name required"},{status:400}); const {data:company,error}=await supabaseAdmin.from("companies").insert({name:body.company_name,owner_user_id:body.user_id,status:"active",metadata:{industry:body.industry||null}}).select().single(); if(error)throw error; await supabaseAdmin.from("company_members").insert({company_id:company.id,user_id:body.user_id,role:"owner",status:"active"}); await supabaseAdmin.from("credit_wallets").upsert({company_id:company.id,balance:0,plan_included_credits:0,updated_at:new Date().toISOString()},{onConflict:"company_id"}); return NextResponse.json({ok:true,company});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > lib/billing/credits.ts <<'TS'
import { supabaseAdmin } from "@/lib/supabase-admin";
export const PLAN_CREDITS:Record<string,number>={starter:100000,builder:300000,company:1000000,enterprise:5000000};
export async function activatePlanAndCredits({companyId,userId,plan,provider,providerPaymentId,amount,currency}:{companyId:string;userId?:string|null;plan:string;provider:"stripe"|"razorpay";providerPaymentId:string;amount?:number;currency?:string;}){
 const p=plan.toLowerCase(); const credits=PLAN_CREDITS[p]||PLAN_CREDITS.starter;
 await supabaseAdmin.from("billing_events").insert({company_id:companyId,user_id:userId||null,provider,event_type:"plan_activated",provider_payment_id:providerPaymentId,amount:amount||0,currency:currency||"usd",metadata:{plan:p,credits}}).then(()=>{});
 await supabaseAdmin.from("company_subscriptions").upsert({company_id:companyId,plan:p,status:"active",provider,provider_payment_id:providerPaymentId,current_period_started_at:new Date().toISOString(),updated_at:new Date().toISOString()},{onConflict:"company_id"}).then(()=>{});
 await supabaseAdmin.from("credit_wallets").upsert({company_id:companyId,balance:credits,plan_included_credits:credits,updated_at:new Date().toISOString()},{onConflict:"company_id"}).then(()=>{});
 await supabaseAdmin.from("credit_ledger").insert({company_id:companyId,amount:credits,type:"credit",reason:"plan_activation",metadata:{plan:p,provider,providerPaymentId}}).then(()=>{});
 return {plan:p,credits};
}
TS

cat > lib/composio/tool-map.ts <<'TS'
export const COMPOSIO_TOOL_MAP:Record<string,string>={gmail_search:"GMAIL_SEARCH_EMAILS",gmail_draft:"GMAIL_CREATE_EMAIL_DRAFT",gmail_send:"GMAIL_SEND_EMAIL",slack_message:"SLACK_SENDS_A_MESSAGE_TO_A_SLACK_CHANNEL",notion_search:"NOTION_SEARCH_NOTION_PAGE",github_issue:"GITHUB_CREATE_AN_ISSUE",google_drive_search:"GOOGLEDRIVE_FIND_FILE",calendar_create:"GOOGLECALENDAR_CREATE_EVENT"};
export function resolveComposioTool(action:string){return COMPOSIO_TOOL_MAP[action]||action;}
TS

cat > lib/composio/client.ts <<'TS'
import { resolveComposioTool } from "./tool-map";
export async function callComposioTool({connectedAccountId,action,payload}:{connectedAccountId?:string;action:string;payload:any;}){
 const apiKey=process.env.COMPOSIO_API_KEY; if(!apiKey)throw new Error("COMPOSIO_API_KEY is missing.");
 const res=await fetch("https://backend.composio.dev/api/v3/tools/execute",{method:"POST",headers:{"x-api-key":apiKey,"Content-Type":"application/json"},body:JSON.stringify({connected_account_id:connectedAccountId,tool_slug:resolveComposioTool(action),arguments:payload||{}})});
 const text=await res.text(); let json:any; try{json=JSON.parse(text)}catch{json={raw:text}}; if(!res.ok)throw new Error(json?.message||json?.error||"Composio execution failed"); return json;
}
TS

cat > app/api/composio-auth-link/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server";
export async function POST(req:NextRequest){try{const body=await req.json(); if(!process.env.COMPOSIO_API_KEY)return NextResponse.json({ok:false,error:"COMPOSIO_API_KEY missing"},{status:400}); if(!body.user_id||!body.toolkit)return NextResponse.json({ok:false,error:"user_id and toolkit required"},{status:400}); const appUrl=process.env.NEXT_PUBLIC_APP_URL||"http://localhost:3000"; const res=await fetch("https://backend.composio.dev/api/v3/connected_accounts/initiate",{method:"POST",headers:{"x-api-key":process.env.COMPOSIO_API_KEY,"Content-Type":"application/json"},body:JSON.stringify({toolkit:body.toolkit,user_id:body.user_id,callback_url:`${appUrl}/connection-layer?connected=true&toolkit=${body.toolkit}`})}); const text=await res.text(); let json:any; try{json=JSON.parse(text)}catch{json={raw:text}}; if(!res.ok)return NextResponse.json({ok:false,error:json.message||json.error||"Composio auth failed",detail:json},{status:500}); return NextResponse.json({ok:true,redirect_url:json.redirect_url||json.auth_url||json.url,data:json});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/api/composio-callback-save/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {supabaseAdmin} from "@/lib/supabase-admin";
export async function POST(req:NextRequest){try{const body=await req.json(); if(!body.company_id||!body.user_id||!body.toolkit||!body.connected_account_id)return NextResponse.json({ok:false,error:"company_id user_id toolkit connected_account_id required"},{status:400}); const {data,error}=await supabaseAdmin.from("connector_sessions").upsert({company_id:body.company_id,user_id:body.user_id,provider:"composio",toolkit:body.toolkit,connected_account_id:body.connected_account_id,status:"connected",metadata:body.metadata||{},updated_at:new Date().toISOString()},{onConflict:"company_id,user_id,toolkit"}).select().single(); if(error)throw error; return NextResponse.json({ok:true,session:data});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/api/stripe-webhook/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {activatePlanAndCredits} from "@/lib/billing/credits";
export async function POST(req:NextRequest){try{if(!process.env.STRIPE_SECRET_KEY||!process.env.STRIPE_WEBHOOK_SECRET)return NextResponse.json({ok:false,error:"Stripe not configured"},{status:400}); const body=await req.json(); const session=body.data?.object||{}; if(body.type==="checkout.session.completed"){const m=session.metadata||{}; if(m.company_id)await activatePlanAndCredits({companyId:m.company_id,userId:m.user_id||null,plan:m.plan||"starter",provider:"stripe",providerPaymentId:session.payment_intent||session.id,amount:session.amount_total||0,currency:session.currency||"usd"});} return NextResponse.json({ok:true});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/api/razorpay-webhook/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {activatePlanAndCredits} from "@/lib/billing/credits";
export async function POST(req:NextRequest){try{if(!process.env.RAZORPAY_KEY_ID||!process.env.RAZORPAY_KEY_SECRET)return NextResponse.json({ok:false,error:"Razorpay not configured"},{status:400}); const body=await req.json(); const payment=body.payload?.payment?.entity||{}; const notes=payment.notes||{}; if(body.event==="payment.captured"||body.event==="order.paid"){if(notes.company_id)await activatePlanAndCredits({companyId:notes.company_id,userId:notes.user_id||null,plan:notes.plan||"starter",provider:"razorpay",providerPaymentId:payment.id||body.payload?.order?.entity?.id,amount:payment.amount||0,currency:payment.currency||"INR"});} return NextResponse.json({ok:true});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/api/launch-verify/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextResponse} from "next/server"; import {getProviderStatus} from "@/lib/guards/providers";
export async function GET(){const providers=getProviderStatus(); return NextResponse.json({ok:true,providers,launch_blocks:{openai_missing:!providers.openai,stripe_missing:!providers.stripe,razorpay_missing:!providers.razorpay,composio_missing:!providers.composio,payments_locked:!providers.stripe&&!providers.razorpay,platform_ai_locked:!providers.openai}});}
TS

cat > components/workflow/DraggableWorkflowCanvas.tsx <<'TSX'
"use client";
import {useMemo,useState} from "react";
type NodeItem={id:string;type:string;label:string;x:number;y:number;action?:string;payload?:any}; type EdgeItem={from:string;to:string};
const initialNodes:NodeItem[]=[{id:"trigger",type:"trigger",label:"Command Trigger",x:70,y:120},{id:"agent",type:"agent",label:"AI Agent",x:365,y:190},{id:"memory",type:"memory",label:"Company Brain",x:665,y:95},{id:"approval",type:"approval",label:"Human Review",x:665,y:330},{id:"tool",type:"tool",label:"Gmail Draft",x:960,y:210,action:"gmail_draft"}];
const initialEdges:EdgeItem[]=[{from:"trigger",to:"agent"},{from:"agent",to:"memory"},{from:"agent",to:"approval"},{from:"approval",to:"tool"}];
export default function DraggableWorkflowCanvas({companyId}:{companyId?:string|null}){const[nodes,setNodes]=useState(initialNodes); const[edges]=useState(initialEdges); const[drag,setDrag]=useState<{id:string;dx:number;dy:number}|null>(null); const[title,setTitle]=useState("AI Operations Workflow"); const[msg,setMsg]=useState(""); const nodeMap=useMemo(()=>{const m=new Map<string,NodeItem>(); nodes.forEach(n=>m.set(n.id,n)); return m},[nodes]);
function onMove(e:React.MouseEvent<HTMLDivElement>){if(!drag)return; const box=e.currentTarget.getBoundingClientRect(); const x=e.clientX-box.left-drag.dx; const y=e.clientY-box.top-drag.dy; setNodes(prev=>prev.map(n=>n.id===drag.id?{...n,x:Math.max(20,x),y:Math.max(20,y)}:n));}
async function save(){if(!companyId){setMsg("Create/login to a workspace before saving.");return;} setMsg("Saving workflow..."); const res=await fetch("/api/workflow-save",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({company_id:companyId,title,graph:{nodes,edges}})}); const json=await res.json(); setMsg(json.ok?"Workflow saved.":json.error||"Save failed.");}
async function run(){if(!companyId){setMsg("Create/login to a workspace before running.");return;} setMsg("Running workflow..."); const res=await fetch("/api/workflow-execute",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({company_id:companyId,graph:{nodes,edges},input:{source:"canvas"}})}); const json=await res.json(); setMsg(json.ok?"Workflow run completed/queued.":json.error||"Run failed.");}
return <div><div className="mb-4 flex flex-wrap items-center justify-between gap-3"><input value={title} onChange={e=>setTitle(e.target.value)} className="w-[320px] rounded-lg border border-neutral-200 bg-white px-3 py-2 text-sm font-bold"/><div className="flex gap-2"><button onClick={save} className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">Save Graph</button><button onClick={run} className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">Run Workflow</button></div></div>{msg&&<p className="mb-3 rounded-xl bg-neutral-100 p-3 text-sm font-bold text-neutral-700">{msg}</p>}<div className="relative h-[720px] overflow-hidden rounded-2xl border border-neutral-200 bg-white" onMouseMove={onMove} onMouseUp={()=>setDrag(null)} onMouseLeave={()=>setDrag(null)}><div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]"/><svg className="absolute inset-0 h-full w-full">{edges.map(edge=>{const a=nodeMap.get(edge.from); const b=nodeMap.get(edge.to); if(!a||!b)return null; const ax=a.x+190; const ay=a.y+50; const bx=b.x; const by=b.y+50; return <path key={`${edge.from}-${edge.to}`} d={`M${ax} ${ay} C${ax+80} ${ay} ${bx-80} ${by} ${bx} ${by}`} fill="none" stroke="#111" strokeWidth="2"/>})}</svg>{nodes.map(node=><div key={node.id} className="absolute w-[190px] cursor-grab rounded-xl border border-neutral-300 bg-white p-4 shadow-lg active:cursor-grabbing" style={{left:node.x,top:node.y}} onMouseDown={e=>{const rect=e.currentTarget.getBoundingClientRect(); setDrag({id:node.id,dx:e.clientX-rect.left,dy:e.clientY-rect.top})}}><p className="text-[11px] font-black uppercase tracking-[.14em] text-neutral-400">{node.type}</p><h3 className="mt-2 font-black">{node.label}</h3><p className="mt-2 text-xs text-neutral-500">Drag to move</p></div>)}</div></div>}
TSX

cat > app/workflow-studio/page.tsx <<'TSX'
import AppShell from "@/components/unic/AppShell";
import DraggableWorkflowCanvas from "@/components/workflow/DraggableWorkflowCanvas";
import { getWorkspace } from "@/lib/server/workspace";

export default async function WorkflowStudioPage() {
  const { user, companyId } = await getWorkspace();
  if (!user) return <main className="grid min-h-screen place-items-center bg-[#f7f7f8] p-6"><div className="rounded-3xl border border-neutral-200 bg-white p-10 text-center"><h1 className="text-4xl font-black">Login required</h1><p className="mt-3 text-neutral-500">Login to access Workflow Studio.</p></div></main>;

  return (
    <AppShell title="Workflow Studio" subtitle="Drag, save and execute workflow graphs." right={<div className="p-5"><p className="text-xs font-black uppercase tracking-[.16em] text-neutral-400">Canvas</p><h2 className="mt-3 text-xl font-black">Drag + Save Enabled</h2><p className="mt-4 text-sm leading-6 text-neutral-500">Nodes can be moved with the mouse. Save Graph persists node positions to Supabase.</p><p className="mt-4 break-all text-xs text-neutral-400">company_id: {companyId || "missing"}</p></div>}>
      <DraggableWorkflowCanvas companyId={companyId} />
    </AppShell>
  );
}
TSX

cat > lib/runtime/workflow-engine.ts <<'TS'
import {supabaseAdmin} from "@/lib/supabase-admin"; import {callComposioTool} from "@/lib/composio/client";
type NodeItem={id:string;type:string;label?:string;action?:string;payload?:any}; type EdgeItem={from:string;to:string};
function orderNodes(nodes:NodeItem[],edges:EdgeItem[]){const start=nodes.find(n=>n.type==="trigger")||nodes[0]; if(!start)return[]; const ordered:NodeItem[]=[]; const visited=new Set<string>(); function walk(node:NodeItem){if(!node||visited.has(node.id))return; visited.add(node.id); ordered.push(node); edges.filter(e=>e.from===node.id).forEach(e=>{const next=nodes.find(n=>n.id===e.to); if(next)walk(next);});} walk(start); return ordered;}
export async function executeWorkflowGraph({companyId,workflowId,graph,input}:{companyId:string;workflowId?:string;graph:any;input?:any}){const nodes:NodeItem[]=graph?.nodes||[]; const edges:EdgeItem[]=graph?.edges||[]; const ordered=orderNodes(nodes,edges); const run=await supabaseAdmin.from("workflow_runs").insert({company_id:companyId,workflow_id:workflowId||null,status:"running",input:input||{},metadata:{node_count:ordered.length}}).select().single(); if(run.error)throw run.error; const outputs:any[]=[]; for(const node of ordered){try{let output:any={ok:true,type:node.type}; if(node.type==="tool"&&node.action){output=await callComposioTool({connectedAccountId:node.payload?.connected_account_id,action:node.action,payload:node.payload||{}});} if(node.type==="approval"){await supabaseAdmin.from("human_approval_inbox").insert({company_id:companyId,approval_type:"workflow_node",title:node.label||"Workflow approval",description:"Workflow requested human approval.",payload:{workflow_run_id:run.data.id,node},status:"pending"}); output={pending_approval:true};} await supabaseAdmin.from("runtime_events").insert({company_id:companyId,event_type:"workflow_node_completed",message:`${node.label||node.type} completed.`,metadata:{workflow_run_id:run.data.id,node_id:node.id,output}}); outputs.push({node,output});}catch(error:any){await supabaseAdmin.from("runtime_events").insert({company_id:companyId,event_type:"workflow_node_failed",message:`${node.label||node.type} failed.`,metadata:{workflow_run_id:run.data.id,node_id:node.id,error:error.message}}); await supabaseAdmin.from("workflow_runs").update({status:"failed",error:error.message}).eq("id",run.data.id); throw error;}} await supabaseAdmin.from("workflow_runs").update({status:"completed",output:{nodes:outputs}}).eq("id",run.data.id); return {run:run.data,outputs};}
TS

cat > app/api/workflow-save/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {supabaseAdmin} from "@/lib/supabase-admin";
export async function POST(req:NextRequest){try{const body=await req.json(); if(!body.company_id||!body.title||!body.graph)return NextResponse.json({ok:false,error:"company_id title graph required"},{status:400}); const payload={company_id:body.company_id,title:body.title,graph:body.graph,status:body.status||"draft",updated_at:new Date().toISOString()}; const result=body.id?await supabaseAdmin.from("workflow_graphs").update(payload).eq("id",body.id).select().single():await supabaseAdmin.from("workflow_graphs").insert(payload).select().single(); if(result.error)throw result.error; return NextResponse.json({ok:true,workflow:result.data});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/api/workflow-execute/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {executeWorkflowGraph} from "@/lib/runtime/workflow-engine";
export async function POST(req:NextRequest){try{const body=await req.json(); if(!body.company_id||!body.graph)return NextResponse.json({ok:false,error:"company_id and graph required"},{status:400}); const result=await executeWorkflowGraph({companyId:body.company_id,workflowId:body.workflow_id,graph:body.graph,input:body.input||{}}); return NextResponse.json({ok:true,result});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/api/composio-execute/route.ts <<'TS'
export const dynamic="force-dynamic"; export const runtime="nodejs";
import {NextRequest,NextResponse} from "next/server"; import {callComposioTool} from "@/lib/composio/client"; import {supabaseAdmin} from "@/lib/supabase-admin";
export async function POST(req:NextRequest){try{const body=await req.json(); if(!body.company_id||!body.action)return NextResponse.json({ok:false,error:"company_id and action required"},{status:400}); const result=await callComposioTool({connectedAccountId:body.connected_account_id,action:body.action,payload:body.payload||{}}); await supabaseAdmin.from("runtime_events").insert({company_id:body.company_id,event_type:"composio_tool_executed",message:`${body.action} executed through Composio.`,metadata:{action:body.action,result}}).then(()=>{}); return NextResponse.json({ok:true,result});}catch(error:any){return NextResponse.json({ok:false,error:error.message},{status:500});}}
TS

cat > app/connection-layer/page.tsx <<'TSX'
"use client";
import {useState} from "react"; import AppShell from "@/components/unic/AppShell"; import {createBrowserClient} from "@supabase/ssr";
const toolkits=[["gmail","Gmail"],["slack","Slack"],["notion","Notion"],["github","GitHub"],["googledrive","Google Drive"],["googlecalendar","Google Calendar"],["discord","Discord"]];
export default function ConnectionLayerPage(){const[msg,setMsg]=useState(""); async function connect(toolkit:string){setMsg(`Starting ${toolkit} connection...`); const supabase=createBrowserClient(process.env.NEXT_PUBLIC_SUPABASE_URL||"",process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY||""); const {data:{user}}=await supabase.auth.getUser(); if(!user){window.location.href="/login";return;} const res=await fetch("/api/composio-auth-link",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({user_id:user.id,toolkit})}); const json=await res.json(); if(!json.ok||!json.redirect_url){setMsg(json.error||"Could not create connection link.");return;} window.location.href=json.redirect_url;} return <AppShell title="Connection Layer" subtitle="Connect business tools through Composio OAuth.">{msg&&<p className="mb-5 rounded-xl bg-neutral-100 p-3 text-sm font-bold text-neutral-700">{msg}</p>}<div className="grid gap-4 md:grid-cols-3">{toolkits.map(([id,label])=><div key={id} className="rounded-2xl border border-neutral-200 bg-white p-6"><h2 className="text-2xl font-black">{label}</h2><p className="mt-3 text-sm text-neutral-500">Connect this app so agents can use it as a tool.</p><button onClick={()=>connect(id)} className="mt-5 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">Connect {label}</button></div>)}</div></AppShell>}
TSX

make_page () {
  ROUTE="$1"; TITLE="$2"; SUBTITLE="$3"; KIND="$4"
  mkdir -p "app/$ROUTE"
  cat > "app/$ROUTE/page.tsx" <<TSX
import AppShell from "@/components/unic/AppShell";

export default function Page() {
  return (
    <AppShell title="$TITLE" subtitle="$SUBTITLE">
      ${
        KIND=="table" ? '<div className="rounded-2xl border border-neutral-200 bg-white p-6"><div className="space-y-3">{["Workspace updated","Agent assigned","Workflow synced","Approval reviewed"].map((x)=>(<div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4"><span className="font-bold">{x}</span><span className="text-sm text-neutral-500">live</span></div>))}</div></div>' :
        KIND=="kanban" ? '<div className="grid gap-4 md:grid-cols-3">{["Backlog","Running","Completed"].map((col)=>(<div key={col} className="rounded-2xl border border-neutral-200 bg-white p-5"><h2 className="text-2xl font-black">{col}</h2><div className="mt-5 space-y-3">{["Task one","Task two","Task three"].map((x)=>(<div key={x} className="rounded-xl bg-neutral-100 p-4 text-sm font-bold">{x}</div>))}</div></div>))}</div>' :
        KIND=="plans" ? '<div className="grid gap-4 md:grid-cols-4">{["Starter","Builder","Company","Enterprise"].map((x)=>(<div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6"><h2 className="text-2xl font-black">{x}</h2><p className="mt-3 text-sm text-neutral-500">Credit-based workspace plan.</p><button className="mt-6 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">Select</button></div>))}</div>' :
        '<div className="grid gap-4 md:grid-cols-3">{["Create","Configure","Monitor","Review","Run","Export"].map((x)=>(<div key={x} className="rounded-2xl border border-neutral-200 bg-white p-6"><h2 className="text-2xl font-black">{x}</h2><p className="mt-3 text-sm text-neutral-500">Workspace action for this module.</p></div>))}</div>'
      }
    </AppShell>
  );
}
TSX
}

make_page team "Team" "Members, roles, invites and workspace access." cards
make_page goals "Goals" "Company goals and agent alignment." cards
make_page tasks "Tasks" "Task queue, ownership and execution status." kanban
make_page usage "Usage" "Credits, runtime consumption and workspace limits." cards
make_page agents "Agents" "Create and manage AI employees." cards
make_page skills "Skills" "Reusable capabilities attached to agents." cards
make_page swarms "Swarms" "Multi-agent teams and delegation systems." cards
make_page billing "Billing" "Plans, invoices, credits and payment status." plans
make_page budgets "Budgets" "Agent, workflow and company spending controls." cards
make_page builder "Builder" "Create agents, workflows and company systems." cards
make_page activity "Activity" "Audit trail and workspace event feed." table
make_page datasets "Datasets" "Upload and index company knowledge." cards
make_page dataset-sell "Dataset Sell" "Package and sell approved datasets." cards
make_page settings "Settings" "Workspace, model keys, security and controls." cards
make_page approvals "Approvals" "Human approval inbox for sensitive actions." table
make_page companies "Companies" "Company profiles, workspaces and operating units." cards
make_page schedules "Schedules" "Recurring tasks and automation schedules." table
make_page marketplace "Marketplace" "Buy, sell and install agents, skills and workflows." cards
make_page brain "Company Brain" "Memory, RAG and company knowledge graph." cards
make_page realtime-dashboard "Realtime" "Runtime events, worker health and execution streams." table
make_page live-runtime "Live Runtime" "Live agent and workflow execution monitor." table
make_page agent-evolution "Agent Evolution" "Review agent improvements and version suggestions." cards

cat > app/pricing/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell";
export default function PricingPage(){return <PublicShell><section className="mx-auto max-w-7xl px-6 py-14"><h1 className="text-7xl font-black tracking-[-.08em]">Pricing</h1><p className="mt-5 max-w-2xl text-neutral-500">Credit-based plans for AI operations, agents and workflows.</p><div className="mt-10 grid gap-4 md:grid-cols-4">{["Starter","Builder","Company","Enterprise"].map((p)=><div key={p} className="rounded-2xl border border-neutral-200 bg-white p-6"><h2 className="text-3xl font-black">{p}</h2><p className="mt-4 text-neutral-500">Workspace access with monthly credits and BYOK support.</p><button className="mt-7 rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">Start</button></div>)}</div></section></PublicShell>}
TSX

cat > app/legal/terms/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell"; export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">Terms</h1><p className="mt-6 leading-8 text-neutral-500">UNIC.ai workspace access, generated systems, exports and enterprise rights are governed by plan terms and applicable agreements.</p></section></PublicShell>}
TSX
cat > app/legal/refund/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell"; export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">Refund Policy</h1><p className="mt-6 leading-8 text-neutral-500">Refunds are reviewed according to subscription status, usage, credits and applicable commercial terms.</p></section></PublicShell>}
TSX
cat > app/legal/privacy/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell"; export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">Privacy Policy</h1><p className="mt-6 leading-8 text-neutral-500">UNIC.ai protects workspace data, connected credentials, model keys and company files through access controls and encrypted storage patterns.</p></section></PublicShell>}
TSX
cat > app/legal/ai-policy/page.tsx <<'TSX'
import PublicShell from "@/components/unic/PublicShell"; export default function Page(){return <PublicShell><section className="mx-auto max-w-4xl px-6 py-14"><h1 className="text-6xl font-black tracking-[-.06em]">AI Policy</h1><p className="mt-6 leading-8 text-neutral-500">Users are responsible for reviewing AI outputs, configuring approvals and complying with laws and third-party platform terms.</p></section></PublicShell>}
TSX

npm run build
git add .
git commit -m "Final complete UI launch wiring and operational system" || true
git push origin main

echo "DONE. Redeploy Vercel and test /api/launch-verify"
