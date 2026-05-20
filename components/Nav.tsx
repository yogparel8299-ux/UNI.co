"use client";

import Link from "next/link";
import { useState } from "react";

const groups = [
  {
    title: "Command",
    items: [
      ["Dashboard", "/dashboard"],
      ["Command Center", "/command"],
      ["Realtime Dashboard", "/realtime-dashboard"],
      ["Notifications", "/notifications-center"]
    ]
  },
  {
    title: "Agents",
    items: [
      ["All Agents", "/agents"],
      ["Skills", "/skills"],
      ["Swarms", "/swarms"],
      ["Agent Reviews", "/seller-dashboard"],
      ["Worker Health", "/worker-health"]
    ]
  },
  {
    title: "Company",
    items: [
      ["Companies", "/companies"],
      ["AI Boardroom", "/ai-boardroom"],
      ["Departments", "/departments"],
      ["Business Generator", "/business-generator"],
      ["Company Brain", "/brain"]
    ]
  },
  {
    title: "Automation",
    items: [
      ["Workflow Studio", "/workflow-studio"],
      ["Builder", "/builder"],
      ["Rollback Center", "/rollback-center"],
      ["Approval Inbox", "/approval-inbox"],
      ["Autopilot", "/company-autopilot"]
    ]
  },
  {
    title: "Data & Tools",
    items: [
      ["Datasets", "/datasets"],
      ["Dataset Lab", "/dataset-lab"],
      ["RAG Search", "/rag"],
      ["Connectors", "/connection-layer"],
      ["MCP Gateway", "/mcp-gateway"]
    ]
  },
  {
    title: "Business",
    items: [
      ["Marketplace", "/marketplace-explore"],
      ["Billing", "/billing-center"],
      ["Usage", "/usage-dashboard"],
      ["Pricing", "/pricing"],
      ["Settings", "/settings"]
    ]
  }
];

export default function Nav() {
  const [open, setOpen] = useState<Record<string, boolean>>({
    Command: true,
    Agents: true
  });

  return (
    <aside className="sidebar fixed left-0 top-0 z-40 hidden h-screen w-[280px] overflow-y-auto p-5 lg:block">
      <Link href="/" className="mb-8 flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-full bg-white text-black font-black">U</div>
        <div>
          <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
          <p className="text-xs text-white/40">AI company OS</p>
        </div>
      </Link>

      <div className="space-y-3">
        {groups.map((group) => (
          <div key={group.title}>
            <button
              onClick={() => setOpen({ ...open, [group.title]: !open[group.title] })}
              className="nav-item w-full"
            >
              <span>{group.title}</span>
              <span>{open[group.title] ? "−" : "+"}</span>
            </button>

            {open[group.title] && (
              <div className="mt-1 space-y-1">
                {group.items.map(([label, href]) => (
                  <Link key={href} href={href} className="nav-child">
                    {label}
                  </Link>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
    </aside>
  );
}
