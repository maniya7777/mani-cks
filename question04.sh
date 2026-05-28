#!/bin/bash

set -e

echo "==============================================="
echo " Installing Falco"
echo "==============================================="

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install falco falcosecurity/falco \
  -n falco

echo
echo "Waiting for Falco Pods..."
kubectl rollout status daemonset/falco -n falco --timeout=180s

sleep 15

echo "==============================================="
echo " Creating Namespace"
echo "==============================================="

kubectl create namespace security-lab --dry-run=client -o yaml | kubectl apply -f -

echo "==============================================="
echo " Deploying Normal Application"
echo "==============================================="

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama-normal
  namespace: security-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama-normal
  template:
    metadata:
      labels:
        app: ollama-normal
    spec:
      containers:
      - name: app
        image: busybox
        command:
        - sh
        - -c
        - |
          while true
          do
            echo "normal pod running"
            sleep 30
          done
EOF

echo "==============================================="
echo " Deploying Misbehaving Application"
echo "==============================================="

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama-memory-reader
  namespace: security-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama-memory-reader
  template:
    metadata:
      labels:
        app: ollama-memory-reader
    spec:
      hostPID: true
      containers:
      - name: attacker
        image: busybox
        securityContext:
          privileged: true
        command:
        - sh
        - -c
        - |
          while true
          do
            echo "reading /dev/mem"
            cat /host-dev/mem > /dev/null 2>&1 || true
            sleep 5
          done
        volumeMounts:
        - name: host-dev
          mountPath: /host-dev
      volumes:
      - name: host-dev
        hostPath:
          path: /dev
EOF

echo
echo "Waiting for pods..."
sleep 20

echo "==============================================="
echo " QUESTION"
echo "==============================================="

echo
echo "A misbehaving Pod poses a security threat to the system."
echo
echo "Task"
echo "A Pod belonging to the ollama application is abnormal — it is directly accessing system memory by reading from the sensitive file /dev/mem."
echo
echo "First, identify the misbehaving Pod accessing /dev/mem."
echo "Next, scale the Deployment of the misbehaving Pod to zero replicas."
echo
echo "==============================================="

echo
echo "Environment setup completed."

