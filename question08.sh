#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 08"
echo "============================================================="
echo

cat <<'QUESTION'

Context
You must expose a web application using HTTPS routing.

Task
Create an Ingress resource named web in the prod02 namespace and configure it as follows:

- Route traffic for the host web.k8sng.local and all paths to the existing web Service.
- Enable TLS termination using the existing web-cert Secret.
- Redirect HTTP requests to HTTPS.

PS:
You can test the Ingress configuration using the following command:

[candidate@cks000032] $ curl -Lk https://web.k8sng.local

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

kubectl create namespace prod02 >/dev/null 2>&1

kubectl create deployment web \
  --image=nginx \
  -n prod02 >/dev/null 2>&1

kubectl expose deployment web \
  --port=80 \
  --target-port=80 \
  --name=web \
  -n prod02 >/dev/null 2>&1

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /tmp/web.key \
  -out /tmp/web.crt \
  -subj "/CN=web.k8sng.local" >/dev/null 2>&1

kubectl create secret tls web-cert \
  --cert=/tmp/web.crt \
  --key=/tmp/web.key \
  -n prod02 >/dev/null 2>&1

echo
echo "[OK] Namespace created        : prod02"
echo "[OK] Deployment created       : web"
echo "[OK] Service created          : web"
echo "[OK] TLS Secret created       : web-cert"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
