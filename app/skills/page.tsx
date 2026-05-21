import AppShell from "@/components/layout/AppShell";

const skills = ["Research", "Sales Outreach", "PDF Analysis", "Code Review", "Financial Analysis", "Legal Review", "Gmail Assistant", "Slack Reporter"];

export default function SkillsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[36px] bg-gradient-to-br from-blue-600 to-slate-950 p-10 text-white">
          <h1 className="text-6xl font-black tracking-[-0.07em]">Skills Library</h1>
          <p className="mt-5 max-w-2xl text-white/65 leading-8">Reusable capabilities that can be attached to any agent.</p>
        </div>

        <div className="mt-8 grid gap-5 md:grid-cols-4">
          {skills.map((skill) => (
            <div key={skill} className="rounded-[28px] border border-slate-200 bg-white p-6 shadow-sm">
              <div className="mb-6 h-16 w-16 rounded-2xl bg-blue-50" />
              <h2 className="text-2xl font-black tracking-[-0.05em]">{skill}</h2>
              <p className="mt-3 text-sm leading-6 text-slate-500">Attach this skill to agents and control execution through approvals and permissions.</p>
              <button className="mt-5 rounded-full bg-slate-950 px-5 py-3 text-sm font-bold text-white">Add Skill</button>
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
