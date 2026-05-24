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
