#!/bin/bash
set -e

echo "=== Starting Hermes & OmniRoute Stack ==="

# 1. Start Hermes Gateway in background
echo "[+] Starting Hermes Gateway..."
if command -v hermes &> /dev/null; then
    hermes gateway &
else
    echo "[!] Hermes CLI not found, skipping..."
fi

# 2. Get target port (Render default: 10000)
LISTEN_PORT="${PORT:-10000}"

echo "[+] Starting OmniRoute AI Gateway on port ${LISTEN_PORT}..."

# Exec replaces shell process and runs OmniRoute with constrained memory
exec omniroute --port "${LISTEN_PORT}"
