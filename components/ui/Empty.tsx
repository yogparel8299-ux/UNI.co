import Link from "next/link";

export default function Empty({
  title,
  text,
  action,
  href
}: {
  title: string;
  text: string;
  action?: string;
  href?: string;
}) {
  return (
    <div className="rounded-[32px] border border-slate-200 bg-white p-14 text-center shadow-[0_20px_80px_rgba(15,23,42,.05)]">
      <div className="mx-auto mb-7 h-20 w-20 rounded-full bg-blue-50" />

      <h2 className="text-4xl font-black tracking-[-0.05em]">
        {title}
      </h2>

      <p className="mx-auto mt-5 max-w-2xl text-slate-500 leading-8">
        {text}
      </p>

      {action && href && (
        <Link
          href={href}
          className="mt-8 inline-flex rounded-full bg-[#111827] px-7 py-4 text-sm font-bold text-white"
        >
          {action}
        </Link>
      )}
    </div>
  );
}
