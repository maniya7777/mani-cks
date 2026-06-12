#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 08"
echo "============================================================="
echo

cat <<'QUESTION'

There is an existing web application running in the production namespace behind a Service named web-service.

Your goal is to publish this application externally using an Ingress with HTTPS.

Create an Ingress resource called web-ingress in the production namespace with these requirements:

Accept traffic for the hostname web.k8s.local
Forward all paths (/) to the existing web Service
Terminate TLS using the existing Secret web-ingress-tls
Ensure plain HTTP requests are automatically redirected to HTTPS

For cillium use below doc:

[https://docs.cilium.io/en/latest/network/servicemesh/ingress/]

Validate using:

# NGINX
curl -Lk https://web.k8s.local:32000

# Cilium
curl -Lk https://web.k8s.local:32001

QUESTION


echo "============================================================="
echo " Ready for execution"
echo "============================================================="
