import Link from "next/link";

export default function HomePage() {
  return (
    <main className="min-h-screen overflow-hidden bg-[#031427] text-[#d3e4fe]">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-6">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-10 w-10 place-items-center rounded bg-[#2fd9f4] font-black text-[#00363e]">U</div>
          <div>
            <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[#c6c6cb]/60">Enterprise OS</p>
          </div>
        </Link>
        <div className="flex items-center gap-3">
          <Link href="/pricing" className="hidden font-mono text-xs uppercase tracking-[0.12em] text-[#c6c6cb] md:block">Pricing</Link>
          <Link href="/login" className="rounded border border-[#2fd9f4]/50 px-5 py-2.5 font-mono text-xs font-bold uppercase tracking-[0.12em] text-[#2fd9f4]">Login</Link>
          <Link href="/signup" className="rounded bg-[#2fd9f4] px-5 py-2.5 font-mono text-xs font-black uppercase tracking-[0.12em] text-[#00363e]">Get Started</Link>
        </div>
      </nav>

      <section className="relative mx-auto grid min-h-[calc(100vh-88px)] max-w-7xl items-center gap-12 px-6 py-16 lg:grid-cols-[1fr_0.95fr]">
        <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_75%_45%,rgba(47,217,244,.24),transparent_34%),radial-gradient(circle_at_50%_80%,rgba(192,193,255,.18),transparent_30%)]" />
        <div>
          <p className="font-mono text-xs font-bold uppercase tracking-[0.24em] text-[#2fd9f4]">Operating System for AI Companies</p>
          <h1 className="mt-6 max-w-5xl text-[clamp(56px,9vw,118px)] font-black leading-[0.88] tracking-[-0.08em]">
            Automate your company with AI runtime.
          </h1>
          <p className="mt-8 max-w-2xl text-lg leading-8 text-[#c6c6cb]">
            Build agents, swarms, workflows, memory, approvals, connected tools, billing and live execution from one enterprise AI operating system.
          </p>
          <div className="mt-10 flex flex-wrap gap-4">
            <Link href="/signup" className="rounded bg-[#2fd9f4] px-7 py-4 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#00363e]">Start Building</Link>
            <Link href="/login" className="rounded border border-[#2fd9f4]/40 px-7 py-4 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#2fd9f4]">Login</Link>
            <Link href="/dashboard" className="rounded border border-[#45474b]/50 px-7 py-4 font-mono text-xs font-black uppercase tracking-[0.14em] text-[#d3e4fe]">View Demo</Link>
          </div>
        </div>

        <div className="rounded border border-[#45474b]/50 bg-[#0b1c30]/70 p-5 shadow-2xl shadow-black/40 backdrop-blur-xl">
          <div className="flex items-center justify-between border-b border-[#45474b]/40 pb-4">
            <div>
              <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[#2fd9f4]">Runtime Graph</p>
              <h2 className="mt-1 text-2xl font-black tracking-[-0.04em]">Workflow Kernel</h2>
            </div>
            <div className="rounded bg-emerald-400/10 px-3 py-1 font-mono text-[10px] font-bold text-emerald-400">LIVE</div>
          </div>
          <div className="relative mt-5 h-[460px] overflow-hidden rounded bg-[#000f21]">
            <div className="absolute inset-0 bg-[radial-gradient(rgba(144,144,149,.16)_1px,transparent_1px)] bg-[size:24px_24px]" />
            {[
              ["Webhook", "left-8 top-10", "webhook"],
              ["AI Agent", "left-[220px] top-[190px]", "psychology"],
              ["Company Brain", "right-8 top-16", "memory"],
              ["Human Approval", "right-8 bottom-12", "verified_user"]
            ].map(([label, pos, icon]) => (
              <div key={label} className={`absolute ${pos} w-48 rounded border border-[#45474b]/50 bg-[#102034]/90 p-4 shadow-xl`}>
                <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-[#2fd9f4]">{icon}</p>
                <p className="mt-2 font-black">{label}</p>
                <p className="mt-1 font-mono text-[10px] text-[#c6c6cb]/60">status: active</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
