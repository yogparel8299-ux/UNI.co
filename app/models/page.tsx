import Shell from "@/components/Shell";

const providers = [
  ["OpenAI / ChatGPT", "Use GPT models with user-owned API billing."],
  ["Anthropic / Claude", "Connect Claude models for reasoning and writing."],
  ["Google Gemini", "Use Gemini for multimodal and workspace tasks."],
  ["Groq", "Fast inference for cheap high-volume runs."],
  ["Mistral", "Open model provider for cost-efficient agents."],
  ["OpenRouter", "One gateway to many models."],
  ["Local Models", "Bring your own hosted model endpoint."],
  ["Custom API", "Connect any model API with headers and endpoint."]
];

export default function Models() {
  return (
    <Shell title="Model Providers" subtitle="Let each user pay for their own model usage while UNIC.ai profits from platform credits, workflow fees and marketplace fees.">
      <div className="grid grid-cols-4 gap-6">
        {providers.map(([name, text]) => (
          <div key={name} className="glass-card p-6">
            <h2 className="text-2xl font-black tracking-[-0.03em]">{name}</h2>
            <p className="text-gray-500 mt-3 leading-7">{text}</p>
            <button className="primary-button mt-6">Connect Provider</button>
          </div>
        ))}
      </div>
    </Shell>
  );
}
