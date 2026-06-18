#!/bin/bash
# ============================================================
# CKS Practice | Q03: Dockerfile & Deployment Hardening
# Removes ~/cks directory
# Run on: controlplane node
# ============================================================

set -euo pipefail

echo ""
echo "==========================================="
echo " CKS Q03 — Restoring to baseline..."
echo "==========================================="
echo ""

echo "[1/1] Removing ~/cks directory..."

rm -rf "$HOME/cks"
echo "  $HOME/cks removed."

clear

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
