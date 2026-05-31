#!/bin/bash

set -e

# Install Falco silently
helm repo add falcosecurity https://falcosecurity.github.io/charts >/dev/null 2>&1
helm repo update >/dev/null 2>&1

kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1

helm upgrade --install falco falcosecurity/falco \
  -n falco >/dev/null 2>&1

kubectl rollout status daemonset/falco -n falco --timeout=180s >/dev/null 2>&1

sleep 15

# Create namespace silently
kubectl create namespace security-lab --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1

# Deploy normal application
cat <<EOF | kubectl apply -f - >/dev/null 2>&1
...
EOF

# Deploy misbehaving application
cat <<EOF | kubectl apply -f - >/dev/null 2>&1
...
EOF

sleep 20

clear

cat <<'EOF'
=============================================================
                         QUESTION
=============================================================

A misbehaving Pod poses a security threat to the system.

Task
A Pod belonging to the ollama application is abnormal — it is directly
accessing system memory by reading from the sensitive file /dev/mem.

First, identify the misbehaving Pod accessing /dev/mem.
Next, scale the Deployment of the misbehaving Pod to zero replicas.

=============================================================
EOF
