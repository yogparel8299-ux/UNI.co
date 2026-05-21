import Link from "next/link";

const cards = [
  {
    title: "AI Agents",
    text: "Create specialized AI workers for operations, research, support, finance and execution."
  },
  {
    title: "Connected Workflows",
    text: "Connect tools, approvals, memory and execution pipelines in one unified operating layer."
  },
  {
    title: "Company Infrastructure",
    text: "Manage teams, permissions, datasets, automations and realtime execution from one workspace."
  }
];

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#f6f8fb] text-[#111827] overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(37,99,235,.12),transparent_30%),radial-gradient(circle_at_top_right,rgba(16,185,129,.10),transparent_26%)]" />

      <nav className="relative z-10 mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-full bg-[#111827] text-white font-black">
            U
          </div>

          <div>
            <p className="font-black tracking-[-0.04em] text-xl">UNIC.ai</p>
            <p className="text-xs text-slate-500">
              AI company operating system
            </p>
          </div>
        </Link>

        <div className="hidden md:flex items-center gap-8 rounded-full border border-slate-200 bg-white px-6 py-3 shadow-sm text-sm text-slate-600">
          <Link href="/agents">Agents</Link>
          <Link href="/workflow-studio">Workflows</Link>
          <Link href="/connection-layer">Connectors</Link>
          <Link href="/marketplace-explore">Marketplace</Link>
          <Link href="/pricing">Pricing</Link>
        </div>

        <div className="flex items-center gap-3">
          <Link
            href="/login"
            className="rounded-full border border-slate-200 bg-white px-5 py-3 text-sm font-bold text-slate-700 shadow-sm"
          >
            Login
          </Link>

          <Link
            href="/signup"
            className="rounded-full bg-[#111827] px-5 py-3 text-sm font-bold text-white"
          >
            Get Started
          </Link>
        </div>
      </nav>

      <section className="relative z-10 mx-auto grid max-w-7xl grid-cols-1 gap-12 px-6 pb-24 pt-16 lg:grid-cols-[1.05fr_.95fr] lg:pt-24">
        <div>
          <div className="mb-8 flex flex-wrap gap-3">
            <span className="rounded-full border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-600 shadow-sm">
              Trusted AI Infrastructure
            </span>

            <span className="rounded-full border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-600 shadow-sm">
              Human Approvals
            </span>

            <span className="rounded-full border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-600 shadow-sm">
              Connected Workflows
            </span>
          </div>

          <h1 className="max-w-4xl text-[clamp(52px,8vw,110px)] font-black leading-[0.9] tracking-[-0.08em]">
            Build your
            <br />
            AI company
          </h1>

          <p className="mt-8 max-w-2xl text-lg leading-8 text-slate-500">
            UNIC.ai helps teams create AI agents, workflows, memory systems,
            approvals and connected operations from one unified workspace.
          </p>

          <div className="mt-10 flex flex-wrap gap-4">
            <Link
              href="/signup"
              className="rounded-full bg-[#111827] px-7 py-4 text-sm font-bold text-white"
            >
              Start Building
            </Link>

            <Link
              href="/dashboard"
              className="rounded-full border border-slate-200 bg-white px-7 py-4 text-sm font-bold text-slate-700 shadow-sm"
            >
              View Dashboard
            </Link>
          </div>

          <div className="mt-16 grid grid-cols-3 gap-6 max-w-2xl">
            <div>
              <p className="text-4xl font-black tracking-[-0.06em]">Agents</p>
              <p className="mt-2 text-sm text-slate-500">
                Specialized AI workers
              </p>
            </div>

            <div>
              <p className="text-4xl font-black tracking-[-0.06em]">
                Memory
              </p>
              <p className="mt-2 text-sm text-slate-500">
                Connected business context
              </p>
            </div>

            <div>
              <p className="text-4xl font-black tracking-[-0.06em]">
                Control
              </p>
              <p className="mt-2 text-sm text-slate-500">
                Approvals and monitoring
              </p>
            </div>
          </div>
        </div>

        <div className="relative">
          <div className="rounded-[36px] border border-slate-200 bg-white/90 p-7 shadow-[0_40px_120px_rgba(15,23,42,.10)] backdrop-blur-xl">
            <div className="rounded-[28px] border border-slate-100 bg-gradient-to-br from-[#ffffff] to-[#eef4ff] p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-bold uppercase tracking-[0.18em] text-blue-600">
                    Workspace
                  </p>

                  <h2 className="mt-2 text-4xl font-black tracking-[-0.05em]">
                    Command Center
                  </h2>
                </div>

                <div className="h-14 w-14 rounded-2xl bg-[#111827]" />
              </div>

              <div className="mt-8 space-y-4">
                {[
                  "Create AI agents",
                  "Connect business tools",
                  "Build workflows",
                  "Review approvals",
                  "Monitor execution"
                ].map((item) => (
                  <div
                    key={item}
                    className="flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm"
                  >
                    <div className="h-3 w-3 rounded-full bg-blue-600" />

                    <p className="font-semibold text-slate-700">{item}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="relative z-10 mx-auto max-w-7xl px-6 pb-28">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
          {cards.map((card) => (
            <div
              key={card.title}
              className="rounded-[30px] border border-slate-200 bg-white p-8 shadow-[0_20px_80px_rgba(15,23,42,.06)]"
            >
              <div className="mb-8 h-32 rounded-[28px] bg-gradient-to-br from-[#eef4ff] via-[#ffffff] to-[#ecfeff]" />

              <h2 className="text-3xl font-black tracking-[-0.05em]">
                {card.title}
              </h2>

              <p className="mt-5 leading-8 text-slate-500">
                {card.text}
              </p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
