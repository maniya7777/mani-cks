#!/bin/bash
# ============================================================
# CKS Practice | Q14: Creating a TLS Secret
# Removes namespace and TLS files
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="bright-banyan"
TLS_DIR="$HOME/tls"

echo ""
echo "==========================================="
echo " CKS Q14 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete namespace ──────────────────────────────────
echo "[1/2] Deleting namespace '$NAMESPACE'..."

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Namespace and all resources removed."

# ── Step 2: Remove TLS files ──────────────────────────────────
echo "[2/2] Removing TLS files..."

rm -rf "$TLS_DIR"
echo "  $TLS_DIR removed."

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
