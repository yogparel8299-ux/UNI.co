import Link from "next/link";

export default function PublicShell({ children }: { children: React.ReactNode }) {
  return (
    <main className="min-h-screen bg-[#f7f7f8] text-black">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
        <Link href="/" className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-xl bg-black text-white font-black">U</div>
          <div>
            <p className="text-xl font-black tracking-[-0.04em]">UNIC.ai</p>
            <p className="text-xs text-neutral-500">AI company operating system</p>
          </div>
        </Link>

        <div className="hidden rounded-full border border-neutral-200 bg-white px-6 py-3 text-sm font-bold text-neutral-600 shadow-sm md:flex gap-8">
          <Link href="/dashboard">Demo</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/legal/privacy">Privacy</Link>
          <Link href="/legal/ai-policy">AI Policy</Link>
        </div>

        <Link href="/signup" className="rounded-xl bg-black px-5 py-3 text-sm font-bold text-white">
          Get Started
        </Link>
      </nav>

      {children}
    </main>
  );
}
