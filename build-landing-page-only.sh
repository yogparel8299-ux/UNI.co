#!/bin/bash
set -e

mkdir -p public app

cat > app/globals.css <<'CSS'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

* {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  padding: 0;
  font-family: Inter, system-ui, sans-serif;
  background: #050505;
}

a {
  text-decoration: none;
}
CSS

cat > app/page.tsx <<'TSX'
"use client";

import Link from "next/link";
import { Menu, X } from "lucide-react";
import { useState } from "react";

const navItems = [
  ["Start", "/"],
  ["Story", "/pricing"],
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Login", "/login"]
];

export default function HomePage() {
  const [open, setOpen] = useState(false);

  return (
    <main className="min-h-screen bg-[#050505]">
      <section className="relative h-screen overflow-hidden">
        <img
          src="/ai-hero.png"
          alt="UNIC.ai cinematic AI operator"
          className="absolute inset-0 h-full w-full object-cover"
        />

        <div className="absolute inset-0 bg-black/35" />
        <div className="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-black/70 to-transparent" />

        <div className="relative z-10 flex h-full flex-col">
          <nav className="mx-auto flex w-full max-w-7xl items-center justify-between px-8 py-6">
            <Link href="/" className="text-2xl font-semibold text-white">
              UNIC.ai
            </Link>

            <div className="hidden items-center gap-9 rounded-full bg-white/10 px-7 py-3 backdrop-blur-xl md:flex">
              {navItems.map(([label, href]) => (
                <Link
                  key={label}
                  href={href}
                  className="text-sm font-medium text-white/80 transition-colors hover:text-white"
                >
                  {label}
                </Link>
              ))}
            </div>

            <Link
              href="/signup"
              className="hidden rounded-full bg-white px-5 py-2 text-sm font-medium text-[#202A36] transition-colors hover:bg-gray-200 md:block"
            >
              Get Started
            </Link>

            <button
              onClick={() => setOpen(!open)}
              className="rounded-full bg-white/15 p-3 text-white backdrop-blur-xl md:hidden"
            >
              {open ? <X size={20} /> : <Menu size={20} />}
            </button>
          </nav>

          {open && (
            <div className="absolute left-4 right-4 top-20 z-20 rounded-3xl bg-white/95 p-5 shadow-2xl backdrop-blur-xl md:hidden">
              <div className="grid gap-3">
                {navItems.map(([label, href]) => (
                  <Link
                    key={label}
                    href={href}
                    className="rounded-2xl px-4 py-3 text-sm font-medium text-gray-900 hover:bg-gray-100"
                  >
                    {label}
                  </Link>
                ))}
                <Link
                  href="/signup"
                  className="rounded-full bg-[#202A36] px-4 py-3 text-center text-sm font-medium text-white"
                >
                  Get Started
                </Link>
              </div>
            </div>
          )}

          <div className="-mt-80 flex flex-1 items-center justify-center px-6 text-center">
            <div>
              <p className="mb-4 text-sm font-semibold uppercase tracking-wider text-white/70">
                AI COMPANY OS
              </p>

              <h1 className="text-6xl font-normal leading-none tracking-tighter text-white/55 md:text-7xl lg:text-8xl">
                Build.
              </h1>

              <h2 className="-mt-3 text-6xl font-normal leading-none tracking-tighter text-white md:text-7xl lg:text-8xl">
                Operate.
              </h2>

              <p className="mx-auto mt-6 mb-6 max-w-2xl text-lg text-white/70 md:text-xl">
                One command to create agents, workflows, memory, tools, approvals and runtime operations.
              </p>

              <div className="flex justify-center gap-4">
                <Link
                  href="/dashboard"
                  className="rounded-full bg-gray-300 px-4 py-2 font-medium text-gray-800 transition-colors hover:bg-gray-400"
                >
                  View Demo
                </Link>

                <Link
                  href="/signup"
                  className="rounded-full bg-[#202A36] px-4 py-2 font-medium text-white transition-colors hover:bg-[#1a2229]"
                >
                  Start Now
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
TSX

npm run build
git add .
git commit -m "Build cinematic UNIC landing page"
git push origin main

echo "DONE. Redeploy Vercel."
