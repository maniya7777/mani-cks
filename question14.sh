#!/bin/bash

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q14: Istio mTLS Enforcement
# setup_problem_scenario.sh
# Installs Istio and deploys workloads without mTLS config
# Run on: controlplane node
# ============================================================

set -euo pipefail

ISTIO_NAMESPACE="istio-system"
APP_NAMESPACE="istio-example"

echo ""
echo "==========================================="
echo " CKS Q14 — Setting up Istio mTLS scenario..."
echo "==========================================="
echo ""

# ── Step 1: Tear down any previous Q14 state ─────────────────
echo "[1/5] Cleaning up any previous Q14 state..."

# Remove PeerAuthentication if user applied it previously
kubectl delete peerauthentication default -n "$APP_NAMESPACE" &>/dev/null || true
kubectl label namespace "$APP_NAMESPACE" istio-injection- &>/dev/null || true
kubectl rollout restart deploy -n "$APP_NAMESPACE" &>/dev/null || true

# Delete previous peer auth yaml files
rm -rf $HOME/*.yml
rm -rf $HOME/*.yaml

echo "  Previous state cleaned."

# ── Step 2: Install Istio (skip if already installed) ────────
echo "[2/5] Checking Istio installation..."

if kubectl get namespace "$ISTIO_NAMESPACE" &>/dev/null && \
   kubectl get pods -n "$ISTIO_NAMESPACE" --field-selector=status.phase=Running 2>/dev/null | grep -q istiod; then
    echo "  Istio already installed and running — skipping install."
else
    echo "  Installing Istio..."
    ISTIO_INSTALL_DIR="/tmp/cks-q03-istio"
    mkdir -p "$ISTIO_INSTALL_DIR"
    cd "$ISTIO_INSTALL_DIR"

    curl -L https://istio.io/downloadIstio | sh -

    # Find the downloaded istio directory
    ISTIO_DIR=$(ls -d istio-* | head -n 1)
    export PATH="$ISTIO_INSTALL_DIR/$ISTIO_DIR/bin:$PATH"

    istioctl install --set profile=demo -y

    echo "  Waiting for Istio control plane to be Ready..."
    kubectl wait --for=condition=ready pod \
        -l app=istiod -n "$ISTIO_NAMESPACE" --timeout=180s

    echo "  Istio installed successfully."
fi

# ── Step 3: Create namespace WITHOUT istio-injection label ────

if kubectl get deployment instagram -n "$APP_NAMESPACE" &>/dev/null; then
    echo "  Namespace and app already exist — skipping."
else
    echo "[3/5] Creating namespace $APP_NAMESPACE (no sidecar injection)..."

    kubectl create namespace "$APP_NAMESPACE"

    # Verify label is NOT present
    echo "  Namespace labels:"
    kubectl get ns "$APP_NAMESPACE" --show-labels | grep -v "istio-injection" && \
        echo "  ✔ istio-injection label is absent (as expected)" || true
    echo "  Namespace created."

    # ── Step 4: Deploy workloads (no sidecars at this point) ─────
    echo "[4/5] Deploying sample workloads..."

    kubectl create deployment instagram \
        -n "$APP_NAMESPACE" \
        --image=devopstechtales/cks-exam-questions:istio-v1

    kubectl create deployment tinder \
        -n "$APP_NAMESPACE" \
        --image=devopstechtales/cks-exam-questions:istio-v2

    echo "  Waiting for pods to be Running..."
    kubectl wait --for=condition=available deployment/instagram \
        -n "$APP_NAMESPACE" --timeout=120s
    kubectl wait --for=condition=available deployment/tinder \
        -n "$APP_NAMESPACE" --timeout=120s

fi

# ── Step 5: Verify no sidecar injected ───────────────────────
echo "[5/5] Verifying scenario state..."

CONTAINERS=$(kubectl get pods -n "$APP_NAMESPACE" \
    -o jsonpath='{.items[*].spec.containers[*].name}')

if echo "$CONTAINERS" | grep -q "istio-proxy"; then
    echo "  ⚠ WARNING: istio-proxy sidecar detected — scenario may not be clean."
else
    echo "  ✔ No istio-proxy sidecar present (as expected)."
fi


clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 14"
echo "============================================================="
echo

cat <<'QUESTION'

A microservices application is running in the Kubernetes cluster. Currently, service-to-service communication within the application uses unencrypted Layer 4 (TCP) traffic.

Istio has already been installed in the cluster to help secure internal communication using mutual TLS (mTLS).

The workloads are deployed inside the istio-example namespace, but secure communication is not yet fully enforced.

🎯 Task
To secure all Layer 4 traffic, complete the following:

Ensure every Pod running in the istio-example namespace has the Istio sidecar proxy (istio-proxy) injected.
Configure mutual TLS authentication in STRICT mode for all workloads inside the istio-example namespace.

QUESTION

echo ""
echo "✅ Q14 scenario is ready!"
echo ""
echo "   Now Start Solution! 💪"
echo ""

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
