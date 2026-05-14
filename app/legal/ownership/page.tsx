import { supabaseAdmin } from "@/lib/supabase-admin";

export default async function OwnershipTerms() {
  const { data } = await supabaseAdmin.from("legal_terms").select("*").eq("slug", "ownership").single();

  return (
    <main className="min-h-screen bg-white p-10">
      <h1 className="text-5xl font-black tracking-[-0.05em]">{data?.title || "Ownership Terms"}</h1>
      <p className="text-gray-600 mt-8 max-w-3xl leading-8 whitespace-pre-wrap">{data?.content}</p>
    </main>
  );
}
