import OpenAI from "openai";

export async function createEmbedding(text: string) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY required for embeddings.");

  const openai = new OpenAI({ apiKey });

  const result = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: text.slice(0, 8000)
  });

  return result.data[0].embedding;
}
