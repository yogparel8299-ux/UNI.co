#!/bin/bash
set -e

echo "Checking Stitch HTML files..."

mkdir -p public/stitch

echo ""
echo "Files inside public/stitch:"
ls -la public/stitch || true

echo ""
echo "Checking required HTML files..."

REQUIRED=(
"landing"
"dashboard"
"login"
"signup"
"agents"
"workflow-studio"
"swarms"
"datasets"
"marketplace"
"billing"
"connection-layer"
"approvals"
"activity"
"settings"
)

for name in "${REQUIRED[@]}"; do
  if [ ! -f "public/stitch/$name.html" ]; then
    echo "MISSING: public/stitch/$name.html"
    cat > "public/stitch/$name.html" <<HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>UNIC.ai - $name missing</title>
  <style>
    body {
      margin:0;
      background:#031427;
      color:#d3e4fe;
      font-family:Inter,Arial,sans-serif;
      display:grid;
      place-items:center;
      min-height:100vh;
    }
    .box {
      border:1px solid #26364a;
      background:#0b1c30;
      padding:32px;
      max-width:720px;
    }
    h1 { color:#2fd9f4; }
    code { color:#c0c1ff; }
  </style>
</head>
<body>
  <div class="box">
    <h1>Missing Stitch HTML: $name</h1>
    <p>The Next.js route exists, but <code>public/stitch/$name.html</code> was not generated.</p>
    <p>Paste/export the Stitch HTML for this page and rerun the installer.</p>
  </div>
</body>
</html>
HTML
  else
    echo "OK: public/stitch/$name.html"
  fi
done

echo ""
echo "Recreating Next.js iframe routes..."

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
git commit -m "Fix Stitch iframe routes and missing html fallbacks" || true
git push origin main

echo ""
echo "DONE. Now redeploy Vercel."
