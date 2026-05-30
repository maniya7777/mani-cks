#!/bin/bash

clear

echo "============================================================="
echo "                 KILLERCODA - TASK (QUESTION 02)"
echo "============================================================="
echo

# Create directory if it doesn't exist
mkdir -p /home/candidate/ca-cert

# Generate private key
openssl genrsa -out /home/candidate/ca-cert/web.k8s.local.key 2048

# Generate self-signed certificate
openssl req -new -x509 -key /home/candidate/ca-cert/web.k8s.local.key \
  -out /home/candidate/ca-cert/web.k8s.local.crt \
  -days 365 \
  -subj "/CN=web.k8s.local"

echo
echo "Certificate and key created:"
echo "  /home/candidate/ca-cert/web.k8s.local.crt"
echo "  /home/candidate/ca-cert/web.k8s.local.key"

# Create TLS Secret
kubectl create secret tls clever-cactus \
  --cert=/home/candidate/ca-cert/web.k8s.local.crt \
  --key=/home/candidate/ca-cert/web.k8s.local.key \
  -n clever-cactus

echo
echo "TLS Secret 'clever-cactus' created in namespace 'clever-cactus'."

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
