#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Download & Install AWS CLI for Cloudflare R2 syncing
apt-get update && apt-get install -y awscli curl unzip python3-pip npm nodejs

# 2. Configure AWS CLI for Cloudflare R2
aws configure set aws_access_key_id "$R2_ACCESS_KEY"
aws configure set aws_secret_access_key "$R2_SECRET_KEY"
aws configure set default.region us-east-1

# 3. Pull Hermes Agent Memory from Cloudflare R2 onto startup
mkdir -p /root/.hermes
echo "=== Pulling Hermes memory from R2 Storage ==="
aws s3 sync "s3://$R2_BUCKET/hermes-memory" /root/.hermes/ --endpoint-url "$R2_ENDPOINT" || echo "First boot: No existing memory found in bucket."

# 4. Background Sync Task (Syncs Hermes memory back to Cloudflare R2 every 10 mins)
(
  while true; do
    sleep 600
    echo "=== Auto-syncing Hermes memory to Cloudflare R2 ==="
    aws s3 sync /root/.hermes/ "s3://$R2_BUCKET/hermes-memory" --endpoint-url "$R2_ENDPOINT"
  done
) &

# 5. Launch OmniRoute AI Gateway in background
echo "=== Launching OmniRoute Service ==="
npx omniroute --port 20128 &

# Wait for OmniRoute engine to initialize
sleep 5

# 6. Install and Start Hermes Agent with Telegram Gateway
echo "=== Launching Hermes Agent Service ==="
pip3 install hermes-agent

hermes config set open_ai_base_url "http://127.0.0.1:20128/v1"
hermes gateway telegram --token "$TELEGRAM_BOT_TOKEN" --allowed-users "$TELEGRAM_ALLOWED_USERS"
