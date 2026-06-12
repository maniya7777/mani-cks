#!/bin/bash
# ============================================================
# CKS Practice | Q04: Restricted Pod Security Standard (PSA)
# reset_to_baseline.sh
# Removes restricted namespace and all Q04 resources
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="restricted"

echo ""
echo "==========================================="
echo " CKS Q04 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete namespace (removes deployment + pods) ─────
echo "[1/2] Deleting namespace '$NAMESPACE'..."

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Namespace and all resources removed."

# ── Step 2: Remove manifest files ────────────────────────────
echo "[2/2] Removing nginx-deployment.yaml..."

sudo rm -f $HOME/nginx-deployment.yaml
echo "  Manifest files removed."

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
