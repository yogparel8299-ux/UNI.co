import Nav from "./Nav";

export default function Shell({
  title,
  subtitle,
  children
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  return (
    <main className="page-shell">
      <Nav />
      <section className="main">
        <div className="flex items-center justify-between gap-8 mb-10">
          <div>
            <h1 className="page-title">{title}</h1>
            <p className="page-subtitle">
              {subtitle || "Live UNIC.ai command center powered by Supabase, workers and AI runtime infrastructure."}
            </p>
          </div>
          <button className="primary-button">
            Create
          </button>
        </div>
        {children}
      </section>
    </main>
  );
}
