#!/bin/bash
set -e

echo "Fixing broken styling by using real CSS, not relying on broken Tailwind output..."

cat > app/globals.css <<'CSS'
* { box-sizing: border-box; }

html, body {
  margin: 0;
  padding: 0;
  background: #f0f0ee;
  color: #111827;
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

a { color: inherit; text-decoration: none; }

.video-bg {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: saturate(.88) contrast(.96) brightness(.98);
  z-index: 0;
}

.page-overlay {
  position: fixed;
  inset: 0;
  background: rgba(240,240,238,.16);
  z-index: 1;
}

.unic-page {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  background: #f0f0ee;
}

.unic-content {
  position: relative;
  z-index: 2;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.unic-nav {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24px 32px 0;
  gap: 12px;
}

.logo-pill {
  width: 44px;
  height: 44px;
  border-radius: 999px;
  background: #ededed;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 10px 40px rgba(0,0,0,.08);
}

.nav-pill {
  display: flex;
  align-items: center;
  gap: 40px;
  border-radius: 14px;
  padding: 12px 32px;
  background: #ededed;
  box-shadow: 0 10px 40px rgba(0,0,0,.08);
}

.nav-pill a {
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  transition: color .2s ease;
}

.nav-pill a:hover { color: #111827; }

.hero-area {
  flex: 1;
  display: flex;
  align-items: flex-end;
  padding: 0 112px 80px;
}

.hero-copy {
  max-width: 360px;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 12px;
  font-size: 11.5px;
  font-weight: 500;
  color: #3b82f6;
}

.hero-title {
  margin: 0 0 12px;
  font-size: 1.75rem;
  line-height: 1.15;
  font-weight: 500;
  letter-spacing: -0.035em;
  color: #111827;
}

.hero-subtext {
  margin: 0 0 12px;
  font-size: 13px;
  font-weight: 400;
  color: #9ca3af;
}

.hero-cta {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border: 1px solid #60a5fa;
  border-radius: 999px;
  padding: 10px 20px;
  font-size: 13px;
  font-weight: 500;
  color: #3b82f6;
  transition: all .2s ease;
}

.hero-cta:hover {
  background: #3b82f6;
  border-color: #3b82f6;
  color: white;
}

.arrow {
  display: inline-block;
  transition: transform .2s ease;
}

.hero-badge:hover .arrow,
.hero-cta:hover .arrow {
  transform: translateX(2px);
}

.app-shell {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  background: #f0f0ee;
}

.app-layout {
  position: relative;
  z-index: 2;
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 260px;
  flex-shrink: 0;
  border-right: 1px solid rgba(255,255,255,.45);
  background: rgba(237,237,237,.74);
  backdrop-filter: blur(24px);
  padding: 16px;
}

.brand {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 32px;
}

.brand-title {
  font-size: 18px;
  font-weight: 650;
  letter-spacing: -0.04em;
}

.brand-sub {
  font-size: 11px;
  color: #6b7280;
}

.sidebar-nav {
  display: grid;
  gap: 4px;
}

.sidebar-link {
  border-radius: 14px;
  padding: 12px 16px;
  font-size: 13px;
  font-weight: 500;
  color: #4b5563;
  transition: all .2s ease;
}

.sidebar-link:hover {
  background: rgba(255,255,255,.62);
  color: #111827;
}

.main {
  flex: 1;
}

.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 32px;
}

.title-box {
  background: rgba(237,237,237,.82);
  backdrop-filter: blur(24px);
  border-radius: 14px;
  padding: 12px 20px;
  box-shadow: 0 20px 80px rgba(0,0,0,.08);
}

.eyebrow {
  margin: 0 0 4px;
  font-size: 11px;
  font-weight: 500;
  color: #3b82f6;
}

.page-title {
  margin: 0;
  font-size: 1.55rem;
  line-height: 1.1;
  font-weight: 500;
  letter-spacing: -0.035em;
}

.top-actions {
  display: flex;
  gap: 8px;
}

.top-action {
  border-radius: 14px;
  padding: 12px 16px;
  background: rgba(237,237,237,.82);
  backdrop-filter: blur(24px);
  font-size: 13px;
  font-weight: 500;
  color: #374151;
}

.page-body {
  padding: 0 32px 40px;
}

.metrics {
  display: grid;
  grid-template-columns: repeat(4, minmax(0,1fr));
  gap: 12px;
}

.grid-main {
  margin-top: 12px;
  display: grid;
  grid-template-columns: 1.2fr .8fr;
  gap: 12px;
}

.card {
  background: rgba(237,237,237,.78);
  backdrop-filter: blur(24px);
  border: 1px solid rgba(255,255,255,.42);
  border-radius: 22px;
  padding: 20px;
  box-shadow: 0 20px 80px rgba(0,0,0,.08);
}

.metric-label {
  margin: 0;
  font-size: 11.5px;
  font-weight: 500;
  color: #9ca3af;
}

.metric-value {
  margin: 8px 0 0;
  font-size: 1.75rem;
  font-weight: 500;
  line-height: 1;
  letter-spacing: -0.035em;
}

.panel-title {
  margin: 0 0 12px;
  color: #3b82f6;
  font-size: 11.5px;
  font-weight: 500;
}

.panel-heading {
  margin: 0;
  max-width: 460px;
  font-size: 1.75rem;
  line-height: 1.15;
  font-weight: 500;
  letter-spacing: -0.035em;
}

.panel-text {
  margin: 12px 0 0;
  max-width: 420px;
  font-size: 13px;
  color: #9ca3af;
}

.row-list {
  margin-top: 32px;
  display: grid;
  gap: 8px;
}

.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 14px;
  background: rgba(255,255,255,.52);
  padding: 12px 16px;
  font-size: 13px;
  color: #374151;
}

@media (max-width: 900px) {
  .hero-area { padding: 0 24px 48px; }
  .sidebar { display: none; }
  .metrics { grid-template-columns: repeat(2, minmax(0,1fr)); }
  .grid-main { grid-template-columns: 1fr; }
  .nav-pill { gap: 16px; padding: 10px 16px; }
  .nav-pill a { font-size: 12px; }
}
CSS

cat > components/unic/PublicHeroShell.tsx <<'TSX'
import Link from "next/link";
import Logo from "./Logo";

const links = [
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Pricing", "/pricing"],
  ["Login", "/login"]
];

export default function PublicHeroShell({
  badge,
  title,
  subtext,
  cta,
  ctaHref = "/signup"
}: {
  badge: string;
  title: string;
  subtext: string;
  cta: string;
  ctaHref?: string;
}) {
  return (
    <main className="unic-page">
      <video
        className="video-bg"
        src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4"
        autoPlay
        muted
        loop
        playsInline
      />
      <div className="page-overlay" />

      <div className="unic-content">
        <nav className="unic-nav">
          <Link href="/" className="logo-pill">
            <Logo />
          </Link>

          <div className="nav-pill">
            {links.map(([label, href]) => (
              <Link key={href} href={href}>{label}</Link>
            ))}
          </div>
        </nav>

        <section className="hero-area">
          <div className="hero-copy">
            <Link href="/dashboard" className="hero-badge">
              {badge}
              <span className="arrow">→</span>
            </Link>

            <h1 className="hero-title">{title}</h1>
            <p className="hero-subtext">{subtext}</p>

            <Link href={ctaHref} className="hero-cta">
              {cta}
              <span className="arrow">→</span>
            </Link>
          </div>
        </section>
      </div>
    </main>
  );
}
TSX

cat > components/unic/AppShell.tsx <<'TSX'
"use client";

import Link from "next/link";
import Logo from "./Logo";

const nav = [
  ["Dashboard", "/dashboard"],
  ["Studio", "/workflow-studio"],
  ["Agents", "/agents"],
  ["Swarms", "/swarms"],
  ["Tasks", "/tasks"],
  ["Goals", "/goals"],
  ["Datasets", "/datasets"],
  ["Brain", "/brain"],
  ["Connect", "/connection-layer"],
  ["Market", "/marketplace"],
  ["Billing", "/billing"],
  ["Usage", "/usage"],
  ["Budgets", "/budgets"],
  ["Team", "/team"],
  ["Schedules", "/schedules"],
  ["Approvals", "/approvals"],
  ["Activity", "/activity"],
  ["Security", "/security"],
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
    <main className="app-shell">
      <video
        className="video-bg"
        src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4"
        autoPlay
        muted
        loop
        playsInline
      />
      <div className="page-overlay" />

      <div className="app-layout">
        <aside className="sidebar">
          <Link href="/" className="brand">
            <div className="logo-pill">
              <Logo />
            </div>
            <div>
              <div className="brand-title">UNIC.ai</div>
              <div className="brand-sub">Operating system</div>
            </div>
          </Link>

          <nav className="sidebar-nav">
            {nav.map(([label, href]) => (
              <Link key={href} href={href} className="sidebar-link">
                {label}
              </Link>
            ))}
          </nav>
        </aside>

        <section className="main">
          <header className="topbar">
            <div className="title-box">
              <p className="eyebrow">{eyebrow}</p>
              <h1 className="page-title">{title}</h1>
            </div>

            <div className="top-actions">
              <Link href="/billing" className="top-action">Credits</Link>
              <Link href="/notifications" className="top-action">Alerts</Link>
              <Link href="/settings" className="top-action">Settings</Link>
            </div>
          </header>

          <div className="page-body">{children}</div>
        </section>
      </div>
    </main>
  );
}

export function Card({ children, className = "" }: { children: React.ReactNode; className?: string }) {
  return <div className={`card ${className}`}>{children}</div>;
}

export function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="card">
      <p className="metric-label">{label}</p>
      <p className="metric-value">{value}</p>
    </div>
  );
}
TSX

npm run build
git add .
git commit -m "Fix UNIC styling with real CSS system"
git push origin main

echo "DONE. Redeploy Vercel."
