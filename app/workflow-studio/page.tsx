import OpsShell from "@/components/ops/OpsShell";

const nodes = [
  ["Trigger", "User command", "left-[70px] top-[120px]"],
  ["Agent", "Research Agent", "left-[360px] top-[190px]"],
  ["Memory", "Company Brain", "left-[650px] top-[95px]"],
  ["Approval", "Human Review", "left-[650px] top-[330px]"],
  ["Tool", "Gmail Draft", "left-[930px] top-[210px]"]
];

export default function WorkflowStudioPage() {
  return (
    <OpsShell
      title="Workflow Studio"
      subtitle="Drag-and-drop AI workflows with agents, tools, memory and approvals."
      rightPanel={
        <div className="p-5">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-neutral-400">Properties</p>
          <h2 className="mt-3 text-xl font-black">Selected Node</h2>
          <div className="mt-5 space-y-4">
            <input className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Node name" />
            <select className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm">
              <option>Agent</option>
              <option>Skill</option>
              <option>Tool</option>
              <option>Approval</option>
              <option>Memory</option>
            </select>
            <textarea className="min-h-[130px] w-full rounded-lg border border-neutral-200 px-3 py-2 text-sm" placeholder="Instructions" />
            <button className="w-full rounded-lg bg-black px-4 py-3 text-sm font-bold text-white">Save Node</button>
          </div>
        </div>
      }
    >
      <div className="mb-4 flex items-center justify-between">
        <div className="flex gap-2">
          {["Trigger", "Agent", "Skill", "Tool", "Memory", "Approval", "Condition"].map((x) => (
            <button key={x} className="rounded-lg border border-neutral-200 bg-white px-3 py-2 text-sm font-bold">
              + {x}
            </button>
          ))}
        </div>

        <button className="rounded-lg bg-black px-4 py-2 text-sm font-bold text-white">
          Run Workflow
        </button>
      </div>

      <div className="relative h-[720px] overflow-hidden rounded-2xl border border-neutral-200 bg-white">
        <div className="absolute inset-0 bg-[linear-gradient(#eee_1px,transparent_1px),linear-gradient(90deg,#eee_1px,transparent_1px)] bg-[size:28px_28px]" />

        <svg className="absolute inset-0 h-full w-full">
          <path d="M250 170 C330 170 300 235 360 235" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M550 235 C620 235 595 150 650 150" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M550 235 C620 235 595 385 650 385" fill="none" stroke="#111" strokeWidth="2" />
          <path d="M835 385 C900 385 870 265 930 265" fill="none" stroke="#111" strokeWidth="2" />
        </svg>

        {nodes.map(([type, label, pos]) => (
          <div key={label} className={`absolute ${pos} w-[190px] rounded-xl border border-neutral-300 bg-white p-4 shadow-lg`}>
            <p className="text-[11px] font-black uppercase tracking-[0.14em] text-neutral-400">{type}</p>
            <h3 className="mt-2 font-black">{label}</h3>
            <p className="mt-2 text-xs text-neutral-500">Click to configure</p>
          </div>
        ))}
      </div>
    </OpsShell>
  );
}
