"use client";

import { useState } from "react";

type Node = { id: string; type: string; label: string; x: number; y: number; };
type Edge = { from: string; to: string; };

export default function VisualWorkflowEditor() {
  const [nodes, setNodes] = useState<Node[]>([
    { id: "trigger", type: "trigger", label: "Trigger", x: 60, y: 140 },
    { id: "agent", type: "agent", label: "AI Agent", x: 340, y: 140 },
    { id: "tool", type: "tool", label: "Tool Action", x: 620, y: 140 }
  ]);
  const [edges] = useState<Edge[]>([
    { from: "trigger", to: "agent" },
    { from: "agent", to: "tool" }
  ]);
  const [draggingId, setDraggingId] = useState<string | null>(null);
  const [selected, setSelected] = useState<Node | null>(null);

  function addNode(type: string) {
    setNodes([...nodes, {
      id: `${type}-${Date.now()}`,
      type,
      label: type === "agent" ? "New Agent" : type === "tool" ? "New Tool" : type === "memory" ? "Memory" : type === "approval" ? "Approval" : "Step",
      x: 120 + nodes.length * 55,
      y: 300
    }]);
  }

  function onMove(event: React.MouseEvent<HTMLDivElement>) {
    if (!draggingId) return;
    const rect = event.currentTarget.getBoundingClientRect();
    setNodes((current) =>
      current.map((node) =>
        node.id === draggingId
          ? { ...node, x: event.clientX - rect.left - 90, y: event.clientY - rect.top - 44 }
          : node
      )
    );
  }

  function exportGraph() {
    alert(JSON.stringify({ nodes, edges }, null, 2));
  }

  return (
    <div className="glass-card p-8">
      <div className="flex items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black tracking-[-0.04em]">Visual Workflow Builder</h2>
          <p className="text-gray-500 mt-2">Drag nodes, design agent execution, connect tools, memory and approvals.</p>
        </div>
        <div className="flex flex-wrap gap-3 justify-end">
          {["agent", "tool", "memory", "approval"].map((type) => (
            <button key={type} className="secondary-button" onClick={() => addNode(type)}>Add {type}</button>
          ))}
          <button className="primary-button" onClick={exportGraph}>Export</button>
        </div>
      </div>

      <div
        className="relative mt-8 h-[600px] rounded-[32px] border border-black/10 bg-gradient-to-br from-white to-gray-50 overflow-hidden select-none"
        onMouseMove={onMove}
        onMouseUp={() => setDraggingId(null)}
        onMouseLeave={() => setDraggingId(null)}
      >
        <svg className="absolute inset-0 w-full h-full pointer-events-none">
          {edges.map((edge, index) => {
            const from = nodes.find((n) => n.id === edge.from);
            const to = nodes.find((n) => n.id === edge.to);
            if (!from || !to) return null;
            return <line key={index} x1={from.x + 180} y1={from.y + 44} x2={to.x} y2={to.y + 44} stroke="#22c55e" strokeWidth="3" strokeDasharray="8 8" />;
          })}
        </svg>

        {nodes.map((node) => (
          <button
            key={node.id}
            onMouseDown={() => setDraggingId(node.id)}
            onClick={() => setSelected(node)}
            className="absolute w-[180px] h-[88px] rounded-[24px] bg-white border border-black/10 shadow-xl text-left p-4 hover:border-green-400 transition cursor-move"
            style={{ left: node.x, top: node.y }}
          >
            <p className="text-xs text-green-600 font-bold uppercase">{node.type}</p>
            <p className="font-black mt-1">{node.label}</p>
          </button>
        ))}
      </div>

      {selected && (
        <div className="mt-6 rounded-[28px] border border-black/10 p-6 bg-white">
          <p className="font-black">Selected Node</p>
          <p className="text-gray-500 mt-2">{selected.label} — {selected.type}</p>
          <p className="text-gray-400 mt-2 text-sm">Position: x {Math.round(selected.x)}, y {Math.round(selected.y)}</p>
        </div>
      )}
    </div>
  );
}
