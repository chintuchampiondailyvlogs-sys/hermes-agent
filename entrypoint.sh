#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Cap Node.js RAM usage to 384MB so it never breaches Render's 512MB limit
export NODE_OPTIONS="--max-old-space-size=384"

# 2. Assign dynamic port from Render
PORT="${PORT:-7860}"

if command -v aws >/dev/null 2>&1; then
    echo "[+] AWS CLI v2 is available."
fi

# 3. Execution logic without file logging / tailing
if command -v hermes >/dev/null 2>&1; then
    echo "[+] Starting OmniRoute in background..."
    PORT=$PORT omniroute &
    sleep 3
    
    echo "[+] Starting Hermes Agent..."
    exec hermes gateway run
else
    echo "[!] Hermes executable not found in PATH."
    echo "[+] Launching OmniRoute in foreground..."
    
    # Executing directly in foreground eliminates log-file RAM bloat
    exec env PORT=$PORT omniroute
fi
