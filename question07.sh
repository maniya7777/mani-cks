#!/bin/bash

# ============================================================
# CKS Practice | Q07: Network Policy
# Creates production + database namespaces with labels
# Run on: controlplane node
# ============================================================

set -euo pipefail

echo ""
echo "==========================================="
echo " CKS Q07 — Setting up Network Policy scenario..."
echo "==========================================="
echo ""

# ── Step 1: Clean previous Q07 state ─────────────────────────
echo "[1/3] Cleaning up any previous Q07 state..."

kubectl delete networkpolicy deny-policy \
    -n production --ignore-not-found
kubectl delete networkpolicy allow-from-production \
    -n database --ignore-not-found

echo "  Previous NetworkPolicies cleaned."

# ── Step 2: Verify CNI is running (supports NetworkPolicy) ───
echo "[2/3] Checking CNI..."

if kubectl get pods -n kube-system --no-headers 2>/dev/null \
        | grep -Ei "calico|cilium|weave|flannel" \
        | grep -q Running; then
    CNI=$(kubectl get pods -n kube-system --no-headers 2>/dev/null \
        | grep -Ei "calico|cilium|weave|flannel" \
        | grep Running | head -1 | awk '{print $1}')
    echo "  CNI already running ($CNI) — skipping install. ✔"
else
    echo "  ⚠ WARNING: No CNI detected in kube-system."
    echo "  NetworkPolicy enforcement may not work."
    echo "  Please ensure a CNI is installed before proceeding."
fi

# ── Step 3: Create namespaces with labels ────────────────────
echo "[3/3] Creating namespaces..."

# production namespace
if kubectl get namespace production &>/dev/null; then
    echo "  production namespace already exists — ensuring label..."
else
    kubectl create namespace production
    echo "  production namespace created."
fi
kubectl label namespace production env=production --overwrite
echo "  production → label env=production ✔"

# database namespace
if kubectl get namespace database &>/dev/null; then
    echo "  database namespace already exists — ensuring label..."
else
    kubectl create namespace database
    echo "  database namespace created."
fi
kubectl label namespace database env=database --overwrite
echo "  database → label env=database ✔"

clear

echo "========================================"
echo "CKS NetworkPolicy Question"
echo "========================================"
echo
echo "Context"
echo "In the production namespace, create a NetworkPolicy named deny-policy that blocks all incoming traffic to Pods by default."
echo "The production namespace has the label:"
echo "env: production"
echo "In the database namespace, create a NetworkPolicy named allow-from-production that permits ingress traffic only from Pods running in the production namespace."
echo "Use the namespace label to allow traffic."
echo "The database namespace has the label:"
echo "env: database"

echo ""
echo "✅ Q07 scenario is ready!"
echo ""
echo "Start the Solution!"
echo ""
echo
echo "========================================"
echo "Environment Ready"
echo "========================================"
