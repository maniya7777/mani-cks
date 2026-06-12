#!/bin/bash
# ============================================================
# CKS Practice | Q08: Ingress with HTTPS
# Full reset — removes all Q10 resources
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="production"
HOSTNAME="web.k8s.local"
TLS_DIR="$HOME/tls"

echo ""
echo "==========================================="
echo " CKS Q08 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

echo "[1/4] Deleting production namespace..."
kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "  Done."

echo "[2/4] Removing /etc/hosts entry..."
sudo sed -i "/$HOSTNAME/d" /etc/hosts
echo "  Done."

echo "[3/4] Removing TLS files..."
rm -rf "$TLS_DIR"
rm -f "$HOME"/*.yaml "$HOME"/*.yml
echo "  Done."

echo "[4/4] Uninstalling ingress-nginx..."
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.0/deploy/static/provider/cloud/deploy.yaml \
    --ignore-not-found 2>/dev/null || true
kubectl delete namespace ingress-nginx --ignore-not-found
echo "  Done."

# NOTE: Cilium ingress is not disabled here to avoid disrupting the CNI.
# The setup script handles idempotent re-enablement on next run.

echo ""
echo "✅ Cluster is back to baseline!"
echo "   Safe to move to next problem. 🚀"
echo ""
