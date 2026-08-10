#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Confirm AWS CLI environment availability
if command -v aws &> /dev/null; then
    echo "[+] AWS CLI v2 is available."
fi

# 2. Start Hermes Gateway background service (Valid CLI choice)
echo "[+] Starting Hermes Gateway..."
if command -v hermes &> /dev/null; then
    hermes gateway &
else
    echo "[!] Hermes CLI not found in PATH, skipping..."
fi

# 3. Target port expected by Render
LISTEN_PORT="${PORT:-10000}"

echo "[+] Starting OmniRoute AI Gateway on port ${LISTEN_PORT}..."

# Exec ensures OmniRoute runs in foreground as PID 1
exec omniroute --port "${LISTEN_PORT}"
