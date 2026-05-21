#!/bin/bash
set -e

echo "Applying full public pages + pricing polish..."

mkdir -p components/marketing
mkdir -p app/{pricing,packs,marketplace,marketplace-explore,billing,billing-center,legal/ownership,legal/privacy,legal/refund,legal/ai-policy,about,contact,security}

cat > components/marketing/PublicNav.tsx <<'TSX'
import Link from "next/link";

export default function PublicNav() {
  return (
    <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
      <Link href="/" className="flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-full bg-slate-950 text-white font-black">U</div>
        <div>
          <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
          <p className="text-xs text-slate-500">AI company OS</p>
        </div>
      </Link>

      <div className="hidden rounded-full border border-slate-200 bg-white px-6 py-3 md:flex gap-9 text-sm text-slate-600 shadow-sm">
        <Link href="/pricing">Pricing</Link>
        <Link href="/marketplace-explore">Marketplace</Link>
        <Link href="/security">Security</Link>
        <Link href="/about">Company</Link>
        <Link href="/contact">Contact</Link>
      </div>

      <Link href="/signup" className="primary-button">Get started</Link>
    </nav>
  );
}
TSX

cat > components/marketing/PublicFooter.tsx <<'TSX'
import Link from "next/link";

export default function PublicFooter() {
  return (
    <footer className="mx-auto max-w-7xl px-6 py-14">
      <div className="soft-panel grid gap-8 p-8 md:grid-cols-4">
        <div>
          <p className="text-2xl font-black tracking-[-0.04em]">UNIC.ai</p>
          <p className="mt-3 text-slate-500 leading-7">
            A trusted operating layer for AI agents, workflows and connected business systems.
          </p>
        </div>

        <div>
          <p className="font-black">Platform</p>
          <div className="mt-4 space-y-3 text-slate-500">
            <Link className="block" href="/agents">Agents</Link>
            <Link className="block" href="/workflow-studio">Workflows</Link>
            <Link className="block" href="/connection-layer">Connectors</Link>
          </div>
        </div>

        <div>
          <p className="font-black">Business</p>
          <div className="mt-4 space-y-3 text-slate-500">
            <Link className="block" href="/pricing">Pricing</Link>
            <Link className="block" href="/marketplace-explore">Marketplace</Link>
            <Link className="block" href="/security">Security</Link>
          </div>
        </div>

        <div>
          <p className="font-black">Legal</p>
          <div className="mt-4 space-y-3 text-slate-500">
            <Link className="block" href="/legal/privacy">Privacy</Link>
            <Link className="block" href="/legal/ai-policy">AI Policy</Link>
            <Link className="block" href="/legal/refund">Refund</Link>
            <Link className="block" href="/legal/ownership">Ownership</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
TSX

cat > app/pricing/page.tsx <<'TSX'
import Link from "next/link";
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

const plans = [
  {
    name: "Starter",
    price: "$19",
    credits: "100k platform credits / month",
    desc: "For founders testing AI agents and workflows.",
    highlight: false,
    features: [
      "Bring your own model keys",
      "Starter platform credits included",
      "3 agents",
      "5 workflows",
      "Basic connectors",
      "Community support"
    ]
  },
  {
    name: "Builder",
    price: "$49",
    credits: "300k platform credits / month",
    desc: "For creators, agencies and builders operating daily workflows.",
    highlight: true,
    features: [
      "Bring your own keys or use included credits",
      "15 agents",
      "Unlimited skills",
      "Workflow Studio",
      "Approval Inbox",
      "Marketplace access",
      "Priority queue"
    ]
  },
  {
    name: "Company",
    price: "$149",
    credits: "1M platform credits / month",
    desc: "For teams building an AI operating layer for real work.",
    highlight: false,
    features: [
      "Team workspace",
      "Advanced connectors",
      "Company Brain",
      "Autopilot controls",
      "Budget limits",
      "Realtime dashboards",
      "Priority support"
    ]
  },
  {
    name: "Enterprise",
    price: "Custom",
    credits: "Custom limits",
    desc: "For private deployments, compliance and dedicated infrastructure.",
    highlight: false,
    features: [
      "Private deployment",
      "Dedicated workers",
      "Custom data residency",
      "SSO and admin controls",
      "Custom ownership terms",
      "Security review",
      "Dedicated support"
    ]
  }
];

export default function PricingPage() {
  return (
    <main className="page-shell">
      <PublicNav />

      <section className="mx-auto max-w-7xl px-6 py-14">
        <div className="text-center">
          <span className="status-pill">Credit-based plans</span>
          <h1 className="page-title mx-auto mt-6 max-w-4xl">
            Pricing that scales with usage
          </h1>
          <p className="page-subtitle mx-auto mt-7">
            Start with included platform credits, then connect your own model keys for predictable control as your AI company grows.
          </p>
        </div>

        <div className="mt-14 grid grid-cols-1 gap-6 lg:grid-cols-4">
          {plans.map((plan) => (
            <div key={plan.name} className={plan.highlight ? "glass-card p-7 ring-2 ring-blue-600" : "glass-card p-7"}>
              {plan.highlight && <span className="status-pill mb-5">Most popular</span>}
              <h2 className="text-3xl font-black tracking-[-0.05em]">{plan.name}</h2>
              <p className="mt-3 text-slate-500 leading-7">{plan.desc}</p>
              <div className="mt-7">
                <span className="text-5xl font-black tracking-[-0.06em]">{plan.price}</span>
                {plan.price !== "Custom" && <span className="text-slate-500"> / month</span>}
              </div>
              <p className="mt-3 font-bold text-blue-600">{plan.credits}</p>
              <Link href="/signup" className="primary-button mt-7 w-full">Choose plan</Link>
              <div className="mt-7 space-y-3">
                {plan.features.map((f) => (
                  <div key={f} className="flex gap-3 text-sm text-slate-600">
                    <span className="text-emerald-600">✓</span>
                    <span>{f}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        <div className="soft-panel mt-12 p-8">
          <h2 className="text-3xl font-black tracking-[-0.04em]">How credits work</h2>
          <p className="mt-4 max-w-3xl text-slate-500 leading-8">
            Credits are used for platform-managed AI tasks, background execution and generation features. For high-volume usage, users can connect their own model keys while UNIC.ai continues to manage agents, memory, workflows, approvals and execution infrastructure.
          </p>
        </div>
      </section>

      <PublicFooter />
    </main>
  );
}
TSX

cat > app/packs/page.tsx <<'TSX'
import Link from "next/link";
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

const packs = [
  ["Launch Pack", "Extra credits for founders testing agents and workflows.", "$9"],
  ["Growth Pack", "More execution room for daily workflows and content systems.", "$29"],
  ["Scale Pack", "High-volume credits for business workflows and teams.", "$99"]
];

export default function PacksPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="page-title">Credit packs</h1>
        <p className="page-subtitle mt-6">Add platform credits when you need more execution capacity without changing your subscription.</p>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {packs.map(([name, desc, price]) => (
            <div className="glass-card p-8" key={name}>
              <h2 className="text-3xl font-black tracking-[-0.05em]">{name}</h2>
              <p className="mt-4 text-slate-500 leading-7">{desc}</p>
              <p className="mt-8 text-5xl font-black">{price}</p>
              <Link className="primary-button mt-7" href="/signup">Get pack</Link>
            </div>
          ))}
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

cat > app/security/page.tsx <<'TSX'
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
TSX

cat > app/about/page.tsx <<'TSX'
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
TSX

cat > app/contact/page.tsx <<'TSX'
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function ContactPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-5xl px-6 py-14">
        <h1 className="page-title">Contact</h1>
        <p className="page-subtitle mt-6">Talk to the UNIC.ai team about product access, enterprise deployments and partnerships.</p>

        <div className="glass-card mt-12 p-8">
          <input className="input-box" placeholder="Work email" />
          <input className="input-box mt-4" placeholder="Company" />
          <textarea className="input-box mt-4 min-h-[160px]" placeholder="How can we help?" />
          <button className="primary-button mt-6">Send request</button>
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

cat > app/marketplace/page.tsx <<'TSX'
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function MarketplacePage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-7xl px-6 py-14">
        <h1 className="page-title">Marketplace</h1>
        <p className="page-subtitle mt-6">Discover agent templates, skill packs, workflow systems and company operating packs.</p>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {["Agent templates", "Skill packs", "Workflow systems"].map((x) => (
            <div className="glass-card p-8" key={x}>
              <h2 className="text-3xl font-black tracking-[-0.05em]">{x}</h2>
              <p className="mt-4 text-slate-500 leading-7">Install ready-made assets into your workspace and customize them for your company.</p>
            </div>
          ))}
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

cat > app/legal/privacy/page.tsx <<'TSX'
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function PrivacyPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">Privacy Policy</h1>
        <p className="mt-6 text-slate-500 leading-8">
          UNIC.ai is designed to protect workspace data, connected account credentials and user-generated business assets. Users control which providers, tools and connectors they authorize.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

cat > app/legal/refund/page.tsx <<'TSX'
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function RefundPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">Refund Policy</h1>
        <p className="mt-6 text-slate-500 leading-8">
          Subscription and credit-pack refunds are reviewed according to usage, billing history and applicable plan terms. Enterprise agreements may include separate commercial terms.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

cat > app/legal/ai-policy/page.tsx <<'TSX'
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function AiPolicyPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">AI Use Policy</h1>
        <p className="mt-6 text-slate-500 leading-8">
          UNIC.ai is built for productive business automation. Users are responsible for configuring approvals, reviewing outputs and complying with laws and third-party platform terms.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

cat > app/legal/ownership/page.tsx <<'TSX'
import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function OwnershipPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">Ownership Terms</h1>
        <p className="mt-6 text-slate-500 leading-8">
          Workspace access, generated systems, marketplace assets, exports and transfer rights depend on the active plan and applicable agreement. Enterprise customers may negotiate custom ownership and export terms.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
TSX

git add app components
git commit -m "Polish all public pages and pricing system" || true
npm run build
git push origin main
