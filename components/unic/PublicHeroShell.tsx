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
  ctaHref = "/signup",
  children
}: {
  badge: string;
  title: string;
  subtext: string;
  cta: string;
  ctaHref?: string;
  children?: React.ReactNode;
}) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-[#f0f0ee]">
      <video
        className="video-soft absolute inset-0 h-full w-full object-cover"
        src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4"
        autoPlay
        muted
        loop
        playsInline
      />
      <div className="absolute inset-0 bg-[#f0f0ee]/10" />

      <div className="relative z-10 flex min-h-screen flex-col">
        <nav className="flex items-center justify-center gap-2 px-4 pt-4 sm:gap-3 sm:px-8 sm:pt-6">
          <Link
            href="/"
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full sm:h-11 sm:w-11"
            style={{ backgroundColor: "#EDEDED" }}
          >
            <Logo />
          </Link>

          <div
            className="flex items-center gap-4 rounded-xl px-4 py-2.5 sm:gap-10 sm:px-8 sm:py-3"
            style={{ backgroundColor: "#EDEDED" }}
          >
            {links.map(([label, href]) => (
              <Link
                key={href}
                href={href}
                className="text-[12px] font-medium text-gray-700 transition-colors duration-200 hover:text-gray-900 sm:text-[14px]"
              >
                {label}
              </Link>
            ))}
          </div>
        </nav>

        <section className="flex flex-1 items-end px-6 pb-10 sm:px-12 sm:pb-16 md:px-20 lg:px-28 lg:pb-20">
          <div className="max-w-xs">
            <Link
              href="/dashboard"
              className="group mb-3 inline-flex items-center gap-1.5 text-[11.5px] font-medium text-blue-500 transition-colors hover:text-blue-600"
            >
              {badge}
              <span className="inline-block transition-transform duration-200 group-hover:translate-x-0.5">→</span>
            </Link>

            <h1 className="mb-3 text-[1.5rem] font-medium leading-[1.15] tracking-tight text-gray-900 sm:text-[1.75rem]">
              {title}
            </h1>

            <p className="mb-3 text-[13px] font-normal text-gray-400">{subtext}</p>

            <Link
              href={ctaHref}
              className="group inline-flex items-center gap-2 rounded-full border border-blue-400 px-5 py-2.5 text-[13px] font-medium text-blue-500 transition-all duration-200 hover:border-blue-500 hover:bg-blue-500 hover:text-white"
            >
              {cta}
              <span className="transition-transform duration-200 group-hover:translate-x-0.5">→</span>
            </Link>
          </div>
        </section>

        {children}
      </div>
    </main>
  );
}
