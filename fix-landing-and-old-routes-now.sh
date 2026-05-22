#!/bin/bash
set -e

echo "Fixing landing page and redirecting old unused routes..."

cat > app/page.tsx <<'TSX'
import Link from "next/link";

const features = [
  ["Agents", "Create AI workers with skills, memory, tools and approvals."],
  ["Workflow Studio", "Build automation visually with an n8n-style AI operations canvas."],
  ["Company Brain", "Upload files, connect tools and give agents business context."],
  ["Human Control", "Approvals, budgets, limits and realtime execution logs."]
];

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#f6f7fb] text-[#0b0b0f]">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-2xl bg-black text-white font-black">U</div>
          <div>
            <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
            <p className="text-xs text-neutral-500">AI company operating system</p>
          </div>
        </Link>

        <div className="hidden rounded-full border border-neutral-200 bg-white px-6 py-3 text-sm font-bold text-neutral-600 shadow-sm md:flex gap-8">
          <Link href="/dashboard">Demo</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/login">Login</Link>
        </div>

        <Link href="/signup" className="rounded-full bg-black px-6 py-3 text-sm font-black text-white">
          Get Started
        </Link>
      </nav>

      <section className="mx-auto max-w-7xl px-6 pb-24 pt-14">
        <div className="rounded-[44px] border border-neutral-200 bg-white p-8 shadow-[0_40px_120px_rgba(15,23,42,.08)]">
          <div className="grid gap-12 lg:grid-cols-[1fr_.95fr]">
            <div className="flex flex-col justify-center py-10 lg:py-20">
              <div className="mb-8 flex flex-wrap gap-3">
                {["AI workforce", "Workflow engine", "Connected tools"].map((x) => (
                  <span key={x} className="rounded-full border border-neutral-200 bg-[#f7f7f8] px-4 py-2 text-xs font-black text-neutral-600">
                    {x}
                  </span>
                ))}
              </div>

              <h1 className="max-w-4xl text-[clamp(54px,8vw,112px)] font-black leading-[0.88] tracking-[-0.085em]">
                Build your AI company.
              </h1>

              <p className="mt-8 max-w-2xl text-lg leading-8 text-neutral-500">
                UNIC.ai gives teams an operating system for agents, workflows, memory, approvals, tools, billing and live execution.
              </p>

              <div className="mt-10 flex flex-wrap gap-4">
                <Link href="/signup" className="rounded-full bg-black px-7 py-4 text-sm font-black text-white">
                  Start Building
                </Link>
                <Link href="/dashboard" className="rounded-full border border-neutral-200 bg-white px-7 py-4 text-sm font-black text-black shadow-sm">
                  View Demo
                </Link>
              </div>
            </div>

            <div className="rounded-[36px] border border-neutral-200 bg-[#f7f7f8] p-5">
              <div className="rounded-[30px] border border-neutral-200 bg-white p-6 shadow-sm">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs font-black uppercase tracking-[0.18em] text-blue-600">Workspace</p>
                    <h2 className="mt-2 text-4xl font-black tracking-[-0.055em]">Operations Canvas</h2>
                  </div>
                  <div className="h-14 w-14 rounded-2xl bg-black" />
                </div>

                <div className="relative mt-8 h-[460px] overflow-hidden rounded-[28px] border border-neutral-200 bg-[#fbfbfc]">
                  <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />
                  <div className="absolute left-8 top-10 rounded-2xl border border-neutral-200 bg-white p-5 shadow-lg">
                    <p className="text-xs font-black text-neutral-400">TRIGGER</p>
                    <p className="mt-2 font-black">New customer request</p>
                  </div>
                  <div className="absolute left-[250px] top-[165px] rounded-2xl border border-neutral-200 bg-white p-5 shadow-lg">
                    <p className="text-xs font-black text-neutral-400">AGENT</p>
                    <p className="mt-2 font-black">Support Operator</p>
                  </div>
                  <div className="absolute right-8 top-10 rounded-2xl border border-neutral-200 bg-white p-5 shadow-lg">
                    <p className="text-xs font-black text-neutral-400">MEMORY</p>
                    <p className="mt-2 font-black">Company Brain</p>
                  </div>
                  <div className="absolute right-8 bottom-10 rounded-2xl border border-neutral-200 bg-white p-5 shadow-lg">
                    <p className="text-xs font-black text-neutral-400">APPROVAL</p>
                    <p className="mt-2 font-black">Human Review</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-4">
          {features.map(([title, text]) => (
            <div key={title} className="rounded-[28px] border border-neutral-200 bg-white p-7 shadow-sm">
              <h2 className="text-2xl font-black tracking-[-0.04em]">{title}</h2>
              <p className="mt-4 text-sm leading-7 text-neutral-500">{text}</p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
TSX

# Redirect unused/old public routes so they do not show random old pages.
OLD_ROUTES=(
about contact security auth command connectors integrations
marketplace-explore marketplace-seller seller-dashboard
admin-analytics admin-console admin/security
brain-search dataset-lab final-onboarding mcp-gateway models
notifications notifications-center ownership packs rag realtime realtime-live realtime-stream
rollback-center router secret-manager swarm-visualizer triggers usage-dashboard vault worker-health billing-center
)

for route in "${OLD_ROUTES[@]}"; do
  mkdir -p "app/$route"
  cat > "app/$route/page.tsx" <<'TSX'
import { redirect } from "next/navigation";

export default function Page() {
  redirect("/login");
}
TSX
done

npm run build
git add .
git commit -m "Fix premium landing and redirect unused old routes" || true
git push origin main
