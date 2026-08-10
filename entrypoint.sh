#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# -------------------------------------------------------------------
# 1. Environment & Dynamic Port Handling
# -------------------------------------------------------------------
# Render passes dynamic PORT (e.g. 10000). Default to 7860 if local.
PORT="${PORT:-7860}"

# Verify AWS CLI v2 Availability
if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available:"
    aws --version
    
    # Optional Cloudflare R2 Sync (Uncomment when credentials are set)
    # if [ -n "$R2_BUCKET_NAME" ]; then
    #     echo "[+] Syncing state from Cloudflare R2..."
    #     aws s3 sync "s3://${R2_BUCKET_NAME}/data" /app/data --endpoint-url "$R2_ENDPOINT_URL"
    # fi
else
    echo "[!] Warning: AWS CLI not found."
fi

# -------------------------------------------------------------------
# 2. Start OmniRoute AI Gateway in Background
# -------------------------------------------------------------------
echo "[+] Starting OmniRoute AI Gateway on port ${PORT}..."

if command -v omniroute >/dev/null 2>&1; then
    PORT=$PORT omniroute > /app/omniroute.log 2>&1 &
else
    PORT=$PORT npx omniroute > /app/omniroute.log 2>&1 &
fi

OMNI_PID=$!
echo "[+] OmniRoute started with PID: ${OMNI_PID}"

# Allow OmniRoute to initialize
sleep 3

# -------------------------------------------------------------------
# 3. Start Hermes Agent or Maintain Primary Process
# -------------------------------------------------------------------
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting Hermes Agent..."
    exec hermes gateway run
else
    echo "[!] Hermes executable not found in PATH."
    echo "[+] Keeping OmniRoute active as primary process..."
    
    # Keep container alive by streaming OmniRoute logs
    tail -f /app/omniroute.log
fi
