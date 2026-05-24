"use client";

import Link from "next/link";
import { Menu, X } from "lucide-react";
import { useState } from "react";

export default function LandingPage() {
  const [open, setOpen] = useState(false);

  return (
    <main className="relative min-h-screen overflow-hidden bg-black text-white">
      <img
        src="/ai-hero.png"
        alt="UNIC.ai AI operator"
        className="absolute inset-0 h-full w-full object-cover"
      />

      <div className="absolute inset-0 bg-black/45" />
      <div className="absolute inset-x-0 bottom-0 h-[45vh] bg-gradient-to-t from-black via-black/70 to-transparent" />

      <header className="relative z-20 mx-auto flex max-w-7xl items-center justify-between px-6 py-6 lg:px-10">
        <Link href="/" className="text-2xl font-semibold tracking-[-0.04em] text-white">
          UNIC.ai
        </Link>

        <nav className="hidden items-center gap-9 rounded-full border border-white/10 bg-white/10 px-8 py-3 backdrop-blur-xl md:flex">
          <Link href="/" className="text-sm font-medium text-white/80 hover:text-white">Start</Link>
          <Link href="/workflow-studio" className="text-sm font-medium text-white/80 hover:text-white">Studio</Link>
          <Link href="/agents" className="text-sm font-medium text-white/80 hover:text-white">Agents</Link>
          <Link href="/pricing" className="text-sm font-medium text-white/80 hover:text-white">Pricing</Link>
          <Link href="/login" className="text-sm font-medium text-white/80 hover:text-white">Login</Link>
        </nav>

        <Link
          href="/signup"
          className="hidden rounded-full bg-white px-5 py-2.5 text-sm font-medium text-[#202A36] transition-colors hover:bg-gray-200 md:block"
        >
          Get Started
        </Link>

        <button
          onClick={() => setOpen(!open)}
          className="rounded-full bg-white/15 p-3 text-white backdrop-blur-xl md:hidden"
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </header>

      {open && (
        <div className="absolute left-4 right-4 top-20 z-30 rounded-3xl bg-white/95 p-5 shadow-2xl backdrop-blur-xl md:hidden">
          <div className="grid gap-2">
            <Link href="/" className="rounded-2xl px-4 py-3 text-sm font-medium text-gray-900">Start</Link>
            <Link href="/workflow-studio" className="rounded-2xl px-4 py-3 text-sm font-medium text-gray-900">Studio</Link>
            <Link href="/agents" className="rounded-2xl px-4 py-3 text-sm font-medium text-gray-900">Agents</Link>
            <Link href="/pricing" className="rounded-2xl px-4 py-3 text-sm font-medium text-gray-900">Pricing</Link>
            <Link href="/login" className="rounded-2xl px-4 py-3 text-sm font-medium text-gray-900">Login</Link>
            <Link href="/signup" className="rounded-full bg-[#202A36] px-4 py-3 text-center text-sm font-medium text-white">
              Get Started
            </Link>
          </div>
        </div>
      )}

      <section className="relative z-10 flex min-h-[calc(100vh-96px)] items-end justify-center px-6 pb-20 text-center">
        <div className="max-w-5xl">
          <p className="mb-5 text-sm font-semibold uppercase tracking-[0.22em] text-white/60">
            AI COMPANY OPERATING SYSTEM
          </p>

          <h1 className="text-[clamp(4rem,10vw,9rem)] font-normal leading-[0.86] tracking-[-0.08em] text-white/45">
            Build.
          </h1>

          <h2 className="-mt-3 text-[clamp(4rem,10vw,9rem)] font-normal leading-[0.86] tracking-[-0.08em] text-white">
            Operate.
          </h2>

          <p className="mx-auto mt-8 max-w-2xl text-lg leading-8 text-white/70 md:text-xl">
            One command to create agents, workflows, memory, tools, approvals and runtime operations.
          </p>

          <div className="mt-8 flex justify-center gap-4">
            <Link
              href="/dashboard"
              className="rounded-full bg-gray-300 px-5 py-2.5 text-sm font-medium text-gray-800 transition-colors hover:bg-gray-400"
            >
              View Demo
            </Link>

            <Link
              href="/signup"
              className="rounded-full bg-[#202A36] px-5 py-2.5 text-sm font-medium text-white transition-colors hover:bg-[#1a2229]"
            >
              Start Now
            </Link>
          </div>
        </div>
      </section>
    </main>
  );
}
