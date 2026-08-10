#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Confirm AWS CLI environment availability
if command -v aws &> /dev/null; then
    echo "[+] AWS CLI v2 is available."
fi

# 2. Start Hermes Agent background service safely
echo "[+] Starting Hermes Agent..."
if command -v hermes &> /dev/null; then
    hermes start &
elif command -v hermes-agent &> /dev/null; then
    hermes-agent &
else
    echo "[!] Hermes CLI entrypoint not found in PATH, skipping..."
fi

# 3. Target port (Render defaults to 10000 via $PORT)
LISTEN_PORT="${PORT:-10000}"

echo "[+] Starting OmniRoute AI Gateway on port ${LISTEN_PORT}..."

# Exec without invalid '--host' option
exec omniroute --port "${LISTEN_PORT}"
