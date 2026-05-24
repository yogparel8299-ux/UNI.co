"use client";

import Link from "next/link";
import Logo from "./Logo";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Swarms", "/swarms"],
  ["Tasks", "/tasks"],
  ["Datasets", "/datasets"],
  ["Brain", "/brain"],
  ["Connect", "/connection-layer"],
  ["Market", "/marketplace"],
  ["Billing", "/billing"],
  ["Approvals", "/approvals"],
  ["Activity", "/activity"],
  ["Settings", "/settings"]
];

export default function AppShell({
  title,
  eyebrow,
  children
}: {
  title: string;
  eyebrow: string;
  children: React.ReactNode;
}) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-[#f0f0ee] text-gray-900">
      <video
        className="video-soft fixed inset-0 h-full w-full object-cover opacity-70"
        src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4"
        autoPlay
        muted
        loop
        playsInline
      />
      <div className="fixed inset-0 bg-[#f0f0ee]/40" />

      <div className="relative z-10 flex min-h-screen">
        <aside className="hidden w-[260px] shrink-0 border-r border-white/40 bg-[#ededed]/70 p-4 backdrop-blur-2xl lg:block">
          <Link href="/" className="mb-8 flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[#EDEDED]">
              <Logo />
            </div>
            <div>
              <p className="text-lg font-semibold tracking-tight">UNIC.ai</p>
              <p className="text-[11px] text-gray-500">Operating system</p>
            </div>
          </Link>

          <nav className="space-y-1">
            {nav.map(([label, href]) => (
              <Link
                key={href}
                href={href}
                className="block rounded-xl px-4 py-3 text-[13px] font-medium text-gray-600 transition hover:bg-white/60 hover:text-gray-950"
              >
                {label}
              </Link>
            ))}
          </nav>
        </aside>

        <section className="flex-1">
          <header className="flex items-center justify-between px-5 py-4 sm:px-8">
            <div className="rounded-xl bg-[#EDEDED]/80 px-5 py-3 backdrop-blur-xl">
              <p className="text-[11px] font-medium text-blue-500">{eyebrow}</p>
              <h1 className="text-[1.55rem] font-medium leading-[1.1] tracking-tight text-gray-900">
                {title}
              </h1>
            </div>

            <div className="flex items-center gap-2">
              <Link
                href="/billing"
                className="rounded-xl bg-[#EDEDED]/80 px-4 py-3 text-[13px] font-medium text-gray-700 backdrop-blur-xl"
              >
                Credits
              </Link>
              <Link
                href="/settings"
                className="rounded-xl bg-[#EDEDED]/80 px-4 py-3 text-[13px] font-medium text-gray-700 backdrop-blur-xl"
              >
                Settings
              </Link>
            </div>
          </header>

          <div className="px-5 pb-10 sm:px-8">{children}</div>
        </section>
      </div>
    </main>
  );
}

export function Card({
  children,
  className = ""
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={`os-panel rounded-2xl p-5 ${className}`}>{children}</div>;
}

export function Metric({ label, value }: { label: string; value: string }) {
  return (
    <Card>
      <p className="text-[11.5px] font-medium text-gray-400">{label}</p>
      <p className="mt-2 text-[1.75rem] font-medium leading-none tracking-tight text-gray-900">{value}</p>
    </Card>
  );
}
