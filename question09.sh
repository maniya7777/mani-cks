#!/bin/bash

cat <<'QUESTION'
=============================================================
              KILLERCODA - QUESTION 09
=============================================================

context
A security review found that a workload in the serviceaccount namespace is handling ServiceAccount tokens in a way that does not meet compliance requirements.

You must harden token usage for the existing monitoring components.

🎯 Tasks
Update the ServiceAccount monitor-sa in the serviceaccount namespace so that Kubernetes does not automatically mount API credentials into Pods using this ServiceAccount.

Update the Deployment monitor (in the same namespace) so that it still receives a ServiceAccount token, but only through an explicitly defined projected volume:

- The projected volume must be named token
- The token file must be mounted at:
  /var/run/secrets/kubernetes.io/serviceaccount/token
- The mount must be read-only

Reference manifest:
~/monitor/deployment.yaml
=============================================================
QUESTION

echo ""
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo ""

set -euo pipefail

NAMESPACE="serviceaccount"
MANIFEST_DIR="$HOME/monitor"
MANIFEST_FILE="$MANIFEST_DIR/deployment.yaml"

echo "[1/4] Cleaning previous state..."

kubectl delete deployment monitor -n "$NAMESPACE" --ignore-not-found
kubectl delete serviceaccount monitor-sa -n "$NAMESPACE" --ignore-not-found
rm -rf "$MANIFEST_DIR"

echo "[2/4] Ensuring namespace exists..."
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo "[3/4] Creating ServiceAccount..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitor-sa
  namespace: $NAMESPACE
automountServiceAccountToken: false
EOF

echo "[4/4] Creating Deployment manifest..."

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
      automountServiceAccountToken: false
      containers:
      - name: monitor
        image: nginx
        volumeMounts:
        - name: token
          mountPath: /var/run/secrets/kubernetes.io/serviceaccount/token
          readOnly: true
      volumes:
      - name: token
        projected:
          sources:
          - serviceAccountToken:
              path: token
              expirationSeconds: 3600
EOF

kubectl apply -f "$MANIFEST_FILE"

echo "Waiting for deployment..."
kubectl rollout status deployment/monitor -n "$NAMESPACE"

echo "✅ Q09 setup completed!"
