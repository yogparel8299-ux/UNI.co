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
