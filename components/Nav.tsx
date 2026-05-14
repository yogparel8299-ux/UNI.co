import Link from "next/link";

const links = [
  ["Dashboard", "/dashboard"],
  ["Command", "/command"],
  ["Companies", "/companies"],
  ["Agents", "/agents"],
  ["Swarms", "/swarms"],
  ["Tasks", "/tasks"],
  ["Builder", "/builder"],
  ["Datasets", "/datasets"],
  ["Marketplace", "/marketplace"],
  ["Approvals", "/approvals"],
  ["Usage", "/usage"],
  ["Activity", "/activity"],
  ["Billing", "/billing"],
  ["Schedules", "/schedules"],
  ["Integrations", "/integrations"],
  ["Models", "/models"],
  ["Packs", "/packs"],
  ["Ownership", "/ownership"],
  ["Auth", "/auth"],
  ["Onboarding", "/onboarding"],
  ["Vault", "/vault"],
  ["Router", "/router"],
  ["Connectors", "/connectors"],
  ["Brain", "/brain"],
  ["Triggers", "/triggers"],
  ["Realtime", "/realtime"],
  ["RAG", "/rag"],
  ["Security", "/admin/security"],
  ["Connection Layer", "/connection-layer"],
  ["MCP Gateway", "/mcp-gateway"],
  ["Dataset Lab", "/dataset-lab"],
  ["Marketplace Seller", "/marketplace-seller"],
  ["Notifications", "/notifications"],
  ["Usage Dashboard", "/usage-dashboard"],
  ["Worker Health", "/worker-health"],
  ["Secret Manager", "/secret-manager"],
  ["Realtime Stream", "/realtime-stream"],
  ["Settings", "/settings"]
];

export default function Nav() {
  return (
    <aside className="sidebar">
      <Link href="/" className="text-4xl font-black tracking-[-0.055em]">
        UNIC<span className="text-green-500">.ai</span>
      </Link>

      <p className="text-gray-500 mt-2 mb-10">
        AI Operating System
      </p>

      <div>
        {links.map(([label, href]) => (
          <Link key={href} href={href} className="sidebar-link">
            {label}
          </Link>
        ))}
      </div>

      <div className="glass-card p-5 mt-10">
        <div className="status-pill">
          Runtime Active
        </div>
        <p className="text-gray-500 text-sm mt-4 leading-7">
          Workers, queues, usage, agent runs and AI command execution are ready.
        </p>
      </div>
    </aside>
  );
}
