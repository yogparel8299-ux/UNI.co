#!/bin/bash
set -e

mkdir -p public/stitch

FILE1="Pasted text(22).txt"
FILE2="Pasted text (2)(5).txt"

if [ ! -f "$FILE1" ] || [ ! -f "$FILE2" ]; then
  echo "ERROR: Missing Stitch text files."
  echo "Required files:"
  echo "$FILE1"
  echo "$FILE2"
  exit 1
fi

python3 <<'PY'
from pathlib import Path
import re, html

files = ["Pasted text(22).txt", "Pasted text (2)(5).txt"]

route_map = {
    "Operational Audit Feed": "activity",
    "Knowledge Ingestion OS": "datasets",
    "Mission Control": "tasks",
    "Integrations": "connection-layer",
    "Runtime Hub": "connection-layer",
    "Asset Marketplace": "marketplace",
    "Billing": "billing",
    "Memory": "brain",
    "Configuration": "settings",
    "Operational OS": "dashboard",
    "Operating System for AI Companies": "landing",
    "AI Orchestration": "workflow-studio",
    "Join the Workforce": "signup",
    "Initialize Session": "login",
    "AI Workforce": "agents",
    "Active Swarms": "swarms",
    "Approval Control": "approvals",
}

out = Path("public/stitch")
out.mkdir(parents=True, exist_ok=True)

created = {}

for file in files:
    text = Path(file).read_text(errors="ignore")
    docs = re.split(r'(?=<!-- .*?\| UNIC\.ai -->)', text)

    for doc in docs:
        if "<!DOCTYPE html>" not in doc:
            continue

        title = re.search(r"<title>(.*?)</title>", doc, re.I | re.S)
        title_text = html.unescape(title.group(1)).replace("UNIC.ai |", "").replace("UNIC.ai Studio |", "").replace("UNIC.ai -", "").strip() if title else "page"

        route = None
        for key, val in route_map.items():
            if key.lower() in title_text.lower() or key.lower() in doc[:3000].lower():
                route = val
                break

        if not route:
            route = re.sub(r"[^a-z0-9]+", "-", title_text.lower()).strip("-")

        doc = doc.replace('href="#"', 'href="/dashboard"')
        doc = doc.replace('href="/#"', 'href="/dashboard"')

        Path(out / f"{route}.html").write_text(doc)
        created[route] = title_text

print("Created pages:")
for route, title in sorted(created.items()):
    print(route, "=>", title)
PY

create_route () {
  ROUTE="$1"
  HTML="$2"
  mkdir -p "app/$ROUTE"
  cat > "app/$ROUTE/page.tsx" <<TSX
export default function Page() {
  return (
    <iframe
      src="/stitch/$HTML.html"
      className="h-screen w-full border-0"
      style={{ background: "#031427" }}
    />
  );
}
TSX
}

create_route activity activity
create_route datasets datasets
create_route tasks tasks
create_route connection-layer connection-layer
create_route marketplace marketplace
create_route billing billing
create_route brain brain
create_route settings settings
create_route dashboard dashboard
create_route workflow-studio workflow-studio
create_route signup signup
create_route login login
create_route agents agents
create_route swarms swarms
create_route approvals approvals

cat > app/page.tsx <<'TSX'
export default function Page() {
  return (
    <iframe
      src="/stitch/landing.html"
      className="h-screen w-full border-0"
      style={{ background: "#031427" }}
    />
  );
}
TSX

npm run build
git add .
git commit -m "Install exact Stitch HTML pages"
git push origin main

echo "DONE"
