#!/bin/bash
# ============================================================
# CKS Practice | Q09: Network Policy
# Removes production + database namespaces and all Q09 resources
# Run on: controlplane node
# ============================================================

set -euo pipefail

echo ""
echo "==========================================="
echo " CKS Q09 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete namespaces (removes NPs + all resources) ──
echo "[1/1] Deleting production and database namespaces..."

kubectl delete namespace production --ignore-not-found
kubectl delete namespace database --ignore-not-found
echo "  Namespaces and all resources removed."

echo ""
echo "✅ Cluster is back to baseline!"
echo "   Safe to move to next problem. 🚀"
echo ""
