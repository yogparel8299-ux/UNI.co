#!/bin/bash
set -e

apt update && apt upgrade -y
apt install -y nodejs npm git curl
npm install -g pm2

npm install

pm2 start workers/runtime-worker.js --name unic-runtime-worker
pm2 save
pm2 startup

echo "UNIC.ai worker deployed on DigitalOcean."
