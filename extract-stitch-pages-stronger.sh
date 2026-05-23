#!/bin/bash
set -e

echo "Extracting Stitch pages with stronger marker detection..."

mkdir -p public/stitch

python3 <<'PY'
from pathlib import Path
import re

candidates = [
    "Pasted text(22).txt",
    "Pasted text (2)(5).txt",
    "Pasted text.txt",
    "Pasted text (2).txt"
]

files = [p for p in candidates if Path(p).exists()]
if not files:
    raise SystemExit("No pasted Stitch text files found in repo root.")

route_by_marker = {
    "Landing Page": "landing",
    "Activity Log": "activity",
    "Datasets": "datasets",
    "Workflow Studio": "workflow-studio",
    "Login": "login",
    "Signup": "signup",
    "Agents": "agents",
    "Swarms": "swarms",
    "Approvals": "approvals",
    "Billing": "billing",
    "Marketplace": "marketplace",
    "Settings": "settings",
    "Integrations": "connection-layer",
    "Connection": "connection-layer",
    "Dashboard": "dashboard",
    "Tasks": "tasks",
}

route_by_title = {
    "The Operating System for AI Companies": "landing",
    "Operational Audit Feed": "activity",
    "Knowledge Ingestion OS": "datasets",
    "AI Orchestration": "workflow-studio",
    "Initialize Session": "login",
    "Join the Workforce": "signup",
    "AI Workforce": "agents",
    "Swarm Orchestration": "swarms",
    "Approval Control": "approvals",
    "Enterprise Billing": "billing",
    "Asset Marketplace": "marketplace",
    "Workspace Configuration": "settings",
    "Central Runtime Hub": "connection-layer",
    "Operational OS": "dashboard",
    "Mission Control": "tasks",
}

created = {}

for file in files:
    text = Path(file).read_text(errors="ignore")

    # Split on every UNIC marker comment.
    parts = re.split(r'(?=<!--\s*.*?UNIC\.ai\s*-->)', text, flags=re.I|re.S)

    for part in parts:
        if "<!DOCTYPE html>" not in part:
            continue

        # Keep from doctype only.
        part = part[part.find("<!DOCTYPE html>"):]

        # Stop before next page marker if accidentally included.
        next_marker = re.search(r'\n<!--\s*.*?UNIC\.ai\s*-->\s*\n<!DOCTYPE html>', part[20:], flags=re.I|re.S)
        if next_marker:
            part = part[:20 + next_marker.start()]

        title_match = re.search(r"<title>(.*?)</title>", part, flags=re.I|re.S)
        title = title_match.group(1).strip() if title_match else ""

        marker_match = re.search(r'<!--\s*(.*?)\s*-->', text[max(0, text.find(part)-200):text.find(part)+50], flags=re.I|re.S)
        marker = marker_match.group(1).strip() if marker_match else ""

        route = None

        for key, value in route_by_marker.items():
            if key.lower() in marker.lower():
                route = value
                break

        if not route:
            for key, value in route_by_title.items():
                if key.lower() in title.lower() or key.lower() in part[:5000].lower():
                    route = value
                    break

        if not route:
            safe = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-") or "unknown"
            route = safe

        # Fix dead links.
        part = part.replace('href="#"', 'href="/dashboard"')
        part = part.replace('href="/#"', 'href="/dashboard"')

        Path(f"public/stitch/{route}.html").write_text(part)
        created[route] = title

print("Created HTML files:")
for route, title in sorted(created.items()):
    print(f"{route}.html <= {title}")
PY

echo ""
echo "Current public/stitch:"
ls -la public/stitch

echo ""
echo "Rebuilding app routes..."

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

create_route dashboard dashboard
create_route login login
create_route signup signup
create_route agents agents
create_route workflow-studio workflow-studio
create_route swarms swarms
create_route datasets datasets
create_route marketplace marketplace
create_route billing billing
create_route connection-layer connection-layer
create_route approvals approvals
create_route activity activity
create_route settings settings
create_route tasks tasks

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
git commit -m "Extract and install Stitch HTML pages correctly" || true
git push origin main

echo "DONE. Redeploy Vercel."
