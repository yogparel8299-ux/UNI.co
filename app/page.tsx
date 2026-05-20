import Link from "next/link";

export default function HomePage() {
  return (
    <main className="page-shell relative overflow-hidden">
      <div className="orb orb-1" />
      <div className="orb orb-2" />
      <div className="orb orb-3" />

      <nav className="relative z-10 mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <div className="glass flex items-center gap-3 rounded-full px-4 py-3">
          <div className="h-8 w-8 rounded-full bg-white text-black grid place-items-center font-black">U</div>
          <span className="font-black tracking-[-0.03em]">UNIC.ai</span>
        </div>

        <div className="glass hidden rounded-full px-6 py-3 md:flex gap-9 text-sm text-white/75">
          <Link href="/pricing">platform</Link>
          <Link href="/marketplace">marketplace</Link>
          <Link href="/agents">agents</Link>
          <Link href="/connection-layer">connectors</Link>
          <Link href="/legal/ownership">company</Link>
        </div>

        <Link href="/signup" className="primary-button">
          get started
        </Link>
      </nav>

      <section className="relative z-10 mx-auto grid max-w-7xl grid-cols-1 gap-12 px-6 pb-20 pt-20 lg:grid-cols-[1.1fr_.9fr]">
        <div>
          <div className="mb-8 flex flex-wrap gap-3">
            <span className="status-pill">AI company operating system</span>
            <span className="status-pill">BYOK-first</span>
            <span className="status-pill">workers run 24/7</span>
          </div>

          <h1 className="page-title">
            build your<br />AI company
          </h1>

          <p className="page-subtitle mt-8">
            UNIC.ai lets users create AI agents, skills, workflows, departments, approval systems,
            company memory, marketplace assets and autonomous business operations from one premium command center.
          </p>

          <div className="mt-10 flex flex-wrap gap-4">
            <Link href="/signup" className="primary-button">start building</Link>
            <Link href="/login" className="secondary-button">login</Link>
          </div>

          <div className="mt-16 grid grid-cols-3 gap-5 max-w-2xl">
            <div>
              <p className="text-4xl font-black">24/7</p>
              <p className="text-white/45 text-sm mt-2">worker execution</p>
            </div>
            <div>
              <p className="text-4xl font-black">100+</p>
              <p className="text-white/45 text-sm mt-2">connector-ready tools</p>
            </div>
            <div>
              <p className="text-4xl font-black">BYOK</p>
              <p className="text-white/45 text-sm mt-2">profitable by default</p>
            </div>
          </div>
        </div>

        <div className="glass-card p-6 lg:mt-24">
          <div className="rounded-[28px] border border-white/10 bg-black/30 p-6">
            <p className="text-sm text-green-300 font-bold">LIVE COMPANY STACK</p>
            <div className="mt-6 space-y-4">
              {[
                ["AI Boardroom", "strategy decisions, approvals, weekly reports"],
                ["Agents + Skills", "sales, support, finance, research, operations"],
                ["Workflow Studio", "drag/drop execution pipelines"],
                ["Company Brain", "datasets, memory, RAG and context"],
                ["Autopilot", "background workers complete tasks after tabs close"]
              ].map(([title, text]) => (
                <div key={title} className="rounded-3xl border border-white/10 bg-white/[.04] p-5">
                  <h3 className="font-black text-xl">{title}</h3>
                  <p className="text-white/50 mt-2 text-sm leading-6">{text}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="relative z-10 mx-auto max-w-7xl px-6 pb-28">
        <p className="mb-8 text-center text-white/45">Built for founders, operators, agencies and AI-native companies</p>
        <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
          {[
            ["Generate companies", "Create departments, AI employees, SOPs, workflows, business templates and operating systems."],
            ["Connect tools", "Let agents use Gmail, Slack, Notion, GitHub, Drive and other tools through secure connector sessions."],
            ["Control execution", "Approval inbox, budgets, rate limits, subscription locks, rollback and worker monitoring."]
          ].map(([title, text]) => (
            <div className="glass-card p-8" key={title}>
              <div className="mb-10 h-28 rounded-[32px] bg-gradient-to-br from-white/10 via-orange-400/20 to-blue-500/20" />
              <h2 className="text-3xl font-black tracking-[-0.04em]">{title}</h2>
              <p className="mt-5 text-white/55 leading-7">{text}</p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
