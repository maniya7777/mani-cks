#!/bin/bash

echo
echo "============================================================="
echo " Creating files..."
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q03: Dockerfile & Deployment Hardening
# Creates insecure Dockerfile + deployment manifest
# Run on: controlplane node
# ============================================================

set -euo pipefail

CKS_DIR="$HOME/cks/docker"

echo ""
echo "==========================================="
echo " CKS Q03 — Setting up Hardening scenario..."
echo "==========================================="
echo ""

# ── Step 1: Clean previous Q16 state ─────────────────────────
echo "[1/3] Cleaning up any previous Q16 state..."

rm -rf "$HOME/cks"
echo "  Previous state cleaned."

# ── Step 2: Create insecure Dockerfile ───────────────────────
echo "[2/3] Creating insecure Dockerfile..."

mkdir -p "$CKS_DIR"

cat > "$CKS_DIR/Dockerfile" <<'EOF'
FROM nginx:1.27

LABEL maintainer="devops-team"

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

COPY ./html /usr/share/nginx/html

RUN chown -R root:root /usr/share/nginx/html

USER root

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

echo "  Dockerfile created (insecure: USER root)"

# ── Step 3: Create insecure deployment.yaml ───────────────────
echo "[3/3] Creating insecure deployment.yaml..."

cat > "$CKS_DIR/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: default
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
      - name: nginx
        image: nginxinc/nginx-unprivileged
        securityContext:
          privileged: true
          readOnlyRootFilesystem: false
          runAsUser: 0
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /var/cache/nginx
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
EOF

echo "  deployment.yaml created (insecure: privileged=true, runAsUser=0)"


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

echo ""
echo "✅ Q03 scenario is ready!"
echo ""
echo "   Files:"
echo "   • $CKS_DIR/Dockerfile"
echo "   • $CKS_DIR/deployment.yaml"
echo ""
echo " Start the Solution!"
echo "   ⚠ Do NOT build the Docker image after changes."
echo ""

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
