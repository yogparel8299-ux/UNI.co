"use client";

import Link from "next/link";
import { useState } from "react";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Agents", "/agents"],
  ["Skills", "/skills"],
  ["Workflow Studio", "/workflow-studio"],
  ["Datasets", "/datasets"],
  ["Marketplace", "/marketplace-explore"],
  ["Approvals", "/approval-inbox"],
  ["Realtime", "/realtime-dashboard"],
  ["Billing", "/billing-center"],
  ["Settings", "/settings"]
];

export default function AppShell({
  children
}: {
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);

  return (
    <main className="min-h-screen bg-[#f6f8fb] text-slate-950">
      <aside className="fixed left-0 top-0 z-40 hidden h-screen w-[280px] border-r border-slate-200 bg-white lg:block">
        <div className="p-6">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-full bg-slate-950 text-white font-black">U</div>
            <div>
              <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
              <p className="text-xs text-slate-500">AI company OS</p>
            </div>
          </Link>
        </div>

        <div className="px-4">
          {nav.map(([label, href]) => (
            <Link
              key={href}
              href={href}
              className="mb-1 block rounded-2xl px-4 py-3 text-sm font-bold text-slate-600 hover:bg-slate-100 hover:text-slate-950"
            >
              {label}
            </Link>
          ))}
        </div>
      </aside>

      <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/80 backdrop-blur-xl lg:hidden">
        <div className="flex items-center justify-between p-5">
          <Link href="/" className="font-black">UNIC.ai</Link>
          <button onClick={() => setOpen(!open)} className="rounded-xl border px-4 py-2 font-bold">Menu</button>
        </div>
        {open && (
          <div className="border-t bg-white p-4">
            {nav.map(([label, href]) => (
              <Link key={href} href={href} className="block rounded-xl px-4 py-3 font-bold text-slate-600">
                {label}
              </Link>
            ))}
          </div>
        )}
      </header>

      <section className="lg:ml-[280px]">
        {children}
      </section>
    </main>
  );
}
