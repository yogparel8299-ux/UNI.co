import Link from "next/link";

export default function Pricing() {
  const plans = [
    ["Free", "$0", "Test agents and workflows."],
    ["Founder", "$29/mo", "For solo founders and early teams."],
    ["Business", "$299/mo", "For companies running AI operations."],
    ["Enterprise", "Custom", "For AI workforce infrastructure."]
  ];

  return (
    <main className="min-h-screen bg-white p-10">
      <Link href="/" className="text-3xl font-black tracking-[-0.05em]">
        UNIC<span className="text-green-500">.ai</span>
      </Link>

      <h1 className="text-6xl font-black tracking-[-0.055em] mt-16">
        Pricing built for AI operators.
      </h1>

      <div className="grid grid-cols-4 gap-6 mt-12">
        {plans.map(([name, price, text]) => (
          <div key={name} className="glass-card p-8">
            <h2 className="text-2xl font-black">{name}</h2>
            <p className="text-4xl font-black mt-4">{price}</p>
            <p className="text-gray-500 mt-4 leading-7">{text}</p>
          </div>
        ))}
      </div>
    </main>
  );
}
