#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# -------------------------------------------------------------------
# 1. Environment & Default Configuration
# -------------------------------------------------------------------
# Default to port 7860 if PORT is not set by Render/Hosting provider
PORT="${PORT:-7860}"

# Optional Cloudflare R2 / AWS CLI Sync Check
if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available:"
    aws --version
    
    # Optional: Put your R2 sync command here if needed:
    # if [ -n "$R2_BUCKET_NAME" ]; then
    #     echo "[+] Syncing state from Cloudflare R2..."
    #     aws s3 sync "s3://${R2_BUCKET_NAME}/data" /app/data --endpoint-url "$R2_ENDPOINT_URL"
    # fi
else
    echo "[!] Warning: AWS CLI not found, skipping storage sync."
fi

# -------------------------------------------------------------------
# 2. Start OmniRoute Gateway (Background)
# -------------------------------------------------------------------
echo "[+] Starting OmniRoute AI Gateway on port ${PORT}..."

# OmniRoute can be started via global CLI or npx
if command -v omniroute >/dev/null 2>&1; then
    PORT=$PORT omniroute > /app/omniroute.log 2>&1 &
else
    PORT=$PORT npx omniroute > /app/omniroute.log 2>&1 &
fi

OMNI_PID=$!
echo "[+] OmniRoute started with PID: ${OMNI_PID}"

# Give OmniRoute a moment to initialize
sleep 3

# -------------------------------------------------------------------
# 3. Start Hermes Agent or Main Execution Process
# -------------------------------------------------------------------
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting Hermes Agent..."
    exec hermes gateway run
else
    echo "[!] Hermes executable not found in PATH."
    echo "[+] Keeping OmniRoute active as primary process..."
    
    # Tail OmniRoute logs to keep the container running in the foreground
    tail -f /app/omniroute.log
fi
