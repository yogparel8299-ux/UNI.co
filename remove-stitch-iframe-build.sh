#!/bin/bash
set -e

echo "Removing wrong Stitch iframe build..."

# Remove iframe static previews
rm -rf public/stitch

# Restore root landing route placeholder so app works normally again
cat > app/page.tsx <<'TSX'
import Link from "next/link";

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#031427] text-[#d3e4fe]">
      <section className="mx-auto flex min-h-screen max-w-7xl flex-col justify-center px-6">
        <p className="text-xs font-black uppercase tracking-[0.2em] text-[#2fd9f4]">
          UNIC.ai
        </p>
        <h1 className="mt-6 max-w-5xl text-7xl font-black tracking-[-0.06em]">
          Operating System for AI Companies
        </h1>
        <p className="mt-6 max-w-2xl text-lg text-[#c6c6cb]">
          Real Next.js rebuild is active. Stitch HTML iframe preview has been removed.
        </p>
        <div className="mt-10 flex gap-4">
          <Link href="/login" className="rounded bg-[#2fd9f4] px-6 py-3 font-black text-[#00363e]">
            Login
          </Link>
          <Link href="/dashboard" className="rounded border border-[#45474b] px-6 py-3 font-black">
            Dashboard
          </Link>
        </div>
      </section>
    </main>
  );
}
TSX

# Remove iframe wrappers that point to deleted public/stitch
for route in dashboard login signup agents workflow-studio swarms datasets marketplace billing connection-layer approvals activity settings tasks brain; do
  if grep -R "src=\"/stitch/" "app/$route/page.tsx" >/dev/null 2>&1; then
    echo "Removing iframe page app/$route/page.tsx"
    rm -f "app/$route/page.tsx"
  fi
done

npm run build

git add .
git commit -m "Remove wrong Stitch iframe build" || true
git push origin main

echo "DONE. Wrong iframe build removed."
