#!/bin/bash
# ============================================================
# CKS Practice | Q03: Istio mTLS Enforcement
# reset_to_baseline.sh
# Removes all Q03 changes including Istio uninstall
# Run on: controlplane node
# ============================================================

set -euo pipefail

ISTIO_NAMESPACE="istio-system"
APP_NAMESPACE="istio-example"
ISTIO_INSTALL_DIR="/tmp/cks-q03-istio"

echo ""
echo "==========================================="
echo " CKS Q03 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Remove user-applied solution resources ───────────
echo "[1/4] Removing solution resources (if applied)..."

kubectl delete peerauthentication default \
    -n "$APP_NAMESPACE" --ignore-not-found
kubectl label namespace "$APP_NAMESPACE" \
    istio-injection- --ignore-not-found 2>/dev/null || true
echo "  PeerAuthentication and namespace label removed."

# ── Step 2: Delete application namespace ─────────────────────
echo "[2/4] Deleting $APP_NAMESPACE namespace..."

kubectl delete namespace "$APP_NAMESPACE" --ignore-not-found
echo "  Namespace deleted."

# ── Step 3: Uninstall Istio ───────────────────────────────────
echo "[3/4] Uninstalling Istio..."

if [ -d "$ISTIO_INSTALL_DIR" ]; then
    ISTIO_DIR=$(ls -d "$ISTIO_INSTALL_DIR"/istio-* 2>/dev/null | head -n 1)
    if [ -n "$ISTIO_DIR" ] && [ -f "$ISTIO_DIR/bin/istioctl" ]; then
        export PATH="$ISTIO_DIR/bin:$PATH"
        istioctl uninstall --purge -y
        echo "  Istio uninstalled via istioctl."
    else
        echo "  istioctl not found in $ISTIO_INSTALL_DIR — attempting kubectl cleanup..."
        kubectl delete namespace "$ISTIO_NAMESPACE" --ignore-not-found
    fi
else
    echo "  Istio install dir not found — attempting kubectl cleanup..."
    kubectl delete namespace "$ISTIO_NAMESPACE" --ignore-not-found
fi

# Remove Istio CRDs
kubectl get crd | grep istio.io | awk '{print $1}' | \
    xargs kubectl delete crd --ignore-not-found 2>/dev/null || true

kubectl delete namespace "$ISTIO_NAMESPACE" --ignore-not-found


# Cleanup temp files
rm -rf "$ISTIO_INSTALL_DIR"
rm -rf $HOME/*.yml
rm -rf $HOME/*.yaml
echo "  Istio CRDs and temp files cleaned."

# ── Step 4: Restart kubelet ───────────────────────────────────
echo "[4/4] Restarting kubelet..."
sudo systemctl daemon-reload
sudo systemctl restart kubelet
echo "  kubelet restarted."

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
