export default function DataTable({ rows }: { rows: any[] }) {
  if (!rows?.length) {
    return (
      <div className="glass-card p-10 text-gray-500">
        No records yet. Create records using the AI Command Center or Supabase.
      </div>
    );
  }

  const keys = Object.keys(rows[0]).slice(0, 6);

  return (
    <div className="glass-card overflow-hidden">
      <table className="table">
        <thead>
          <tr>
            {keys.map((k) => (
              <th key={k}>{k}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={row.id || i}>
              {keys.map((k) => (
                <td key={k}>
                  {typeof row[k] === "object"
                    ? JSON.stringify(row[k]).slice(0, 80)
                    : String(row[k] ?? "").slice(0, 80)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
