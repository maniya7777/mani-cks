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
• Certificate: /home/candidate/ca-cert/web.k8s.local.crt
• Private Key: /home/candidate/ca-cert/web.k8s.local.key

The Deployment is already configured to use the TLS Secret. Do not modify the existing Deployment.

QST

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
