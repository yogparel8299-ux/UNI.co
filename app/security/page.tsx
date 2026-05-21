import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function SecurityPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="page-title">Built for trust</h1>
        <p className="page-subtitle mt-6">
          UNIC.ai gives teams control over connected tools, approvals, audit logs, budgets and data boundaries.
        </p>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {[
            ["Approval controls", "Sensitive actions can require human review before execution."],
            ["Encrypted secrets", "Model keys and credentials are encrypted before storage."],
            ["Access governance", "Workspace roles, tool permissions and logs help teams stay in control."]
          ].map(([title, text]) => (
            <div key={title} className="glass-card p-8">
              <h2 className="text-3xl font-black tracking-[-0.05em]">{title}</h2>
              <p className="mt-4 text-slate-500 leading-7">{text}</p>
            </div>
          ))}
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
