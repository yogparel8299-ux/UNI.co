#!/bin/bash
set -e

echo "Removing unused UNIC.ai routes..."

REMOVE_ROUTES=(
"admin-analytics"
"admin-console"
"admin/security"
"about"
"auth"
"billing-center"
"brain-search"
"command"
"connectors"
"contact"
"dataset-lab"
"final-onboarding"
"integrations"
"legal/ownership"
"marketplace-explore"
"marketplace-seller"
"mcp-gateway"
"models"
"notifications-center"
"ownership"
"packs"
"rag"
"realtime"
"realtime-live"
"realtime-stream"
"rollback-center"
"router"
"seller-dashboard"
"swarm-visualizer"
"triggers"
"usage-dashboard"
"vault"
)

for route in "${REMOVE_ROUTES[@]}"; do
  if [ -d "app/$route" ]; then
    echo "Deleting app/$route"
    rm -rf "app/$route"
  else
    echo "Skipping app/$route (not found)"
  fi
done

echo ""
echo "Cleaning imports and cache..."

rm -rf .next

echo ""
echo "Remaining routes:"
find app -name page.tsx | sort

echo ""
echo "Running build verification..."

npm run build

echo ""
echo "Git committing cleanup..."

git add .
git commit -m "Remove unused legacy routes and pages" || true
git push origin main

echo ""
echo "DONE"
