import Link from "next/link";

export default function PublicNav() {
  return (
    <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-7">
      <Link href="/" className="flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-full bg-slate-950 text-white font-black">U</div>
        <div>
          <p className="font-black tracking-[-0.04em]">UNIC.ai</p>
          <p className="text-xs text-slate-500">AI company OS</p>
        </div>
      </Link>

      <div className="hidden rounded-full border border-slate-200 bg-white px-6 py-3 md:flex gap-9 text-sm text-slate-600 shadow-sm">
        <Link href="/pricing">Pricing</Link>
        <Link href="/marketplace-explore">Marketplace</Link>
        <Link href="/security">Security</Link>
        <Link href="/about">Company</Link>
        <Link href="/contact">Contact</Link>
      </div>

      <Link href="/signup" className="primary-button">Get started</Link>
    </nav>
  );
}
