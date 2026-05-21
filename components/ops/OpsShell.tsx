"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const nav = [
  ["Overview", "/dashboard"],
  ["Agents", "/agents"],
  ["Skills", "/skills"],
  ["Workflows", "/workflow-studio"],
  ["Datasets", "/datasets"],
  ["Approvals", "/approval-inbox"],
  ["Realtime", "/realtime-dashboard"],
  ["Marketplace", "/marketplace-explore"],
  ["Billing", "/billing-center"],
  ["Agent Evolution", "/agent-evolution"],
  ["Settings", "/settings"]
];

export default function OpsShell({
  title,
  subtitle,
  rightPanel,
  children
}: {
  title: string;
  subtitle?: string;
  rightPanel?: React.ReactNode;
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <main className="min-h-screen bg-[#f7f7f8] text-[#111111]">
      <aside className="fixed left-0 top-0 hidden h-screen w-[260px] border-r border-neutral-200 bg-white lg:block">
        <div className="border-b border-neutral-200 p-5">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-9 w-9 place-items-center rounded-xl bg-black text-white font-black">U</div>
            <div>
              <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-neutral-500">Operations workspace</p>
            </div>
          </Link>
        </div>

        <div className="p-3">
          {nav.map(([label, href]) => {
            const active = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                className={
                  active
                    ? "mb-1 flex rounded-xl bg-black px-3 py-2.5 text-sm font-bold text-white"
                    : "mb-1 flex rounded-xl px-3 py-2.5 text-sm font-semibold text-neutral-600 hover:bg-neutral-100 hover:text-black"
                }
              >
                {label}
              </Link>
            );
          })}
        </div>
      </aside>

      <section className={rightPanel ? "lg:ml-[260px] lg:mr-[320px]" : "lg:ml-[260px]"}>
        <header className="sticky top-0 z-20 border-b border-neutral-200 bg-white/85 backdrop-blur-xl">
          <div className="flex items-center justify-between px-6 py-4">
            <div>
              <h1 className="text-2xl font-black tracking-[-0.04em]">{title}</h1>
              {subtitle && <p className="mt-1 text-sm text-neutral-500">{subtitle}</p>}
            </div>

            <div className="flex items-center gap-2">
              <Link href="/signup" className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-sm font-bold">
                Invite
              </Link>
              <Link href="/settings" className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">
                Settings
              </Link>
            </div>
          </div>
        </header>

        <div className="p-6">{children}</div>
      </section>

      {rightPanel && (
        <aside className="fixed right-0 top-0 hidden h-screen w-[320px] border-l border-neutral-200 bg-white lg:block">
          {rightPanel}
        </aside>
      )}
    </main>
  );
}
