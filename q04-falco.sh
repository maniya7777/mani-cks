#!/bin/bash
# ============================================================
# CKS Practice | Q05: Detecting a Pod Accessing /dev/mem
# setup_problem_scenario.sh
# Deploys neuron workloads and installs Falco
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="neuron"
FALCO_RULES_LOCAL="/etc/falco/falco_rules.local.yaml"

echo ""
echo "==========================================="
echo " CKS Q05 — Setting up /dev/mem scenario..."
echo "==========================================="
echo ""

# ── Step 1: Reset only deployments + Falco rules ─────────────
echo "[1/4] Cleaning up previous deployments and Falco rules..."

for APP in facebook instagram tinder; do
    kubectl delete deployment "$APP" -n "$NAMESPACE" --ignore-not-found
done

if [ -f "$FALCO_RULES_LOCAL" ]; then
    sudo truncate -s 0 "$FALCO_RULES_LOCAL"
    echo "  Falco local rules cleared."
fi

echo "  Previous state cleaned."

# ── Step 2: Install Falco (skip if already installed) ────────
echo "[2/4] Checking Falco installation..."

if command -v falco &>/dev/null; then
    echo "  Falco already installed — skipping."
else
    echo "  Installing Falco..."

    sudo apt-get update -qq
    sudo apt-get install -y curl gnupg2 apt-transport-https -qq

    curl -fsSL https://falco.org/repo/falcosecurity-packages.asc \
        | sudo gpg --dearmor \
        -o /usr/share/keyrings/falco-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] \
https://download.falco.org/packages/deb stable main" \
        | sudo tee /etc/apt/sources.list.d/falcosecurity.list > /dev/null

    sudo apt-get update -qq
    sudo apt-get install -y falco

    echo "  Falco installed successfully."
fi

# Stop Falco system service — user runs it manually in foreground
sudo systemctl stop falco 2>/dev/null || true
sudo systemctl disable falco 2>/dev/null || true
echo "  Falco system service stopped (user runs it manually)."

# Ensure local rules file exists and is empty
sudo touch "$FALCO_RULES_LOCAL"
sudo truncate -s 0 "$FALCO_RULES_LOCAL"
echo "  Falco local rules file ready (empty): $FALCO_RULES_LOCAL"

# ── Step 3: Ensure namespace exists + deploy workloads ───────
echo "[3/4] Ensuring namespace and deploying workloads..."

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "  Namespace '$NAMESPACE' already exists — skipping recreate."
else
    kubectl create namespace "$NAMESPACE"
    echo "  Namespace '$NAMESPACE' created."
fi

for APP in facebook instagram tinder; do
    case "$APP" in
        facebook)  IMAGE="devopstechtales/cks-exam-questions:falco-eg-v1" ;;
        instagram) IMAGE="devopstechtales/cks-exam-questions:falco-eg-v2" ;;
        tinder)    IMAGE="devopstechtales/cks-exam-questions:falco-eg-v3" ;;
    esac

    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $APP
  template:
    metadata:
      labels:
        app: $APP
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      nodeSelector:
        node-role.kubernetes.io/control-plane: ""
      containers:
      - name: $APP
        image: $IMAGE
EOF

done

echo "  Waiting for pods to be Running on controlplane..."
kubectl wait --for=condition=available deployment/facebook \
    -n "$NAMESPACE" --timeout=120s
kubectl wait --for=condition=available deployment/instagram \
    -n "$NAMESPACE" --timeout=120s
kubectl wait --for=condition=available deployment/tinder \
    -n "$NAMESPACE" --timeout=120s

# ── Step 4: Verify scenario state ────────────────────────────
echo "[4/4] Verifying scenario state..."
kubectl get pods -n "$NAMESPACE"

echo ""
echo "✅ Q05 scenario is ready!"
echo ""
echo "Start the solution!"
echo ""
