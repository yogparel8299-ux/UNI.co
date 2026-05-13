import Link from "next/link";

export default function Signup() {
  return (
    <main className="min-h-screen bg-white p-10 flex items-center justify-center">
      <div className="glass-card p-10 w-full max-w-md">
        <Link href="/" className="text-3xl font-black tracking-[-0.05em]">
          UNIC<span className="text-green-500">.ai</span>
        </Link>
        <h1 className="text-4xl font-black mt-10">Signup</h1>
        <p className="text-gray-500 mt-4">
          Signup and company onboarding can be connected here.
        </p>
      </div>
    </main>
  );
}
