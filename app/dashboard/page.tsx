import { AppShell, Panel, Stat } from "@/components/unic/UNICShell";

export default function DashboardPage() {
  return (
    <AppShell title="Mission Control" eyebrow="Operational OS">
      <div className="grid gap-5 md:grid-cols-4">
        <Stat label="Active Agents" value="18" />
        <Stat label="Running Workflows" value="42" tone="violet" />
        <Stat label="Approvals" value="07" tone="emerald" />
        <Stat label="Runtime Health" value="99.9%" />
      </div>
      <div className="mt-5 grid gap-5 xl:grid-cols-[1.3fr_.7fr]">
        <Panel className="min-h-[520px]">
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#2fd9f4]">Live Runtime Feed</p>
          <div className="mt-5 space-y-3 font-mono text-sm">
            {["Agent Sentinel completed data audit", "Workflow Support_OS moved to review", "Gmail connector synchronized", "Dataset embedding queued", "Approval requested for outbound email"].map((x, i) => (
              <div key={x} className="flex gap-4 border-b border-[#45474b]/20 py-3">
                <span className="text-[#909095]">14:{22 + i}:0{i}</span>
                <span className="text-[#2fd9f4]">[INFO]</span>
                <span className="text-[#c6c6cb]">{x}</span>
              </div>
            ))}
          </div>
        </Panel>
        <Panel>
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-[#c0c1ff]">Connected Entities</p>
          <div className="mt-5 space-y-3">
            {["GPT Orchestrator", "Pinecone Vector DB", "Gmail Runtime", "Slack Runtime"].map((x) => (
              <div key={x} className="flex items-center justify-between rounded border border-[#45474b]/30 bg-[#000f21] p-3">
                <span className="font-bold">{x}</span>
                <span className="font-mono text-[10px] text-emerald-400">ACTIVE</span>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </AppShell>
  );
}
