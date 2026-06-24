#!/bin/bash

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

# ============================================================
# CKS Practice | Q11: BOM Tool (SBOM / SPDX)
# setup_problem_scenario.sh
# Deploys sbom workload with 3 containers + installs bom
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="sbom"
MANIFEST_PATH="$HOME/sbom-deployment.yaml"

echo ""
echo "==========================================="
echo " CKS Q11 — Setting up BOM Tool scenario..."
echo "==========================================="
echo ""

# ── Step 1: Reset only deployment + user-generated files ─────
echo "[1/4] Cleaning up previous deployment and report files..."

kubectl delete deployment sbom -n "$NAMESPACE" --ignore-not-found
rm -f "$HOME/report.spdx" "$MANIFEST_PATH"

echo "  Previous state cleaned."

# ── Step 2: Install bom (skip if already installed) ───────────
echo "[2/4] Checking bom installation..."

if command -v bom &>/dev/null; then
    echo "  bom already installed — skipping."
else
    echo "  Installing bom..."
    curl -L https://github.com/kubernetes-sigs/bom/releases/latest/download/bom-amd64-linux \
        -o /tmp/bom
    chmod +x /tmp/bom
    sudo mv /tmp/bom /usr/local/bin/bom
    echo "  bom installed: $(bom version)"
fi

# ── Step 3: Ensure namespace exists + deploy workload ─────────
echo "[3/4] Ensuring namespace and deploying sbom workload..."

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "  Namespace '$NAMESPACE' already exists — skipping recreate."
else
    kubectl create namespace "$NAMESPACE"
    echo "  Namespace '$NAMESPACE' created."
fi

cat > "$MANIFEST_PATH" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbom
  namespace: sbom
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sbom
  template:
    metadata:
      labels:
        app: sbom
    spec:
      containers:
      - name: container-1
        image: devopstechtales/cks-exam-questions:sbom-test-v1
        command: ["sleep", "3600"]
      - name: container-2
        image: devopstechtales/cks-exam-questions:sbom-test-v2
        command: ["sleep", "3600"]
      - name: container-3
        image: devopstechtales/cks-exam-questions:sbom-test-v3
        command: ["sleep", "3600"]
EOF

kubectl apply -f "$MANIFEST_PATH"

echo "  Waiting for pod to be Running..."
kubectl wait --for=condition=available deployment/sbom \
    -n "$NAMESPACE" --timeout=120s

# ── Step 4: Verify ────────────────────────────────────────────
echo "[4/4] Verifying scenario state..."
kubectl get pods -n "$NAMESPACE"
echo "  Manifest saved at: $MANIFEST_PATH"


clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 11"
echo "============================================================="
echo

cat <<'QUESTION'

There is a Deployment named sbom running in the sbom namespace.

This Deployment contains three containers, and each container uses a different image version.

Your task is to inspect the container images and identify which container includes the package:

libcrypto3 version 3.1.4-r5
After identifying the correct image version:

Use the pre-installed bom utility to generate an SPDX (Software Bill of Materials) report and save it as:

~/report.spdx
Update the sbom Deployment so that the container using the identified image version is removed.

The Deployment manifest file is located at:

~/sbom-deployment.yaml

QUESTION


echo ""
echo "✅ Q11 scenario is ready!"
echo ""
echo "Start the solution!"
echo ""

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
