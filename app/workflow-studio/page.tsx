import { AppShell, Icon, Panel } from "@/components/unic/UNICShell";

export default function WorkflowStudioPage() {
  const nodes = [
    ["Webhook In", "left-12 top-16", "webhook"],
    ["LLM Agent", "left-[380px] top-[250px]", "psychology"],
    ["Company Brain", "left-[710px] top-24", "memory"],
    ["Human Approval", "left-[760px] top-[430px]", "verified_user"]
  ];

  return (
    <AppShell title="Workflow Studio" eyebrow="AI Orchestration" right={<Panel><p className="font-mono text-xs uppercase tracking-[0.2em] text-[#2fd9f4]">Inspector</p><h2 className="mt-4 text-2xl font-black">Node Configuration</h2><textarea className="mt-5 h-40 w-full rounded border border-[#45474b] bg-[#000f21] p-3 text-sm text-[#d3e4fe]" defaultValue="Analyze the incoming request and route to the correct AI worker." /></Panel>}>
      <div className="grid h-[calc(100vh-112px)] grid-cols-[250px_1fr] overflow-hidden rounded border border-[#45474b]/40">
        <aside className="border-r border-[#45474b]/40 bg-[#000f21] p-4">
          <button className="mb-5 flex w-full items-center justify-center gap-2 rounded bg-[#2fd9f4] py-3 font-mono text-xs font-black uppercase text-[#00363e]"><Icon name="add" /> New Runtime</button>
          {["Triggers", "AI Models", "Logic & Tools", "Integrations"].map((group) => (
            <div key={group} className="mb-6">
              <p className="mb-2 font-mono text-[10px] uppercase tracking-[0.18em] text-[#c6c6cb]/50">{group}</p>
              {["Webhook", "LLM Inference", "Vector Store", "Slack Outbound"].map((x) => (
                <div key={x} className="rounded px-3 py-2 font-mono text-xs text-[#c6c6cb] hover:bg-[#26364a]/40 hover:text-[#2fd9f4]">{x}</div>
              ))}
            </div>
          ))}
        </aside>
        <section className="relative overflow-hidden bg-[#031427]">
          <div className="absolute inset-0 bg-[radial-gradient(rgba(144,144,149,.16)_1px,transparent_1px)] bg-[size:24px_24px]" />
          {nodes.map(([label, pos, icon]) => (
            <div key={label} className={`absolute ${pos} w-60 rounded border border-[#45474b]/50 bg-[#102034]/95 p-4 shadow-2xl`}>
              <div className="flex items-center gap-3">
                <Icon name={icon} />
                <b>{label}</b>
              </div>
              <p className="mt-3 font-mono text-[11px] text-[#c6c6cb]/70">status: ready</p>
            </div>
          ))}
        </section>
      </div>
    </AppShell>
  );
}
