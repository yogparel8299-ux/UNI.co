import Nav from "@/components/Nav";

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
    <main className="page-shell min-h-screen">
      <Nav />
      <section className="px-6 py-8 lg:ml-[280px] lg:px-10">
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-5xl md:text-7xl font-black tracking-[-0.07em]">{title}</h1>
            {subtitle && <p className="page-subtitle mt-4">{subtitle}</p>}
          </div>
          <a href="/signup" className="primary-button hidden md:inline-flex">get started</a>
        </div>
        {children}
      </section>
    </main>
  );
}
