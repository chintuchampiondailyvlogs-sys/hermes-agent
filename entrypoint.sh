#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Configure Node memory & default port
export NODE_OPTIONS="--max-old-space-size=384"
PORT="${PORT:-10000}"

if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available."
fi

# 2. Start Hermes Agent in the background
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting Hermes Agent in background..."
    hermes gateway run > /app/hermes.log 2>&1 &
fi

# 3. Start OmniRoute in the FOREGROUND with supported CLI options
echo "[+] Starting OmniRoute AI Gateway on port ${PORT}..."
exec omniroute --port "$PORT" --no-open --no-tray
