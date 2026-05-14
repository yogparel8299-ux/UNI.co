export async function parseUploadedFile(file: File) {
  const name = file.name.toLowerCase();
  const buffer = Buffer.from(await file.arrayBuffer());

  if (name.endsWith(".txt") || name.endsWith(".md") || name.endsWith(".csv")) {
    return buffer.toString("utf8");
  }

  if (name.endsWith(".json")) {
    return JSON.stringify(JSON.parse(buffer.toString("utf8")), null, 2);
  }

  if (name.endsWith(".pdf")) {
    const pdfParse = (await import("pdf-parse")).default as any;
    const parsed = await pdfParse(buffer);
    return parsed.text || "";
  }

  if (name.endsWith(".docx")) {
    const mammoth = await import("mammoth");
    const parsed = await mammoth.extractRawText({ buffer });
    return parsed.value || "";
  }

  return buffer.toString("utf8");
}
