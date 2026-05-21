import AppShell from "@/components/layout/AppShell";

const items = [
  "Customer Support Agent",
  "Research Workflow",
  "Sales Qualification System",
  "Operations Copilot",
  "Marketing Automation Stack",
  "Finance Review Pipeline"
];

export default function MarketplaceExplorePage() {
  return (
    <AppShell
      title="Marketplace"
      subtitle="Discover reusable agents, workflows and company systems."
    >
      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        {items.map((item) => (
          <div
            key={item}
            className="rounded-[30px] border border-slate-200 bg-white p-7 shadow-[0_20px_80px_rgba(15,23,42,.05)]"
          >
            <div className="mb-7 h-36 rounded-[24px] bg-gradient-to-br from-[#eef4ff] via-white to-[#f5f3ff]" />

            <h2 className="text-3xl font-black tracking-[-0.05em]">
              {item}
            </h2>

            <p className="mt-4 text-sm leading-7 text-slate-500">
              Ready-to-install automation system with configurable workflows and integrations.
            </p>

            <button className="mt-7 rounded-full bg-[#111827] px-5 py-3 text-sm font-bold text-white">
              View Asset
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
