#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Multi-Container Stack ==="

# 1. Confirm AWS CLI environment availability
if command -v aws &> /dev/null; then
    echo "[+] AWS CLI v2 is available."
fi

# 2. Start Hermes Agent background service
echo "[+] Starting Hermes Agent in background..."
python3 -m hermes_agent &

# 3. Resolve target port dynamically (Render default is usually 10000)
LISTEN_PORT="${PORT:-10000}"

echo "[+] Starting OmniRoute AI Gateway on 0.0.0.0:${LISTEN_PORT}..."

# Exec replaces shell process so signals and port bindings register instantly with Render
exec omniroute --host 0.0.0.0 --port "${LISTEN_PORT}"
