import AppShell from "@/components/layout/AppShell";
import Link from "next/link";

const agents = [
  ["Research Analyst", "Research", "Finds insights and summarizes markets"],
  ["Support Operator", "Support", "Handles tickets and drafts replies"],
  ["Sales Builder", "Sales", "Builds lead lists and outreach"],
  ["Finance Reviewer", "Finance", "Reviews costs and revenue signals"]
];

export default function AgentsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="flex flex-col justify-between gap-6 rounded-[36px] bg-white p-8 shadow-sm lg:flex-row lg:items-end">
          <div>
            <p className="text-sm font-black uppercase tracking-[0.18em] text-blue-600">AI Workforce</p>
            <h1 className="mt-4 text-6xl font-black tracking-[-0.07em]">Agents</h1>
            <p className="mt-5 max-w-2xl text-slate-500 leading-8">Create AI employees, attach skills, connect tools and control how each worker executes tasks.</p>
          </div>
          <Link href="/builder" className="rounded-full bg-slate-950 px-7 py-4 font-bold text-white">Create Agent</Link>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-2 xl:grid-cols-4">
          {agents.map(([name, role, text]) => (
            <div key={name} className="rounded-[32px] border border-slate-200 bg-white p-7 shadow-sm">
              <div className="mb-7 h-24 rounded-[28px] bg-gradient-to-br from-blue-50 via-white to-emerald-50" />
              <p className="text-xs font-black uppercase tracking-[0.16em] text-blue-600">{role}</p>
              <h2 className="mt-3 text-3xl font-black tracking-[-0.05em]">{name}</h2>
              <p className="mt-4 text-slate-500 leading-7">{text}</p>
              <div className="mt-6 flex gap-3">
                <Link href="/skills" className="rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">Skills</Link>
                <Link href="/workflow-studio" className="rounded-full border border-slate-200 px-5 py-3 text-sm font-bold">Workflows</Link>
              </div>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
