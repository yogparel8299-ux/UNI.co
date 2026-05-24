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
