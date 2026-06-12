#!/bin/bash
# ============================================================
# CKS Practice | Q13: Securing the Docker Daemon
# Removes Docker completely — restores node01 to baseline
# ============================================================

set -euo pipefail

echo ""
echo "==========================================="
echo " CKS Q13 — Restoring node01 to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Stop Docker ───────────────────────────────────────
echo "[1/3] Stopping Docker..."

sudo systemctl stop docker docker.socket 2>/dev/null || true
sudo systemctl disable docker 2>/dev/null || true
echo "  Docker stopped and disabled."

# ── Step 2: Remove Docker packages ───────────────────────────
echo "[2/3] Removing Docker..."

sudo apt-get purge -y -qq \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
sudo apt-get autoremove -y -qq 2>/dev/null || true

# Remove Docker repo + keyring
sudo rm -f /etc/apt/sources.list.d/docker.sources
sudo rm -f /etc/apt/keyrings/docker.asc
sudo apt-get update -qq

echo "  Docker removed."

# ── Step 3: Remove developer user ────────────────────────────
echo "[3/3] Removing developer user..."

if id developer &>/dev/null; then
    sudo userdel developer 2>/dev/null || true
    echo "  developer user removed."
else
    echo "  developer user not found — skipping."
fi

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
