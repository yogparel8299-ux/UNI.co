import AppShell from "@/components/unic/AppShell";
import { getWorkspace } from "@/lib/server/workspace";
import { getProviderStatus } from "@/lib/guards/providers";

export default async function DatasetsPage() {
  const { supabase, user, companyId } = await getWorkspace();
  const providers = getProviderStatus();

  const { data: datasets } = user && companyId
    ? await supabase.from("datasets").select("*").eq("company_id", companyId).order("created_at", { ascending: false })
    : { data: [] };

  return (
    <AppShell title="Datasets" subtitle="Upload, ingest and embed company knowledge.">
      {!providers.openai && (
        <div className="mb-6 rounded-2xl border border-amber-200 bg-amber-50 p-5">
          <p className="font-black text-amber-800">Embeddings disabled</p>
          <p className="mt-2 text-sm text-amber-700">
            OPENAI_API_KEY is missing. Upload records can be created, but embedding generation will stay disabled.
          </p>
        </div>
      )}

      <div className="rounded-2xl border-2 border-dashed border-blue-200 bg-blue-50/40 p-12 text-center">
        <h2 className="text-3xl font-black">Upload company knowledge</h2>
        <p className="mt-4 text-neutral-500">PDF, DOCX, CSV, TXT and structured data.</p>
        <button className="mt-7 rounded-xl bg-black px-6 py-4 text-sm font-bold text-white">Upload Dataset</button>
      </div>

      <div className="mt-8 grid gap-4 md:grid-cols-3">
        {(datasets || []).map((d: any) => (
          <div key={d.id} className="rounded-2xl border border-neutral-200 bg-white p-6">
            <h2 className="text-2xl font-black">{d.title}</h2>
            <p className="mt-3 text-sm text-neutral-500">{d.status}</p>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
