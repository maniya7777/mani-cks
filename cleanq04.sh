#!/bin/bash
# ============================================================
# CKS Practice | Q04: Detecting a Pod Accessing /dev/mem
# reset_to_baseline.sh
# Removes neuron namespace and fully uninstalls Falco
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="neuron"

echo ""
echo "==========================================="
echo " CKS Q04 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete neuron namespace ──────────────────────────
echo "[1/3] Deleting namespace '$NAMESPACE'..."

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Namespace and all workloads removed."

# ── Step 2: Stop Falco service ────────────────────────────────
echo "[2/3] Stopping and uninstalling Falco..."

sudo systemctl stop falco 2>/dev/null || true
sudo systemctl disable falco 2>/dev/null || true

# Uninstall Falco package
sudo apt-get purge -y falco 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Remove Falco repo and keyring
sudo rm -f /etc/apt/sources.list.d/falcosecurity.list
sudo rm -f /usr/share/keyrings/falco-archive-keyring.gpg

# Remove Falco config directory
sudo rm -rf /etc/falco

sudo apt-get update -qq
echo "  Falco fully uninstalled."

# ── Step 3: Verify Falco removed ─────────────────────────────
echo "[3/3] Verifying Falco removal..."

if command -v falco &>/dev/null; then
    echo "  ⚠ WARNING: falco binary still found — may need manual cleanup."
else
    echo "  ✔ Falco binary not found — clean."
fi

clear

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
