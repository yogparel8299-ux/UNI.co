import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function RefundPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">Refund Policy</h1>
        <p className="mt-6 text-slate-500 leading-8">
          Subscription and credit-pack refunds are reviewed according to usage, billing history and applicable plan terms. Enterprise agreements may include separate commercial terms.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
