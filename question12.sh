#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 12"
echo "============================================================="
echo

cat <<'QUESTION'

A Kubernetes cluster is configured to enforce the Restricted Pod Security Standard across all user namespaces.

In the restricted namespace, an existing Deployment is not meeting the required Restricted security rules. 
Because of this, its Pods are being rejected and cannot be scheduled or started.

The Deployment manifest file is available at:

~/nginx-deployment.yaml
🎯 Task
Update the Deployment in the restricted namespace so that it fully complies with the Restricted Pod Security Standard.
After applying the required security settings, verify that the Pods are created and running successfully.

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q12: Restricted Pod Security Standard (PSA)
# setup_problem_scenario.sh
# Creates restricted namespace + non-compliant deployment
# Run on: controlplane node
# ============================================================
set -euo pipefail

NAMESPACE="restricted"
MANIFEST_FILE="$HOME/nginx-deployment.yaml"

MANIFEST_CONTENT='apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-unprivileged
  namespace: restricted
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 80'

echo ""
echo "==========================================="
echo " CKS Q12 — Setting up PSA scenario..."
echo "==========================================="
echo ""

# ── Step 1: Reset deployment and manifest (always) ───────────
echo "[1/4] Cleaning up previous deployment and manifest..."

kubectl delete deployment nginx-unprivileged -n "$NAMESPACE" --ignore-not-found
rm -f "$MANIFEST_FILE"

echo "  Deployment and manifest cleared."

# ── Step 2: Ensure namespace exists with correct PSA label ───
echo "[2/4] Checking namespace..."

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "  Namespace '$NAMESPACE' already exists — skipping recreate."

    # Ensure PSA label is present (in case user removed it as part of solution)
    CURRENT_LABEL=$(kubectl get ns "$NAMESPACE" \
        -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)

    if [ "$CURRENT_LABEL" != "restricted" ]; then
        echo "  PSA label missing or changed — re-applying..."
        kubectl label namespace "$NAMESPACE" \
            pod-security.kubernetes.io/enforce=restricted --overwrite
    else
        echo "  PSA label enforce=restricted already set ✔"
    fi
else
    echo "  Creating namespace '$NAMESPACE' with enforce=restricted..."
    kubectl create namespace "$NAMESPACE"
    kubectl label namespace "$NAMESPACE" \
        pod-security.kubernetes.io/enforce=restricted
fi

echo "  Namespace labels:"
kubectl get ns "$NAMESPACE" --show-labels

# ── Step 3: Create non-compliant deployment manifest ─────────
echo "[3/4] Creating non-compliant nginx-deployment.yaml..."

cat > "$MANIFEST_FILE" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-unprivileged
  namespace: restricted
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 80
EOF

echo "  nginx-deployment.yaml created at $MANIFEST_FILE"

# ── Step 4: Apply deployment (pods will be rejected by PSA) ──
echo "[4/4] Applying non-compliant deployment..."

kubectl apply -f "$MANIFEST_FILE"

sleep 5

POD_COUNT=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
EVENTS=$(kubectl get events -n "$NAMESPACE" \
    --sort-by=.lastTimestamp 2>/dev/null | tail -3)

echo ""
if [ "$POD_COUNT" -eq 0 ]; then
    echo "  ✔ No pods running — PSA is correctly blocking them."
else
    echo "  ⚠ WARNING: $POD_COUNT pod(s) running — PSA may not be enforcing."
fi

echo ""
echo "  Recent events:"
echo "$EVENTS"
echo ""
echo "✅ Q12 scenario is ready!"
echo ""
echo "  Start The Solution!"
echo ""
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
