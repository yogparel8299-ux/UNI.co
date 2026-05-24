"use client";

import Link from "next/link";
import { Menu, X } from "lucide-react";
import { useState } from "react";

export default function HomePage() {
  const [open, setOpen] = useState(false);

  return (
    <main className="unic-landing">
      <img src="/ai-hero.png" alt="" className="hero-image" />
      <div className="hero-shade" />

      <nav className="nav">
        <Link href="/" className="brand">UNIC.ai</Link>

        <div className="desktop-nav">
          <Link href="/">Start</Link>
          <Link href="/pricing">Story</Link>
          <Link href="/workflow-studio">Studio</Link>
          <Link href="/agents">Agents</Link>
          <Link href="/login">Login</Link>
        </div>

        <Link href="/signup" className="desktop-cta">Get Started</Link>

        <button className="mobile-btn" onClick={() => setOpen(!open)}>
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </nav>

      {open && (
        <div className="mobile-menu">
          <Link href="/">Start</Link>
          <Link href="/pricing">Story</Link>
          <Link href="/workflow-studio">Studio</Link>
          <Link href="/agents">Agents</Link>
          <Link href="/login">Login</Link>
          <Link href="/signup" className="mobile-cta">Get Started</Link>
        </div>
      )}

      <section className="hero-content">
        <p className="label">AI COMPANY OS</p>
        <h1 className="ghost">Build.</h1>
        <h2>Operate.</h2>
        <p className="subtitle">
          One command to create agents, workflows, memory, tools, approvals and runtime operations.
        </p>

        <div className="buttons">
          <Link href="/dashboard" className="btn light">View Demo</Link>
          <Link href="/signup" className="btn dark">Start Now</Link>
        </div>
      </section>

      <style jsx global>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

        * {
          box-sizing: border-box;
        }

        html, body {
          margin: 0;
          padding: 0;
          font-family: Inter, system-ui, sans-serif;
          background: #050505;
        }

        a {
          text-decoration: none;
        }

        .unic-landing {
          position: relative;
          min-height: 100vh;
          overflow: hidden;
          background: #050505;
          color: white;
        }

        .hero-image {
          position: absolute;
          inset: 0;
          width: 100%;
          height: 100%;
          object-fit: cover;
          z-index: 0;
        }

        .hero-shade {
          position: absolute;
          inset: 0;
          background:
            linear-gradient(to bottom, rgba(0,0,0,.35), rgba(0,0,0,.28), rgba(0,0,0,.72)),
            radial-gradient(circle at center, transparent 0%, rgba(0,0,0,.25) 45%, rgba(0,0,0,.85) 100%);
          z-index: 1;
        }

        .nav {
          position: relative;
          z-index: 5;
          max-width: 1280px;
          margin: 0 auto;
          padding: 24px 32px;
          display: flex;
          align-items: center;
          justify-content: space-between;
        }

        .brand {
          font-size: 24px;
          font-weight: 600;
          color: white;
          letter-spacing: -0.04em;
        }

        .desktop-nav {
          display: flex;
          align-items: center;
          gap: 34px;
          padding: 12px 28px;
          border-radius: 999px;
          background: rgba(255,255,255,.11);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255,255,255,.12);
        }

        .desktop-nav a {
          color: rgba(255,255,255,.78);
          font-size: 14px;
          font-weight: 500;
          transition: color .2s ease;
        }

        .desktop-nav a:hover {
          color: white;
        }

        .desktop-cta {
          padding: 10px 18px;
          border-radius: 999px;
          background: white;
          color: #202A36;
          font-size: 14px;
          font-weight: 500;
        }

        .mobile-btn {
          display: none;
          border: 0;
          border-radius: 999px;
          background: rgba(255,255,255,.15);
          color: white;
          padding: 10px;
          backdrop-filter: blur(20px);
        }

        .mobile-menu {
          position: absolute;
          z-index: 10;
          top: 82px;
          left: 18px;
          right: 18px;
          display: grid;
          gap: 8px;
          padding: 16px;
          border-radius: 24px;
          background: rgba(255,255,255,.95);
          backdrop-filter: blur(20px);
        }

        .mobile-menu a {
          color: #111827;
          font-size: 14px;
          font-weight: 500;
          padding: 12px;
          border-radius: 14px;
        }

        .mobile-cta {
          text-align: center;
          background: #202A36;
          color: white !important;
        }

        .hero-content {
          position: relative;
          z-index: 4;
          min-height: calc(100vh - 96px);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          text-align: center;
          margin-top: -120px;
          padding: 0 24px;
        }

        .label {
          margin: 0 0 16px;
          font-size: 14px;
          font-weight: 600;
          color: rgba(255,255,255,.62);
          letter-spacing: .16em;
        }

        .ghost {
          margin: 0;
          font-size: clamp(64px, 9vw, 128px);
          line-height: .92;
          font-weight: 400;
          letter-spacing: -0.08em;
          color: rgba(255,255,255,.42);
        }

        h2 {
          margin: -12px 0 0;
          font-size: clamp(64px, 9vw, 128px);
          line-height: .92;
          font-weight: 400;
          letter-spacing: -0.08em;
          color: white;
        }

        .subtitle {
          max-width: 680px;
          margin: 28px auto 26px;
          color: rgba(255,255,255,.68);
          font-size: 20px;
          line-height: 1.5;
        }

        .buttons {
          display: flex;
          justify-content: center;
          gap: 16px;
        }

        .btn {
          padding: 10px 18px;
          border-radius: 999px;
          font-size: 14px;
          font-weight: 500;
          transition: all .2s ease;
        }

        .btn.light {
          background: #d1d5db;
          color: #1f2937;
        }

        .btn.light:hover {
          background: #9ca3af;
        }

        .btn.dark {
          background: #202A36;
          color: white;
        }

        .btn.dark:hover {
          background: #1a2229;
        }

        @media (max-width: 768px) {
          .desktop-nav,
          .desktop-cta {
            display: none;
          }

          .mobile-btn {
            display: flex;
          }

          .nav {
            padding: 20px;
          }

          .hero-content {
            margin-top: -60px;
          }

          .subtitle {
            font-size: 16px;
          }
        }
      `}</style>
    </main>
  );
}
