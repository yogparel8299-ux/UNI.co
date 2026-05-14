import OpenAI from "openai";

export async function embedText(text: string) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY missing.");

  const openai = new OpenAI({ apiKey });

  const res = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: text.slice(0, 8000)
  });

  return res.data[0].embedding;
}
