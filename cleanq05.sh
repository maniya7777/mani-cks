#!/bin/bash
# ============================================================
# CKS Practice | Q05: Container Security Context Hardening
# Removes sec-ns namespace and manifest files
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="sec-ns"
MANIFEST_FILE="sec-ns_deployment.yaml"

echo ""
echo "==========================================="
echo " CKS Q05 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete namespace ──────────────────────────────────
echo "[1/2] Deleting namespace '$NAMESPACE'..."

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Namespace and all resources removed."

# ── Step 2: Remove manifest files ────────────────────────────
echo "[2/2] Removing manifest files..."


rm -f "$HOME/$MANIFEST_FILE"
echo "  Manifest files removed."

clear

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
