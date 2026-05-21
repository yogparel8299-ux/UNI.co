"use client";

import Link from "next/link";
import { useState } from "react";

const groups = [
  {
    title: "Workspace",
    items: [
      ["Dashboard", "/dashboard"],
      ["Agents", "/agents"],
      ["Skills", "/skills"],
      ["Swarms", "/swarms"],
      ["Tasks", "/tasks"]
    ]
  },
  {
    title: "Automation",
    items: [
      ["Workflow Studio", "/workflow-studio"],
      ["Approvals", "/approval-inbox"],
      ["Schedules", "/schedules"],
      ["Realtime", "/realtime-dashboard"]
    ]
  },
  {
    title: "Data",
    items: [
      ["Datasets", "/datasets"],
      ["Company Brain", "/brain"],
      ["RAG Search", "/rag"],
      ["Vault", "/vault"]
    ]
  },
  {
    title: "Business",
    items: [
      ["Marketplace", "/marketplace-explore"],
      ["Billing", "/billing-center"],
      ["Usage", "/usage-dashboard"],
      ["Settings", "/settings"]
    ]
  }
];

export default function AppShell({
  title,
  subtitle,
  children
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState<Record<string, boolean>>({
    Workspace: true,
    Automation: true
  });

  return (
    <main className="min-h-screen bg-[#f6f8fb] text-[#111827]">
      <aside className="fixed left-0 top-0 z-40 hidden h-screen w-[290px] overflow-y-auto border-r border-slate-200 bg-white lg:block">
        <div className="p-6">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-full bg-[#111827] text-white font-black">
              U
            </div>

            <div>
              <p className="font-black tracking-[-0.04em] text-xl">
                UNIC.ai
              </p>

              <p className="text-xs text-slate-500">
                AI company operating system
              </p>
            </div>
          </Link>
        </div>

        <div className="px-4 pb-10">
          {groups.map((group) => (
            <div key={group.title} className="mb-5">
              <button
                onClick={() =>
                  setOpen({
                    ...open,
                    [group.title]: !open[group.title]
                  })
                }
                className="flex w-full items-center justify-between rounded-2xl px-4 py-3 text-left text-sm font-black text-slate-700 hover:bg-slate-100"
              >
                <span>{group.title}</span>
                <span>{open[group.title] ? "−" : "+"}</span>
              </button>

              {open[group.title] && (
                <div className="mt-2 space-y-1">
                  {group.items.map(([label, href]) => (
                    <Link
                      key={href}
                      href={href}
                      className="block rounded-2xl px-4 py-3 text-sm font-semibold text-slate-500 hover:bg-slate-100 hover:text-slate-900"
                    >
                      {label}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      </aside>

      <section className="lg:ml-[290px]">
        <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/80 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-5">
            <div>
              <h1 className="text-4xl font-black tracking-[-0.06em]">
                {title}
              </h1>

              {subtitle && (
                <p className="mt-2 text-sm text-slate-500">
                  {subtitle}
                </p>
              )}
            </div>

            <div className="flex items-center gap-3">
              <Link
                href="/notifications-center"
                className="rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700"
              >
                Notifications
              </Link>

              <Link
                href="/settings"
                className="rounded-2xl bg-[#111827] px-5 py-3 text-sm font-bold text-white"
              >
                Settings
              </Link>
            </div>
          </div>
        </header>

        <div className="p-6">
          {children}
        </div>
      </section>
    </main>
  );
}
