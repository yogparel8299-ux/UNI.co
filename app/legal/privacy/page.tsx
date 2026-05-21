import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function PrivacyPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-4xl px-6 py-14">
        <h1 className="text-6xl font-black tracking-[-0.06em]">Privacy Policy</h1>
        <p className="mt-6 text-slate-500 leading-8">
          UNIC.ai is designed to protect workspace data, connected account credentials and user-generated business assets. Users control which providers, tools and connectors they authorize.
        </p>
      </section>
      <PublicFooter />
    </main>
  );
}
