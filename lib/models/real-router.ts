import OpenAI from "openai";
import Anthropic from "@anthropic-ai/sdk";
import { requiredEnv, optionalEnv } from "@/lib/env/required";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { decryptSecret } from "@/lib/crypto";

async function getCompanySecret(companyId: string, provider: string) {
  const { data } = await supabaseAdmin
    .from("encrypted_secrets")
    .select("*")
    .eq("company_id", companyId)
    .eq("provider", provider)
    .eq("status", "active")
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (!data?.encrypted_value) return null;
  return decryptSecret(data.encrypted_value);
}

export async function runRealModel({
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
  const selectedProvider = provider || "openai";

  if (selectedProvider === "openai") {
    const apiKey = await getCompanySecret(companyId, "openai") || requiredEnv("OPENAI_API_KEY");
    const client = new OpenAI({ apiKey });

    const result = await client.chat.completions.create({
      model: model || "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt || "You are a UNIC.ai execution agent." },
        { role: "user", content: prompt }
      ]
    });

    return { provider: "openai", model: model || "gpt-4o-mini", text: result.choices?.[0]?.message?.content || "" };
  }

  if (selectedProvider === "anthropic") {
    const apiKey = await getCompanySecret(companyId, "anthropic") || requiredEnv("ANTHROPIC_API_KEY");
    const client = new Anthropic({ apiKey });

    const result = await client.messages.create({
      model: model || "claude-3-5-sonnet-latest",
      max_tokens: 4000,
      system: systemPrompt || "You are a UNIC.ai execution agent.",
      messages: [{ role: "user", content: prompt }]
    });

    const text = result.content.map((part: any) => part.type === "text" ? part.text : "").join("");
    return { provider: "anthropic", model: model || "claude-3-5-sonnet-latest", text };
  }

  if (selectedProvider === "openrouter") {
    const apiKey = await getCompanySecret(companyId, "openrouter") || requiredEnv("OPENROUTER_API_KEY");

    const client = new OpenAI({
      apiKey,
      baseURL: "https://openrouter.ai/api/v1",
      defaultHeaders: {
        "HTTP-Referer": optionalEnv("NEXT_PUBLIC_APP_URL"),
        "X-Title": "UNIC.ai"
      }
    });

    const result = await client.chat.completions.create({
      model: model || "openai/gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt || "You are a UNIC.ai execution agent." },
        { role: "user", content: prompt }
      ]
    });

    return { provider: "openrouter", model: model || "openai/gpt-4o-mini", text: result.choices?.[0]?.message?.content || "" };
  }

  throw new Error(`Unsupported provider: ${selectedProvider}`);
}
