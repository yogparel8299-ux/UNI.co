#!/bin/bash
set -e

echo "Fixing Tailwind PostCSS setup for Vercel..."

cat > postcss.config.js <<'POSTCSS'
module.exports = {
  plugins: {
    "@tailwindcss/postcss": {}
  }
};
POSTCSS

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));

pkg.dependencies = pkg.dependencies || {};
pkg.devDependencies = pkg.devDependencies || {};

delete pkg.dependencies.tailwindcss;
pkg.devDependencies.tailwindcss = "^4.0.0";
pkg.devDependencies["@tailwindcss/postcss"] = "^4.0.0";
pkg.devDependencies.postcss = "latest";
pkg.devDependencies.autoprefixer = "latest";

fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
NODE

rm -rf node_modules package-lock.json .next
npm install
npm run build

git add package.json package-lock.json postcss.config.js
git commit -m "Fix Tailwind PostCSS config for Vercel" || true
git push origin main

echo "DONE. Now redeploy Vercel with build cache OFF."
