#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# Set Node.js memory limits and binding interface
export NODE_OPTIONS="--max-old-space-size=384"
export HOST="0.0.0.0"
export PORT="${PORT:-10000}"

if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available."
fi

# 1. Start Hermes Agent in background (if present)
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting Hermes Agent in background..."
    hermes gateway run > /app/hermes.log 2>&1 &
fi

# 2. Start OmniRoute in FOREGROUND bound explicitly to 0.0.0.0
echo "[+] Starting OmniRoute AI Gateway on ${HOST}:${PORT}..."
exec omniroute --host 0.0.0.0 --port "$PORT"
