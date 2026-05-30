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
echo " Generating SSL Certificate and Key"
echo "============================================================="
echo

# Create directory
mkdir -p /root/mani-cks

# Generate private key (NO PASSWORD)
openssl genrsa -out /root/mani-cks/web.k8s.local.key 2048

# Generate self-signed certificate (FIXED LINE CONTINUATION + NON-INTERACTIVE)
openssl req -new -x509 \
  -key /root/mani-cks/web.k8s.local.key \
  -out /root/mani-cks/web.k8s.local.crt \
  -days 365 \
  -nodes \
  -subj "/CN=web.k8s.local"

echo
echo "Certificate and key created successfully:"
echo "  /root/mani-cks/web.k8s.local.crt"
echo "  /root/mani-cks/web.k8s.local.key"

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
