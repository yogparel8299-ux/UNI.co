export function chunkText(text: string, size = 1200, overlap = 150) {
  const clean = text.replace(/\s+/g, " ").trim();
  const chunks: string[] = [];
  let index = 0;

  while (index < clean.length) {
    chunks.push(clean.slice(index, index + size));
    index += size - overlap;
  }

  return chunks.filter(Boolean);
}
