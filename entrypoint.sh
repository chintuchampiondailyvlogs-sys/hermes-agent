#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

export NODE_OPTIONS="--max-old-space-size=384"
PORT="${PORT:-7860}"

if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available."
fi

# 1. Start Hermes Agent in the background if available
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting Hermes Agent in background..."
    hermes gateway run > /app/hermes.log 2>&1 &
fi

# 2. Start OmniRoute in the FOREGROUND so Render binds the web port cleanly
echo "[+] Starting OmniRoute AI Gateway on port ${PORT}..."
exec env PORT=$PORT omniroute
