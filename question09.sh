#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 09"
echo "============================================================="
echo

cat <<'QUESTION'

cat <<'EOF'
context
A security review found that a workload in the serviceaccount namespace is handling ServiceAccount tokens in a way that does not meet compliance requirements.

You must harden token usage for the existing monitoring components.

🎯 Tasks
Update the ServiceAccount monitor-sa in the serviceaccount namespace so that Kubernetes does not automatically mount API credentials into Pods using this ServiceAccount.

Update the Deployment monitor (in the same namespace) so that it still receives a ServiceAccount token, but only through an explicitly defined projected volume:

The projected volume must be named token

The token file must be mounted at:

/var/run/secrets/kubernetes.io/serviceaccount/token
The mount must be read-only

Reference manifest:

~/monitor/deployment.yaml
EOF

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo
#!/bin/bash
# ============================================================
# CKS Practice | Q09: Hardening ServiceAccount Token Usage
# Creates namespace, ServiceAccount and Deployment
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="serviceaccount"
MANIFEST_DIR="$HOME/monitor"
MANIFEST_FILE="$MANIFEST_DIR/deployment.yaml"

echo ""
echo "==========================================="
echo " CKS Q09 — Setting up ServiceAccount scenario..."
echo "==========================================="
echo ""

# ── Step 1: Reset only user-modified state ───────────────────
echo "[1/4] Cleaning up previous Q09 state..."

# Deployment — user modifies this (automountServiceAccountToken)
kubectl delete deployment monitor -n "$NAMESPACE" --ignore-not-found

# ServiceAccount — user modifies this (automountServiceAccountToken)
kubectl delete serviceaccount monitor-sa -n "$NAMESPACE" --ignore-not-found

# Manifest dir — always restore to original non-hardened version
rm -rf "$MANIFEST_DIR"

echo "  Previous state cleaned."

# ── Step 2: Ensure namespace exists ──────────────────────────
echo "[2/4] Checking namespace..."

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "  Namespace '$NAMESPACE' already exists — skipping."
else
    kubectl create namespace "$NAMESPACE"
    echo "  Namespace '$NAMESPACE' created."
fi

# ── Step 3: Create ServiceAccount ────────────────────────────
echo "[3/4] Creating ServiceAccount monitor-sa..."

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitor-sa
  namespace: $NAMESPACE
EOF

echo "  ServiceAccount monitor-sa created (automount: default true)."

# ── Step 4: Create manifest + apply Deployment ───────────────
echo "[4/4] Creating deployment manifest and applying..."

mkdir -p "$MANIFEST_DIR"

cat > "$MANIFEST_FILE" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitor
  namespace: serviceaccount
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitor
  template:
    metadata:
      labels:
        app: monitor
    spec:
      serviceAccountName: monitor-sa
      containers:
      - name: monitor
        image: nginx
        ports:
        - containerPort: 80
EOF

kubectl apply -f "$MANIFEST_FILE"

echo "  Waiting for deployment to be Ready..."
kubectl wait --for=condition=available deployment/monitor \
    -n "$NAMESPACE" --timeout=120s

echo ""
echo "✅ Q09 scenario is ready!"
echo ""
echo "Start the Solution!"
echo ""

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
