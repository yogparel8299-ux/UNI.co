import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function OwnershipPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">Ownership Terms</h1>
        <p className="mt-6 text-slate-500 leading-8">
          Workspace access, generated systems, marketplace assets, exports and transfer rights depend on the active plan and applicable agreement. Enterprise customers may negotiate custom ownership and export terms.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
