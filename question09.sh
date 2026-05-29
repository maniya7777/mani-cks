#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 09"
echo "============================================================="
echo

cat <<'QUESTION'

Context
A security audit identified non-compliant service account tokens in a Deployment, which may lead to security vulnerabilities.

Task
First, modify the existing stats-monitor-sa ServiceAccount in the monitoring namespace to disable API credential auto-mounting.

Then, modify the existing stats-monitor Deployment in the monitoring namespace to inject the ServiceAccount token mounted at:

/var/run/secrets/kubernetes.io/serviceaccount/token

Use a projected volume named token to inject the ServiceAccount token and ensure it is mounted as read-only.

PS:
The Deployment manifest file can be found at:

~/stats-monitor/deployment.yaml

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

kubectl create namespace monitoring >/dev/null 2>&1

kubectl create serviceaccount stats-monitor-sa \
  -n monitoring >/dev/null 2>&1

kubectl create deployment stats-monitor \
  --image=nginx \
  -n monitoring >/dev/null 2>&1

kubectl set serviceaccount deployment/stats-monitor \
  stats-monitor-sa \
  -n monitoring >/dev/null 2>&1

mkdir -p ~/stats-monitor

cat <<'YAML' > ~/stats-monitor/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stats-monitor
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stats-monitor
  template:
    metadata:
      labels:
        app: stats-monitor
    spec:
      serviceAccountName: stats-monitor-sa
      containers:
      - name: nginx
        image: nginx
YAML

echo "[OK] Namespace created        : monitoring"
echo "[OK] ServiceAccount created   : stats-monitor-sa"
echo "[OK] Deployment created       : stats-monitor"
echo "[OK] Manifest file created    : ~/stats-monitor/deployment.yaml"

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
