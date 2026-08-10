#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Force network host binding to 0.0.0.0 so Render detects the open port
export HOST="0.0.0.0"
export OMNIROUTE_HOST="0.0.0.0"

# 2. Node memory & default port setup
export NODE_OPTIONS="--max-old-space-size=384"
PORT="${PORT:-10000}"

if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available."
fi

# 3. Start Hermes Agent in the background
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting Hermes Agent in background..."
    hermes gateway run > /app/hermes.log 2>&1 &
fi

# 4. Start OmniRoute in FOREGROUND bound to 0.0.0.0
echo "[+] Starting OmniRoute AI Gateway on 0.0.0.0:${PORT}..."
exec env HOST=0.0.0.0 OMNIROUTE_HOST=0.0.0.0 omniroute --port "$PORT" --no-open --no-tray
