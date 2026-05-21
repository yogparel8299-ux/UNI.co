import Link from "next/link";
import PublicShell from "@/components/unic/PublicShell";

export default function DashboardPage() {
  return (
    <PublicShell>
      <section className="mx-auto max-w-7xl px-6 py-10">
        <div className="rounded-[36px] bg-white p-10 shadow-[0_20px_80px_rgba(15,23,42,.06)]">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-neutral-500">Product Preview</p>
          <h1 className="mt-5 text-6xl font-black tracking-[-0.07em]">AI company command center</h1>
          <p className="mt-6 max-w-3xl text-neutral-500 leading-8">
            Visitors can preview the workspace. Login is required for agents, workflows, datasets, approvals, marketplace, billing and runtime tools.
          </p>
        </div>

        <div className="mt-8 grid gap-4 md:grid-cols-4">
          {[
            ["Agents", "18"],
            ["Workflows", "42"],
            ["Executions", "12.4k"],
            ["Workers", "Online"]
          ].map(([label, value]) => (
            <div key={label} className="rounded-2xl border border-neutral-200 bg-white p-5">
              <p className="text-sm font-bold text-neutral-500">{label}</p>
              <p className="mt-3 text-4xl font-black tracking-[-0.05em]">{value}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 grid gap-5 lg:grid-cols-[1.4fr_.6fr]">
          <div className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">Live execution preview</h2>
            <div className="mt-5 space-y-3">
              {["Research workflow completed", "Supplier outreach drafted", "Dataset indexed", "Approval requested"].map((x) => (
                <div key={x} className="flex justify-between rounded-xl border border-neutral-200 p-4">
                  <span className="font-bold">{x}</span>
                  <span className="text-sm text-neutral-500">demo</span>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">Access workspace</h2>
            <div className="mt-5 grid gap-3">
              {["Agents", "Workflow Studio", "Datasets", "Approvals"].map((x) => (
                <Link key={x} href="/login" className="rounded-xl bg-neutral-100 p-4 text-left text-sm font-black">
                  {x}
                </Link>
              ))}
            </div>
          </div>
        </div>
      </section>
    </PublicShell>
  );
}
