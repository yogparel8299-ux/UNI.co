import Link from "next/link";

const bots = [
  ["Agent Builder", "Create AI workers for sales, support, research and operations."],
  ["Workflow Studio", "Drag, connect and run AI workflows with approvals."],
  ["Company Brain", "Give agents memory from datasets, files and connected apps."],
  ["Tool Layer", "Connect Gmail, Slack, Notion, GitHub and more."]
];

const faqs = [
  ["Can visitors use the app?", "Visitors can only view the landing page and demo dashboard. Workspace tools require login."],
  ["Can I use my own model keys?", "Yes. UNIC.ai supports BYOK and platform-provided credits when configured."],
  ["Does it connect to business apps?", "Yes. Apps connect through the connector layer and can become agent tools."],
  ["Is payment active now?", "Payments stay disabled until Stripe or Razorpay keys are configured."]
];

export default function HomePage() {
  return (
    <main className="min-h-screen bg-white text-black">
      <section className="mx-auto max-w-[1440px] px-4 py-4">
        <div className="overflow-hidden rounded-[34px] bg-black text-white">
          <nav className="flex items-center justify-between px-7 py-6">
            <Link href="/" className="flex items-center gap-3">
              <div className="grid h-10 w-10 place-items-center rounded-xl bg-white text-black font-black">
                U
              </div>
              <div>
                <p className="text-lg font-black tracking-[-0.04em]">UNIC.ai</p>
                <p className="text-xs text-white/50">AI company OS</p>
              </div>
            </Link>

            <div className="hidden items-center gap-8 text-sm font-bold text-white/70 md:flex">
              <Link href="/dashboard">Demo</Link>
              <Link href="/pricing">Pricing</Link>
              <Link href="/legal/privacy">Privacy</Link>
              <Link href="/login" className="text-white underline underline-offset-4">
                Login
              </Link>
            </div>

            <Link
              href="/signup"
              className="rounded-full bg-white px-6 py-3 text-sm font-black text-black shadow-lg"
            >
              Get started
            </Link>
          </nav>

          <div className="relative px-7 pb-20 pt-20 md:px-12 md:pb-28">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_55%_55%,rgba(52,211,153,.95),transparent_23%),radial-gradient(circle_at_65%_40%,rgba(59,130,246,.95),transparent_28%),radial-gradient(circle_at_45%_70%,rgba(240,253,244,.75),transparent_24%)] opacity-90" />
            <div className="absolute inset-0 bg-gradient-to-b from-black via-black/60 to-transparent" />

            <div className="relative z-10 grid gap-12 lg:grid-cols-[1.05fr_.95fr]">
              <div>
                <div className="mb-7 inline-flex rounded-full border border-white/15 bg-white/10 px-4 py-2 text-xs font-black text-white/80">
                  AI operations for modern companies
                </div>

                <h1 className="max-w-4xl text-[clamp(54px,8vw,118px)] font-black leading-[0.86] tracking-[-0.085em]">
                  Automate & manage your business with AI.
                </h1>
              </div>

              <div className="flex flex-col justify-center lg:pt-24">
                <p className="max-w-md text-base leading-8 text-white/72">
                  Build agents, workflows, datasets, approvals and connected operations from one clean workspace.
                </p>

                <div className="mt-7 flex flex-wrap items-center gap-4">
                  <Link
                    href="/signup"
                    className="rounded-full bg-white px-6 py-3 text-sm font-black text-black"
                  >
                    Start building
                  </Link>
                  <Link
                    href="/dashboard"
                    className="rounded-full border border-white/25 px-6 py-3 text-sm font-black text-white"
                  >
                    View demo
                  </Link>
                  <Link
                    href="/login"
                    className="rounded-full bg-black/40 px-6 py-3 text-sm font-black text-white ring-1 ring-white/25"
                  >
                    Login
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto grid max-w-7xl gap-10 px-6 py-20 lg:grid-cols-[.8fr_1.2fr]">
        <h2 className="text-5xl font-black leading-[0.95] tracking-[-0.06em]">
          How can UNIC.ai help your business?
        </h2>

        <div>
          <p className="text-lg leading-8 text-neutral-600">
            UNIC.ai turns your company into an AI-operated workspace where agents handle tasks, workflows connect tools, and humans approve important actions.
          </p>

          <div className="mt-10 grid gap-8 md:grid-cols-3">
            {[
              ["100%", "Human approval control"],
              ["90%", "Less manual operations"],
              ["10k+", "Automations possible"]
            ].map(([a, b]) => (
              <div key={a} className="border-l border-neutral-200 pl-6">
                <p className="text-5xl font-black tracking-[-0.06em]">{a}</p>
                <p className="mt-2 text-sm text-neutral-500">{b}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-7xl px-6 pb-20">
        <div className="text-center">
          <h2 className="text-5xl font-black tracking-[-0.06em]">
            AI-powered growth bots
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-neutral-500">
            Each system is designed to work inside your company workspace.
          </p>
        </div>

        <div className="mt-12 grid gap-5 md:grid-cols-4">
          {bots.map(([title, text]) => (
            <div
              key={title}
              className="rounded-[26px] border border-neutral-200 bg-[#f7f7f8] p-7"
            >
              <div className="mb-8 grid h-11 w-11 place-items-center rounded-full bg-white shadow-sm">
                ✦
              </div>
              <h3 className="text-xl font-black tracking-[-0.03em]">{title}</h3>
              <p className="mt-4 text-sm leading-7 text-neutral-500">{text}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="bg-black py-20 text-white">
        <div className="mx-auto max-w-7xl px-6 text-center">
          <p className="text-sm font-black uppercase tracking-[0.18em] text-white/50">
            Industries
          </p>
          <h2 className="mx-auto mt-5 max-w-3xl text-5xl font-black tracking-[-0.06em]">
            Built for teams that want AI to operate real work.
          </h2>

          <div className="mt-12 flex flex-wrap justify-center gap-4 text-2xl font-black text-white/75">
            {["SaaS", "Agencies", "E-commerce", "Finance", "Support", "Operations"].map((x) => (
              <span key={x} className="rounded-full border border-white/10 px-6 py-3">
                {x}
              </span>
            ))}
          </div>
        </div>
      </section>

      <section className="mx-auto grid max-w-7xl gap-10 px-6 py-20 lg:grid-cols-[.75fr_1.25fr]">
        <div>
          <h2 className="text-5xl font-black tracking-[-0.06em]">
            Frequently asked questions
          </h2>
          <p className="mt-5 text-neutral-500">
            Clear answers before users create a workspace.
          </p>
        </div>

        <div className="space-y-3">
          {faqs.map(([q, a]) => (
            <details key={q} className="rounded-2xl border border-neutral-200 bg-white p-5">
              <summary className="cursor-pointer text-lg font-black">{q}</summary>
              <p className="mt-4 leading-7 text-neutral-500">{a}</p>
            </details>
          ))}
        </div>
      </section>

      <footer className="mx-auto max-w-[1440px] px-4 pb-4">
        <div className="overflow-hidden rounded-[34px] bg-black px-8 py-14 text-white">
          <div className="grid gap-10 md:grid-cols-[1fr_.7fr]">
            <div>
              <h2 className="text-5xl font-black tracking-[-0.06em]">
                Let’s build the future together.
              </h2>
              <Link
                href="/signup"
                className="mt-8 inline-flex rounded-full bg-white px-6 py-3 text-sm font-black text-black"
              >
                Get started
              </Link>
            </div>

            <div className="grid grid-cols-2 gap-6 text-sm text-white/60">
              <div className="space-y-3">
                <p className="font-black text-white">Product</p>
                <Link href="/dashboard" className="block">Demo</Link>
                <Link href="/pricing" className="block">Pricing</Link>
                <Link href="/login" className="block">Login</Link>
              </div>
              <div className="space-y-3">
                <p className="font-black text-white">Legal</p>
                <Link href="/legal/privacy" className="block">Privacy</Link>
                <Link href="/legal/refund" className="block">Refund</Link>
                <Link href="/legal/ai-policy" className="block">AI Policy</Link>
              </div>
            </div>
          </div>

          <p className="mt-16 text-[clamp(62px,12vw,180px)] font-black leading-none tracking-[-0.09em]">
            UNIC.ai
          </p>
        </div>
      </footer>
    </main>
  );
}
