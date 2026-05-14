#!/bin/bash
set -e

apt update && apt upgrade -y
apt install -y nodejs npm git curl
npm install -g pm2

npm install

pm2 start workers/production-worker.js --name unic-production-worker
pm2 start workers/connection-sync-worker.js --name unic-connection-worker
pm2 start workers/super-worker.js --name unic-super-worker
pm2 start workers/launch-worker.js --name unic-launch-worker

pm2 save
pm2 startup

echo "UNIC.ai production workers are running."
