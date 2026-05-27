#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 05"
echo "============================================================="
echo

cat <<'QUESTION'

Context
You must update an existing Pod to ensure the immutability of its containers.

Task
Modify the Deployment named secdep in the sec-ns namespace so that its containers:

- Run with user ID 30000
- Use a read-only root filesystem
- Prohibit privilege escalation

The Deployment manifest file can be found at:
~/sec-ns_deployment.yaml

QUESTION

echo
echo "============================================================="
echo " Creating Environment Setup"
echo "============================================================="
echo

mkdir -p ~/cks/question05

cat <<'YAML' > ~/sec-ns_deployment.yaml
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
        image: nginx

YAML

echo "[OK] Deployment manifest created:"
echo "~/sec-ns_deployment.yaml"

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
