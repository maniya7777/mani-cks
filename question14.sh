#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 14"
echo "============================================================="
echo

cat <<'QUESTION'

Context
You must secure a microservices-based application using unencrypted Layer 4 (L4) transport with Istio.

Task
Perform the following tasks to secure Layer 4 (L4) transport communication for the existing application using Istio.

Istio is already installed to secure Layer 4 (L4) communication.

You can access Istio's documentation using a browser.

First, ensure all Pods in the mtls namespace have the istio-proxy sidecar injected.

Next, configure mutual authentication in STRICT mode for all workloads in the mtls namespace.

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

kubectl create namespace mtls >/dev/null 2>&1

kubectl create deployment frontend \
  --image=nginx \
  -n mtls >/dev/null 2>&1

kubectl create deployment backend \
  --image=httpd \
  -n mtls >/dev/null 2>&1

kubectl expose deployment frontend \
  --port=80 \
  --target-port=80 \
  -n mtls >/dev/null 2>&1

kubectl expose deployment backend \
  --port=80 \
  --target-port=80 \
  -n mtls >/dev/null 2>&1

mkdir -p ~/istio-mtls

cat <<'INFO' > ~/istio-mtls/README.txt
Istio mTLS Scenario

Tasks:
1. Enable automatic sidecar injection for namespace mtls
2. Ensure Pods receive istio-proxy sidecars
3. Configure STRICT mutual TLS authentication
4. Validate workloads continue functioning
INFO

echo
echo "[OK] Namespace created          : mtls"
echo "[OK] Frontend deployment created"
echo "[OK] Backend deployment created"
echo "[OK] Services created"
echo "[OK] Istio scenario files ready"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
