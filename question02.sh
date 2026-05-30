#!/bin/bash

clear

echo "============================================================="
echo "                 KILLERCODA - TASK (QUESTION 02)"
echo "============================================================="
echo

cat <<'QST'

Context
You must secure access to the web server using SSL files stored in a TLS Secret.

Task
Create a TLS Secret named clever-cactus in the clever-cactus namespace for the existing Deployment named clever-cactus.

Use the following SSL files:
• Certificate: /root/mani-cks/web.k8s.local.crt
• Private Key: /root/mani-cks/web.k8s.local.key

The Deployment is already configured to use the TLS Secret. Do not modify the existing Deployment.

QST

echo
echo "============================================================="
echo " Creating namespace, cert and key"
echo "============================================================="
echo

# Create namespace (safe even if already exists)
kubectl create namespace clever-cactus --dry-run=client -o yaml | kubectl apply -f -

# Create directory
mkdir -p /root/mani-cks

# Generate private key (non-interactive)
openssl genrsa -out /root/mani-cks/web.k8s.local.key 2048

# Generate certificate (fixed + non-interactive)
openssl req -new -x509 \
  -key /root/mani-cks/web.k8s.local.key \
  -out /root/mani-cks/web.k8s.local.crt \
  -days 365 \
  -nodes \
  -subj "/CN=web.k8s.local"

echo
echo " Secret created successfully"

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
