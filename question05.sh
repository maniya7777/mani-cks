#!/bin/bash

echo
echo "============================================================="
echo " Creating Environment Setup"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q05: Container Security Context Hardening
# Creates sec-ns namespace + insecure Deployment + manifest
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="sec-ns"
MANIFEST_FILE="$HOME/sec-ns_deployment.yaml"

echo ""
echo "==========================================="
echo " CKS Q05 — Setting up Security Context scenario..."
echo "==========================================="
echo ""

# ── Step 1: Reset only user-modified state ───────────────────
echo "[1/3] Cleaning up previous Q05 state..."

# Deployment — user adds securityContext fields to this
kubectl delete deployment secdep -n "$NAMESPACE" --ignore-not-found

# Manifest — user edits this file directly
rm -f "$MANIFEST_FILE"

echo "  Previous state cleaned."

# ── Step 2: Ensure namespace exists ──────────────────────────
echo "[2/3] Checking namespace..."

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "  Namespace '$NAMESPACE' already exists — skipping."
else
    kubectl create namespace "$NAMESPACE"
    echo "  Namespace '$NAMESPACE' created."
fi

# ── Step 3: Create manifest + apply Deployment ───────────────
echo "[3/3] Creating manifest and deploying..."

cat > "$MANIFEST_FILE" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secdep
  namespace: sec-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secdep
  template:
    metadata:
      labels:
        app: secdep
    spec:
      containers:
      - name: nginx
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 80
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /var/cache/nginx
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
EOF

kubectl apply -f "$MANIFEST_FILE"

echo "  Waiting for Deployment to be Ready..."
kubectl wait --for=condition=available deployment/secdep \
    -n "$NAMESPACE" --timeout=120s

echo ""
echo "✅ Q05 scenario is ready!"
echo ""
echo "Start the Solution!"
echo ""
echo


clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 05"
echo "============================================================="
echo

cat <<'QUESTION'

A Kubernetes Deployment is running with insecure container settings.

Your objective is to harden the containers by enforcing immutability and reducing privilege-related risks.

An existing Deployment named secdep is deployed in the sec-ns namespace.

You have been provided with the manifest file: ~/sec-ns_deployment.yaml

Task
Update the Deployment so that all containers:

Run as a non-root user with UID 32000
Use a read-only root filesystem
Disallow privilege escalation

QUESTION

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
