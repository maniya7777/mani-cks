#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 12"
echo "============================================================="
echo

cat <<'QUESTION'

Task
A Deployment in the confidential namespace does not comply with the Restricted Pod Security Standard, preventing its Pods from being scheduled.

Modify this Deployment to comply with the standard and verify the Pods can run normally.

PS:
The Deployment manifest file can be found at:

~/nginx-unprivileged.yaml

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

kubectl create namespace confidential >/dev/null 2>&1

kubectl label namespace confidential \
pod-security.kubernetes.io/enforce=restricted \
--overwrite >/dev/null 2>&1

cat <<'YAML' > ~/nginx-unprivileged.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-unprivileged
  namespace: confidential
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-unprivileged
  template:
    metadata:
      labels:
        app: nginx-unprivileged
    spec:
      containers:
      - name: nginx
        image: nginx

YAML

echo
echo "[OK] Namespace created                  : confidential"
echo "[OK] Restricted PSS enabled on namespace"
echo "[OK] Deployment manifest created        : ~/nginx-unprivileged.yaml"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
