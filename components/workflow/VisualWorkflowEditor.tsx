"use client";

import { useState } from "react";

type WorkflowNode = {
  id: string;
  type: string;
  label: string;
  x: number;
  y: number;
};

type WorkflowEdge = {
  from: string;
  to: string;
};

export default function VisualWorkflowEditor() {
  const [nodes, setNodes] = useState<WorkflowNode[]>([
    {
      id: "trigger",
      type: "trigger",
      label: "Trigger",
      x: 60,
      y: 120
    },
    {
      id: "agent",
      type: "agent",
      label: "AI Agent",
      x: 340,
      y: 120
    },
    {
      id: "tool",
      type: "tool",
      label: "Tool Action",
      x: 620,
      y: 120
    }
  ]);

  const [edges, setEdges] = useState<WorkflowEdge[]>([
    {
      from: "trigger",
      to: "agent"
    },
    {
      from: "agent",
      to: "tool"
    }
  ]);

  const [selected, setSelected] = useState<WorkflowNode | null>(null);

  function addNode(type: string) {
    const id = `${type}-${Date.now()}`;

    setNodes([
      ...nodes,
      {
        id,
        type,
        label:
          type === "agent"
            ? "New Agent"
            : type === "tool"
            ? "New Tool"
            : type === "approval"
            ? "Approval"
            : "New Step",
        x: 100 + nodes.length * 70,
        y: 280
      }
    ]);
  }

  function exportGraph() {
    alert(JSON.stringify({ nodes, edges }, null, 2));
  }

  return (
    <div className="glass-card p-8">
      <div className="flex items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black tracking-[-0.04em]">
            Visual Workflow Builder
          </h2>

          <p className="text-gray-500 mt-2">
            Build workflows with triggers, AI agents, tools, memory and approvals.
          </p>
        </div>

        <div className="flex gap-3">
          <button className="secondary-button" onClick={() => addNode("agent")}>
            Add Agent
          </button>

          <button className="secondary-button" onClick={() => addNode("tool")}>
            Add Tool
          </button>

          <button className="secondary-button" onClick={() => addNode("approval")}>
            Add Approval
          </button>

          <button className="primary-button" onClick={exportGraph}>
            Export Graph
          </button>
        </div>
      </div>

      <div className="relative mt-8 h-[560px] rounded-[32px] border border-black/10 bg-gradient-to-br from-white to-gray-50 overflow-hidden">
        <svg className="absolute inset-0 w-full h-full">
          {edges.map((edge, index) => {
            const from = nodes.find((node) => node.id === edge.from);
            const to = nodes.find((node) => node.id === edge.to);

            if (!from || !to) return null;

            return (
              <line
                key={index}
                x1={from.x + 90}
                y1={from.y + 44}
                x2={to.x}
                y2={to.y + 44}
                stroke="#22c55e"
                strokeWidth="3"
                strokeDasharray="8 8"
              />
            );
          })}
        </svg>

        {nodes.map((node) => (
          <button
            key={node.id}
            onClick={() => setSelected(node)}
            className="absolute w-[180px] h-[88px] rounded-[24px] bg-white border border-black/10 shadow-xl text-left p-4 hover:border-green-400 transition"
            style={{
              left: node.x,
              top: node.y
            }}
          >
            <p className="text-xs text-green-600 font-bold uppercase">
              {node.type}
            </p>

            <p className="font-black mt-1">
              {node.label}
            </p>
          </button>
        ))}
      </div>

      {selected && (
        <div className="mt-6 rounded-[28px] border border-black/10 p-6 bg-white">
          <p className="font-black">
            Selected Node
          </p>

          <p className="text-gray-500 mt-2">
            {selected.label} — {selected.type}
          </p>
        </div>
      )}
    </div>
  );
}
