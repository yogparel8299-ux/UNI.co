import PublicNav from "@/components/marketing/PublicNav";
import PublicFooter from "@/components/marketing/PublicFooter";

export default function ContactPage() {
  return (
    <main className="page-shell">
      <PublicNav />
      <section className="mx-auto max-w-5xl px-6 py-14">
        <h1 className="page-title">Contact</h1>
        <p className="page-subtitle mt-6">Talk to the UNIC.ai team about product access, enterprise deployments and partnerships.</p>

        <div className="glass-card mt-12 p-8">
          <input className="input-box" placeholder="Work email" />
          <input className="input-box mt-4" placeholder="Company" />
          <textarea className="input-box mt-4 min-h-[160px]" placeholder="How can we help?" />
          <button className="primary-button mt-6">Send request</button>
        </div>
      </section>
      <PublicFooter />
    </main>
  );
}
