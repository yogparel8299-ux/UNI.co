#!/bin/bash
set -e

echo "Checking required env example..."
cat .env.example

echo "Checking files..."
test -f lib/supabase-admin.ts
test -f lib/models/real-router.ts
test -f workers/production-worker.js
test -f scripts/digitalocean-production-workers.sh
test -f components/workflow/VisualWorkflowEditor.tsx

echo "Checking build..."
npm run build

echo "UNIC.ai final verification passed."
