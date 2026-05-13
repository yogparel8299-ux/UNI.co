import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen bg-white p-8">
      <nav className="flex justify-between items-center">
        <div className="text-4xl font-black tracking-[-0.055em]">
          UNIC<span className="text-green-500">.ai</span>
        </div>

        <div className="space-x-5">
          <Link href="/pricing">Pricing</Link>
          <Link href="/login">Login</Link>
          <Link href="/dashboard" className="primary-button">
            Open Dashboard
          </Link>
        </div>
      </nav>

      <section className="py-32 max-w-6xl">
        <p className="text-green-600 font-bold mb-5">
          AI Agent Operating System
        </p>

        <h1 className="text-7xl font-black tracking-[-0.065em] leading-[0.94]">
          Build, host, train, sell and operate AI agents from one beautiful command center.
        </h1>

        <p className="text-xl text-gray-500 mt-8 max-w-3xl leading-8">
          UNIC.ai gives companies one operating layer for agents, swarms, datasets, billing, usage, approvals, marketplace and runtime infrastructure.
        </p>

        <div className="mt-10 flex gap-4">
          <Link href="/command" className="primary-button">
            Build with AI Command
          </Link>

          <Link href="/dashboard" className="secondary-button">
            View Dashboard
          </Link>
        </div>
      </section>

      <section className="grid grid-cols-3 gap-6 pb-20">
        {[
          ["AI Command Center", "Tell UNIC.ai to build companies, agents and workflows."],
          ["Agent Runtime", "Queue tasks and process outputs with workers."],
          ["Marketplace Layer", "Prepare agents and datasets for buying, selling and renting."]
        ].map(([title, text]) => (
          <div key={title} className="glass-card p-8">
            <h3 className="text-2xl font-black tracking-[-0.03em]">{title}</h3>
            <p className="text-gray-500 mt-4 leading-7">{text}</p>
          </div>
        ))}
      </section>
    </main>
  );
}
