import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function AboutPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="page-title">AI operations for modern teams</h1>
        <p className="page-subtitle mt-6">
          UNIC.ai is designed for teams that want AI agents to work across tools, memory, workflows and approvals from one secure workspace.
        </p>

        <div className="soft-panel mt-12 p-10">
          <h2 className="text-4xl font-black tracking-[-0.05em]">Our focus</h2>
          <p className="mt-5 max-w-3xl text-slate-500 leading-8">
            We help users create AI employees, connect business systems, automate repeated work and monitor execution without losing control of important actions.
          </p>
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
