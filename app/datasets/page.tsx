import AppShell from "@/components/layout/AppShell";

export default function DatasetsPage() {
  return (
    <AppShell>
      <section className="p-6 lg:p-10">
        <div className="rounded-[36px] bg-white p-10 shadow-sm">
          <h1 className="text-6xl font-black tracking-[-0.07em]">Datasets</h1>
          <p className="mt-5 max-w-2xl text-slate-500 leading-8">Upload files, build embeddings and create business memory for your agents.</p>

          <div className="mt-8 rounded-[32px] border-2 border-dashed border-blue-200 bg-blue-50/40 p-12 text-center">
            <h2 className="text-3xl font-black tracking-[-0.05em]">Upload company knowledge</h2>
            <p className="mt-4 text-slate-500">PDF, DOCX, CSV, TXT and structured data.</p>
            <button className="mt-7 rounded-full bg-slate-950 px-7 py-4 font-bold text-white">Upload Dataset</button>
          </div>
        </div>
      </section>
    </AppShell>
  );
}
