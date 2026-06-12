#!/bin/bash
# ============================================================
# CKS Practice | Q06: BOM Tool (SBOM / SPDX)
# reset_to_baseline.sh
# Removes sbom namespace, manifest files and bom binary
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="sbom"

echo ""
echo "==========================================="
echo " CKS Q06 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete sbom namespace ────────────────────────────
echo "[1/3] Deleting namespace '$NAMESPACE'..."

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Namespace and all resources removed."

# ── Step 2: Remove manifest and report files ─────────────────
echo "[2/3] Removing manifest and report files..."

sudo rm -f $HOME/sbom-deployment.yaml
sudo rm -f $HOME/report.spdx
echo "  Files removed."

# ── Step 3: Remove bom binary ────────────────────────────────
echo "[3/3] Removing bom binary..."

if command -v bom &>/dev/null; then
    sudo rm -f /usr/local/bin/bom
    echo "  bom binary removed."
else
    echo "  bom not found — skipping."
fi

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
