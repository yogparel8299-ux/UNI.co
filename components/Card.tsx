export default function Card({
  title,
  value,
  note
}: {
  title: string;
  value: any;
  note?: string;
}) {
  return (
    <div className="glass-card metric">
      <p className="metric-label">{title}</p>
      <h2 className="metric-value">{value}</h2>
      {note && <p className="text-gray-500 text-sm mt-3">{note}</p>}
    </div>
  );
}
