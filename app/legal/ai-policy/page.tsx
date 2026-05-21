import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function AiPolicyPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">AI Use Policy</h1>
        <p className="mt-6 text-slate-500 leading-8">
          UNIC.ai is built for productive business automation. Users are responsible for configuring approvals, reviewing outputs and complying with laws and third-party platform terms.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
