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
