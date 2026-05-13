import OpenAI from "openai";
import Anthropic from "@anthropic-ai/sdk";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { decryptSecret } from "@/lib/crypto";

async function getSecret(companyId: string, provider: string) {
  const { data } = await supabaseAdmin
    .from("encrypted_secrets")
    .select("*")
    .eq("company_id", companyId)
    .eq("provider", provider)
    .eq("status", "active")
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (!data?.encrypted_value) return null;

  return decryptSecret(data.encrypted_value);
}

export async function runModelRouter({
  companyId,
  prompt,
  systemPrompt,
  provider,
  model
}: {
  companyId: string;
  prompt: string;
  systemPrompt?: string;
  provider?: string;
  model?: string;
}) {
  let selectedProvider = provider;
  let selectedModel = model;

  if (!selectedProvider || !selectedModel) {
    const { data: rule } = await supabaseAdmin
      .from("model_router_rules")
      .select("*")
      .eq("company_id", companyId)
      .eq("status", "active")
      .order("created_at", { ascending: false })
      .limit(1)
      .single();

    selectedProvider = rule?.primary_provider || "openai";
    selectedModel = rule?.primary_model || "gpt-4o-mini";
  }

  if (selectedProvider === "openai") {
    const apiKey = await getSecret(companyId, "openai") || process.env.OPENAI_API_KEY;

    if (!apiKey) throw new Error("OpenAI key missing.");

    const client = new OpenAI({ apiKey });

    const result = await client.chat.completions.create({
      model: selectedModel || "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: systemPrompt || "You are a useful UNIC.ai execution agent."
        },
        {
          role: "user",
          content: prompt
        }
      ]
    });

    return {
      provider: "openai",
      model: selectedModel,
      text: result.choices?.[0]?.message?.content || ""
    };
  }

  if (selectedProvider === "anthropic") {
    const apiKey = await getSecret(companyId, "anthropic");

    if (!apiKey) throw new Error("Anthropic Claude key missing.");

    const client = new Anthropic({ apiKey });

    const result = await client.messages.create({
      model: selectedModel || "claude-3-5-sonnet-latest",
      max_tokens: 2000,
      system: systemPrompt || "You are a useful UNIC.ai execution agent.",
      messages: [
        {
          role: "user",
          content: prompt
        }
      ]
    });

    const text = result.content
      .map((part: any) => part.type === "text" ? part.text : "")
      .join("");

    return {
      provider: "anthropic",
      model: selectedModel,
      text
    };
  }

  if (selectedProvider === "openrouter") {
    const apiKey = await getSecret(companyId, "openrouter");

    if (!apiKey) throw new Error("OpenRouter key missing.");

    const client = new OpenAI({
      apiKey,
      baseURL: "https://openrouter.ai/api/v1"
    });

    const result = await client.chat.completions.create({
      model: selectedModel || "openai/gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: systemPrompt || "You are a useful UNIC.ai execution agent."
        },
        {
          role: "user",
          content: prompt
        }
      ]
    });

    return {
      provider: "openrouter",
      model: selectedModel,
      text: result.choices?.[0]?.message?.content || ""
    };
  }

  throw new Error(`Unsupported provider: ${selectedProvider}`);
}
