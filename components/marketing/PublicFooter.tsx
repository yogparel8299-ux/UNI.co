import Link from "next/link";

export default function PublicFooter() {
  return (
    <footer className="mx-auto max-w-7xl px-6 py-14">
      <div className="soft-panel grid gap-8 p-8 md:grid-cols-4">
        <div>
          <p className="text-2xl font-black tracking-[-0.04em]">UNIC.ai</p>
          <p className="mt-3 text-slate-500 leading-7">
            A trusted operating layer for AI agents, workflows and connected business systems.
          </p>
        </div>

        <div>
          <p className="font-black">Platform</p>
          <div className="mt-4 space-y-3 text-slate-500">
            <Link className="block" href="/agents">Agents</Link>
            <Link className="block" href="/workflow-studio">Workflows</Link>
            <Link className="block" href="/connection-layer">Connectors</Link>
          </div>
        </div>

        <div>
          <p className="font-black">Business</p>
          <div className="mt-4 space-y-3 text-slate-500">
            <Link className="block" href="/pricing">Pricing</Link>
            <Link className="block" href="/marketplace-explore">Marketplace</Link>
            <Link className="block" href="/security">Security</Link>
          </div>
        </div>

        <div>
          <p className="font-black">Legal</p>
          <div className="mt-4 space-y-3 text-slate-500">
            <Link className="block" href="/legal/privacy">Privacy</Link>
            <Link className="block" href="/legal/ai-policy">AI Policy</Link>
            <Link className="block" href="/legal/refund">Refund</Link>
            <Link className="block" href="/legal/ownership">Ownership</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
