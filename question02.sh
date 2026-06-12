#!/bin/bash

clear

echo "============================================================="
echo "                 KILLERCODA - TASK (QUESTION 02)"
echo "============================================================="
echo

cat <<'QST'

Create a TLS Secret named bright-banyan in the bright-banyan namespace.

The Secret must be created using the following SSL files:

Certificate file: /root/tls/banyan.crt

Private key file: /root/tls/banyan.key

An existing Deployment named bright-banyan is already configured to reference this Secret.

QST

echo
echo "============================================================="
echo " Creating namespace, cert and key"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q02: Creating a TLS Secret
# Creates TLS files, namespace and Deployment
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="bright-banyan"
TLS_DIR="$HOME/tls"

echo ""
echo "==========================================="
echo " CKS Q02 — Setting up TLS Secret scenario..."
echo "==========================================="
echo ""

# ── Step 1: Reset only user-modified state ───────────────────
echo "[1/3] Cleaning up previous Q14 state..."

# TLS secret — user creates this as the solution
kubectl delete secret bright-banyan -n "$NAMESPACE" --ignore-not-found

# Force pod restart so it tries to mount missing secret → goes 0/1 Pending
kubectl rollout restart deployment bright-banyan \
    -n "$NAMESPACE" &>/dev/null || true

# TLS dir — always regenerate fresh cert/key
rm -rf "$TLS_DIR"

echo "  Previous state cleaned."

# ── Step 2: Generate TLS cert + key ──────────────────────────
echo "[2/3] Generating TLS certificate and key..."

mkdir -p "$TLS_DIR"

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$TLS_DIR/banyan.key" \
    -out "$TLS_DIR/banyan.crt" \
    -subj "/CN=web.k8s.local" 2>/dev/null

echo "  TLS files created:"
echo "  • $TLS_DIR/banyan.crt"
echo "  • $TLS_DIR/banyan.key"

# ── Step 3: Ensure namespace + Deployment exist ───────────────
echo "[3/3] Checking namespace and Deployment..."

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "  Namespace '$NAMESPACE' already exists — skipping."
else
    kubectl create namespace "$NAMESPACE"
    echo "  Namespace '$NAMESPACE' created."
fi

if kubectl get deployment bright-banyan -n "$NAMESPACE" &>/dev/null; then
    echo "  Deployment 'bright-banyan' already exists — skipping."
else
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bright-banyan
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bright-banyan
  template:
    metadata:
      labels:
        app: bright-banyan
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 443
        volumeMounts:
        - name: tls-cert
          mountPath: /etc/nginx/tls
          readOnly: true
      volumes:
      - name: tls-cert
        secret:
          secretName: bright-banyan
EOF
    echo "  Deployment bright-banyan created."
fi

echo "  (Pod stays Pending — secret does not exist yet) ✔"

echo ""
echo "✅ Q02 scenario is ready!"
echo ""
echo "Start the Solution!"
echo ""

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
