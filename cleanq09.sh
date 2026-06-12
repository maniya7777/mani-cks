#!/bin/bash
# ============================================================
# CKS Practice | Q09: Hardening ServiceAccount Token Usage
# Removes namespace and manifest files
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="serviceaccount"

echo ""
echo "==========================================="
echo " CKS Q09 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete namespace ──────────────────────────────────
echo "[1/2] Deleting namespace '$NAMESPACE'..."

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Namespace and all resources removed."

# ── Step 2: Remove manifest directory ────────────────────────
echo "[2/2] Removing $HOME/monitor directory..."


sudo rm -rf $HOME/monitor
echo "  $HOME/monitor directory removed."

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
