import Shell from "@/components/Shell";

const integrations = [
  ["Slack", "Team alerts, agent updates, approvals and output delivery."],
  ["Zapier", "Connect UNIC.ai agents to thousands of apps."],
  ["Webhooks", "Trigger workflows from any external system."],
  ["Gmail", "Email agents, outreach, support and summaries."],
  ["Notion", "Knowledge base, docs, task logs and company brain."],
  ["HubSpot", "CRM, leads, sales workflows and customer history."],
  ["Google Drive", "Dataset uploads, files and company documents."],
  ["Discord", "Community, agent alerts and workspace updates."]
];

export default function Integrations() {
  return (
    <Shell title="Integrations" subtitle="Connect UNIC.ai to the tools your company already uses.">
      <div className="grid grid-cols-4 gap-6">
        {integrations.map(([name, text]) => (
          <div key={name} className="glass-card p-6">
            <h2 className="text-2xl font-black tracking-[-0.03em]">{name}</h2>
            <p className="text-gray-500 mt-3 leading-7">{text}</p>
            <button className="primary-button mt-6">Connect</button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
