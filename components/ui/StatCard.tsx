export default function StatCard({
  title,
  value,
  subtitle
}: {
  title: string;
  value: string;
  subtitle?: string;
}) {
  return (
    <div className="rounded-[30px] border border-slate-200 bg-white p-7 shadow-[0_20px_80px_rgba(15,23,42,.05)]">
      <p className="text-sm font-bold text-slate-500">
        {title}
      </p>

      <p className="mt-3 text-5xl font-black tracking-[-0.06em]">
        {value}
      </p>

      {subtitle && (
        <p className="mt-3 text-sm text-slate-500">
          {subtitle}
        </p>
      )}
    </div>
  );
}
