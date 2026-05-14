#!/bin/bash

echo "===== UNIC.ai Codespaces Verification ====="

check_file() {
  if [ -f "$1" ]; then
    echo "✅ FILE: $1"
  else
    echo "❌ MISSING FILE: $1"
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo "✅ DIR:  $1"
  else
    echo "❌ MISSING DIR:  $1"
  fi
}

echo ""
echo "== Core files =="
check_file "package.json"
check_file "next.config.js"
check_file "tsconfig.json"
check_file "tailwind.config.js"
check_file "postcss.config.js"
check_file ".gitignore"
check_file ".env.example"
check_file "README.md"

echo ""
echo "== App folders =="
for dir in \
app/dashboard \
app/command \
app/companies \
app/agents \
app/swarms \
app/tasks \
app/datasets \
app/dataset-lab \
app/marketplace \
app/marketplace-explore \
app/marketplace-seller \
app/billing \
app/billing-center \
app/connection-layer \
app/mcp-gateway \
app/workflow-studio \
app/brain \
app/brain-search \
app/rag \
app/triggers \
app/realtime \
app/realtime-stream \
app/swarm-visualizer \
app/live-runtime \
app/admin-console \
app/admin/security \
app/notifications \
app/usage-dashboard \
app/worker-health \
app/secret-manager \
app/vault \
app/router \
app/connectors \
app/onboarding \
app/final-onboarding \
app/auth \
app/login \
app/signup \
app/settings; do
  check_dir "$dir"
done

echo ""
echo "== API routes =="
for dir in \
app/api/command \
app/api/queue \
app/api/onboarding \
app/api/save-secret \
app/api/router-run \
app/api/connector-connect \
app/api/composio-link \
app/api/tool-execute \
app/api/trigger-event \
app/api/embed-text \
app/api/rag-search \
app/api/dataset-upload \
app/api/dataset-ingest \
app/api/dataset-search \
app/api/stripe-checkout \
app/api/stripe-webhook \
app/api/razorpay-order \
app/api/razorpay-webhook \
app/api/marketplace-buy \
app/api/marketplace-publish \
app/api/marketplace-rent \
app/api/marketplace-review \
app/api/buy-credits \
app/api/team-accept \
app/api/workflow-run \
app/api/swarm-run \
app/api/audit-log \
app/api/rate-limit-check \
app/api/command-save \
app/api/company-settings \
app/api/workflow-template-use \
app/api/brain-query \
app/api/connection-link \
app/api/connection-callback \
app/api/connection-tools \
app/api/connection-tool-call \
app/api/connection-sync \
app/api/mcp/tools \
app/api/mcp/call \
app/api/enforce-limit \
app/api/notify \
app/api/stream-event \
app/api/secret-list \
app/api/secret-delete \
app/api/worker-heartbeat; do
  check_dir "$dir"
done

check_dir "app/skills"
check_dir "app/api/create-skill"
check_dir "app/api/assign-skill"
check_dir "app/api/remove-agent-skill"
check_dir "app/api/run-skill"
check_file "components/skills/SkillAssignmentPanel.tsx"
check_file "lib/skills/run-skill.ts"

echo ""
echo "== Important components/libs/workers =="
check_file "components/Nav.tsx"
check_file "components/Shell.tsx"
check_file "components/Card.tsx"
check_file "components/DataTable.tsx"
check_file "components/CommandCenter.tsx"
check_file "components/workflow/VisualWorkflowEditor.tsx"

check_file "lib/supabase-admin.ts"
check_file "lib/supabase-browser.ts"
check_file "lib/command-planner.ts"
check_file "lib/crypto.ts"
check_file "lib/models/model-router.ts"
check_file "lib/connection/composio.ts"
check_file "lib/datasets/chunk.ts"
check_file "lib/datasets/embed.ts"
check_file "lib/limits/enforce.ts"
check_file "lib/rate-limit/check.ts"
check_file "lib/realtime/stream.ts"

check_file "workers/runtime-worker.js"
check_file "workers/super-worker.js"
check_file "workers/connection-sync-worker.js"
check_file "workers/launch-worker.js"
check_file "workers/all-workers.js"

echo ""
echo "== Package scripts =="
node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const scripts = pkg.scripts || {};
const required = ["dev", "build", "start", "worker", "super-worker", "connection-worker", "launch-worker", "all-workers"];
for (const s of required) {
  if (scripts[s]) console.log(`✅ SCRIPT: ${s} = ${scripts[s]}`);
  else console.log(`❌ MISSING SCRIPT: ${s}`);
}
NODE

echo ""
echo "== Git ignore safety =="
if grep -q "node_modules/" .gitignore; then echo "✅ node_modules ignored"; else echo "❌ node_modules NOT ignored"; fi
if grep -q ".next/" .gitignore; then echo "✅ .next ignored"; else echo "❌ .next NOT ignored"; fi
if grep -q ".env" .gitignore; then echo "✅ .env ignored"; else echo "❌ .env NOT ignored"; fi

echo ""
echo "== Type/build check =="
npm run build

echo ""
echo "===== Verification complete ====="
