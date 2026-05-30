#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 03"
echo "============================================================="
echo

cat <<'TASK'

Task
Analyze and edit the provided Dockerfile /cks/docker/Dockerfile to fix one instruction with prominent security/best practice issues.

Do not build the Dockerfile — this may cause storage exhaustion and a score of zero.

Analyze and edit the provided manifest file /cks/docker/deployment.yaml to fix one field with prominent security/best practice issues.

Note:
Do not add or delete configuration settings — only modify existing ones to resolve the security/best practice issues in both files.

Note:
If a non-privileged user is required to execute any project, use the nobody user with UID 65535.

TASK

echo
echo "============================================================="
echo " Creating files..."
echo "============================================================="
echo

mkdir -p /cks/docker

# Dockerfile fix: avoid root user
cat <<'EOF' > /cks/docker/Dockerfile
FROM nginx:latest

USER root

COPY . /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
EOF

# deployment.yaml fix: improve image version (no structural changes)
cat <<'EOF' > /cks/docker/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: secure-app
        image: nginx:stable
EOF

echo "Files created successfully:"
echo "  /cks/docker/Dockerfile"
echo "  /cks/docker/deployment.yaml"

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
