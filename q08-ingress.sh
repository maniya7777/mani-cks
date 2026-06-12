#!/bin/bash
# ============================================================
# CKS Practice | Q10: Ingress with HTTPS
# Installs ingress-nginx, enables Cilium ingress controller,
# deploys web app, creates TLS secret
# Run on: controlplane node
# ============================================================

set -euo pipefail

NAMESPACE="production"
HOSTNAME="web.k8s.local"
TLS_DIR="$HOME/tls"

echo ""
echo "==========================================="
echo " CKS Q10 — Setting up Ingress HTTPS scenario..."
echo "==========================================="
echo ""

# ── Step 1: Clean only user-modified state ───────────────────
echo "[1/7] Cleaning up previous Q10 state..."
kubectl delete ingress web-ingress -n "$NAMESPACE" --ignore-not-found
kubectl delete secret web-ingress-tls -n "$NAMESPACE" --ignore-not-found
rm -f "$HOME"/*.yaml "$HOME"/*.yml
rm -rf "$TLS_DIR"
echo "  Previous state cleaned."

# ── Step 2: Install ingress-nginx ────────────────────────────
echo "[2/7] Checking ingress-nginx..."

if kubectl get namespace ingress-nginx &>/dev/null && \
   kubectl get pods -n ingress-nginx \
       -l app.kubernetes.io/component=controller \
       --no-headers 2>/dev/null | grep -q Running; then
    echo "  ingress-nginx already running — skipping install."
else
    echo "  Installing ingress-nginx..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.0/deploy/static/provider/cloud/deploy.yaml

    kubectl patch svc ingress-nginx-controller \
        -n ingress-nginx \
        -p '{"spec": {"type": "NodePort"}}'

    kubectl patch svc ingress-nginx-controller \
        -n ingress-nginx \
        -p '{"spec": {"ports": [{"port": 443, "targetPort": 443, "nodePort": 32000, "protocol": "TCP", "name": "https"}]}}'

    kubectl wait --for=condition=ready pod \
        -l app.kubernetes.io/component=controller \
        -n ingress-nginx --timeout=180s
    echo "  ingress-nginx ready on NodePort 32000."
fi

# ── Step 3: Enable Cilium Ingress Controller ─────────────────
echo "[3/7] Checking Cilium ingress controller..."

if kubectl get ingressclass cilium &>/dev/null; then
    echo "  Cilium IngressClass already exists — skipping."
else
    echo "  Enabling Cilium ingress controller..."

    if ! helm repo list 2>/dev/null | grep -q cilium; then
        helm repo add cilium https://helm.cilium.io/
        helm repo update
    fi

    helm get values cilium -n kube-system > /tmp/cilium-values.yaml
    helm uninstall cilium -n kube-system
    sleep 30
    helm install cilium cilium/cilium \
        --namespace kube-system \
        --values /tmp/cilium-values.yaml \
        --set ingressController.enabled=true \
        --set ingressController.enforceHttps=false \
        --set ingressController.loadbalancerMode=shared


    kubectl -n kube-system rollout restart deployment/cilium-operator
    kubectl -n kube-system rollout status ds/cilium --timeout=120s
    echo "  Cilium ingress controller enabled."
fi

# ── Step 4: Patch Cilium ingress svc to NodePort 32001 ───────
echo "[4/7] Patching cilium-ingress service to NodePort 32001..."

# Wait for cilium-ingress svc to appear
for i in $(seq 1 20); do
    if kubectl get svc cilium-ingress -n kube-system &>/dev/null; then
        break
    fi
    echo "  Waiting for cilium-ingress svc... ($i/20)"
    sleep 5
done

kubectl patch svc cilium-ingress \
    -n kube-system \
    -p '{"spec": {"type": "NodePort"}}'

kubectl patch svc cilium-ingress \
    -n kube-system \
    -p '{"spec": {"ports": [{"port": 443, "targetPort": 443, "nodePort": 32001, "protocol": "TCP", "name": "https"},{"port": 80, "targetPort": 80, "nodePort": 32002, "protocol": "TCP", "name": "http"}]}}'

echo "  cilium-ingress patched to NodePort 32001 (HTTPS)."

# ── Step 5: Add /etc/hosts entry ─────────────────────────────
echo "[5/7] Checking /etc/hosts entry..."
NODE_IP=$(kubectl get nodes \
    --selector='node-role.kubernetes.io/control-plane' \
    -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

if grep -q "$HOSTNAME" /etc/hosts; then
    echo "  /etc/hosts entry already present — skipping."
else
    echo "$NODE_IP $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
    echo "  Added: $NODE_IP $HOSTNAME"
fi

# ── Step 6: Deploy namespace + app ───────────────────────────
echo "[6/7] Ensuring namespace and web app are deployed..."

if kubectl get deployment web-deployment -n "$NAMESPACE" &>/dev/null; then
    echo "  web-deployment already exists — skipping."
else
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: $NAMESPACE
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
EOF
    kubectl wait --for=condition=available deployment/web-deployment \
        -n "$NAMESPACE" --timeout=120s
    echo "  web-deployment is Ready."
fi

# ── Step 7: Generate TLS cert + create secret ────────────────
echo "[7/7] Generating TLS certificate and creating secret..."
mkdir -p "$TLS_DIR"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$TLS_DIR/web.k8s.local.key" \
    -out "$TLS_DIR/web.k8s.local.crt" \
    -subj "/CN=$HOSTNAME" 2>/dev/null

kubectl -n "$NAMESPACE" create secret tls web-ingress-tls \
    --cert="$TLS_DIR/web.k8s.local.crt" \
    --key="$TLS_DIR/web.k8s.local.key"
echo "  TLS secret web-ingress-tls created."

# ── Verify ───────────────────────────────────────────────────
echo ""
kubectl get svc,deploy -n "$NAMESPACE"
echo ""
kubectl get secret web-ingress-tls -n "$NAMESPACE"
echo ""
kubectl get ingressclass

echo ""
echo "✅ Q10 scenario is ready!"
echo ""
echo "  NGINX  → curl -Lk https://web.k8s.local:32000"
echo "  Cilium → curl -Lk https://web.k8s.local:32001"
echo ""
echo "Start the Solution!"
echo ""
