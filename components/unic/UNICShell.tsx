"use client";

import Link from "next/link";
import { ReactNode, useState } from "react";

const nav = [
  ["Dashboard", "/dashboard", "grid_view"],
  ["Workflow Studio", "/workflow-studio", "hub"],
  ["Agents", "/agents", "smart_toy"],
  ["Swarms", "/swarms", "group_work"],
  ["Tasks", "/tasks", "view_kanban"],
  ["Datasets", "/datasets", "database"],
  ["Company Brain", "/brain", "memory"],
  ["Connection Layer", "/connection-layer", "lan"],
  ["Marketplace", "/marketplace", "storefront"],
  ["Billing", "/billing", "account_balance_wallet"],
  ["Approvals", "/approvals", "verified_user"],
  ["Activity", "/activity", "monitoring"],
  ["Settings", "/settings", "settings"]
];

export function Icon({ name }: { name: string }) {
  return <span className="material-symbols-outlined text-[20px]">{name}</span>;
}

export function AppShell({
  title,
  eyebrow,
  children,
  right
}: {
  title: string;
  eyebrow?: string;
  children: ReactNode;
  right?: ReactNode;
}) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <main className="min-h-screen bg-[#031427] text-[#d3e4fe] selection:bg-[#2fd9f4]/30">
      <aside className={`${collapsed ? "w-[82px]" : "w-64"} fixed left-0 top-0 z-40 hidden h-screen border-r border-[#45474b]/40 bg-[#000f21] transition-all lg:flex lg:flex-col`}>
        <div className="flex h-16 items-center gap-3 border-b border-[#45474b]/30 px-5">
          <div className="grid h-8 w-8 place-items-center rounded bg-[#2fd9f4] text-sm font-black text-[#00363e]">U</div>
          {!collapsed && (
            <div>
              <p className="text-lg font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-[#c6c6cb]/60">Enterprise OS</p>
            </div>
          )}
        </div>

        <nav className="flex-1 space-y-1 overflow-y-auto p-3">
          {nav.map(([label, href, icon]) => (
            <Link key={href} href={href} className="flex items-center gap-3 rounded px-3 py-2.5 font-mono text-xs uppercase tracking-[0.08em] text-[#c6c6cb] transition hover:bg-[#26364a]/50 hover:text-[#2fd9f4]">
              <Icon name={icon} />
              {!collapsed && <span>{label}</span>}
            </Link>
          ))}
        </nav>

        <div className="border-t border-[#45474b]/30 p-3">
          <button onClick={() => setCollapsed(!collapsed)} className="flex w-full items-center justify-center gap-2 rounded border border-[#45474b]/40 px-3 py-2 font-mono text-xs text-[#c6c6cb] hover:text-[#2fd9f4]">
            <Icon name="dock_to_right" />
            {!collapsed && "Collapse"}
          </button>
        </div>
      </aside>

      <section className={`${collapsed ? "lg:ml-[82px]" : "lg:ml-64"} transition-all`}>
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[#45474b]/30 bg-[#031427]/85 px-6 backdrop-blur-xl">
          <div>
            {eyebrow && <p className="font-mono text-[10px] uppercase tracking-[0.22em] text-[#2fd9f4]">{eyebrow}</p>}
            <h1 className="text-xl font-black tracking-[-0.04em]">{title}</h1>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden items-center gap-2 rounded border border-[#45474b]/40 bg-[#0b1c30] px-3 py-2 md:flex">
              <Icon name="search" />
              <span className="font-mono text-xs text-[#c6c6cb]/70">Command / Search</span>
            </div>
            <Link href="/billing" className="rounded border border-[#2fd9f4]/30 bg-[#000e12] px-3 py-2 font-mono text-xs font-bold text-[#2fd9f4]">14.2k credits</Link>
            <Link href="/settings" className="rounded border border-[#45474b]/40 p-2 text-[#c6c6cb] hover:text-[#2fd9f4]"><Icon name="settings" /></Link>
          </div>
        </header>

        <div className={right ? "grid gap-0 xl:grid-cols-[1fr_340px]" : ""}>
          <div className="p-6">{children}</div>
          {right && <aside className="hidden min-h-[calc(100vh-64px)] border-l border-[#45474b]/30 bg-[#000f21] p-5 xl:block">{right}</aside>}
        </div>
      </section>
    </main>
  );
}

export function Panel({ children, className = "" }: { children: ReactNode; className?: string }) {
  return <div className={`rounded border border-[#45474b]/40 bg-[#0b1c30]/80 p-5 backdrop-blur-xl ${className}`}>{children}</div>;
}

export function Stat({ label, value, tone = "cyan" }: { label: string; value: string; tone?: "cyan" | "violet" | "emerald" }) {
  const color = tone === "violet" ? "text-[#c0c1ff]" : tone === "emerald" ? "text-emerald-400" : "text-[#2fd9f4]";
  return (
    <Panel>
      <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-[#c6c6cb]/60">{label}</p>
      <p className={`mt-3 text-4xl font-black tracking-[-0.06em] ${color}`}>{value}</p>
    </Panel>
  );
}
