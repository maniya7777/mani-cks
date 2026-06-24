#!/bin/bash

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q10: Worker Node Upgrade
# setup_q07.sh
# Upgrades CP to v1.35.2 + downgrades node01 to v1.35.1
# Run on: controlplane node
# ============================================================

set -euo pipefail

TARGET_CP_VERSION="1.35.2"
TARGET_NODE_VERSION="1.35.1"

echo ""
echo "==========================================="
echo " CKS Q10 — Setup: Worker Node Upgrade"
echo "==========================================="
echo ""

# ── Step 1: Upgrade control plane ────────────────────────────
echo "[1/2] Checking control plane version..."

CURRENT=$(kubectl get node controlplane \
    -o jsonpath='{.status.nodeInfo.kubeletVersion}' | sed 's/v//')
echo "  Current: v$CURRENT"

if [ "$CURRENT" != "$TARGET_CP_VERSION" ]; then
    echo "  Upgrading control plane to v$TARGET_CP_VERSION..."

    sudo apt-mark unhold kubeadm
    sudo apt-get update -qq
    sudo apt-get install -y kubeadm=${TARGET_CP_VERSION}-*
    sudo apt-mark hold kubeadm

    sudo kubeadm upgrade apply v${TARGET_CP_VERSION} --yes

    sudo apt-mark unhold kubelet kubectl
    sudo apt-get install -y \
        kubelet=${TARGET_CP_VERSION}-* \
        kubectl=${TARGET_CP_VERSION}-*
    sudo apt-mark hold kubelet kubectl
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    echo "  Control plane upgraded to v$TARGET_CP_VERSION."
else
    echo "  Already at v$TARGET_CP_VERSION — skipping."
fi

# ── Step 2: Downgrade node01 via SSH ─────────────────────────
echo "[2/2] Downgrading node01 to v$TARGET_NODE_VERSION..."

ssh node01 bash <<ENDSSH
set -euo pipefail
sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get update -qq
sudo apt-get install -y --allow-downgrades \
    kubeadm=${TARGET_NODE_VERSION}-* \
    kubelet=${TARGET_NODE_VERSION}-* \
    kubectl=${TARGET_NODE_VERSION}-*
sudo apt-mark hold kubeadm kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
echo "  node01 downgraded to ${TARGET_NODE_VERSION}."
ENDSSH

echo "  Waiting for kubelet to re-register..."
sleep 20
kubectl get nodes

sleep 5
kubectl get nodes


clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 10"
echo "============================================================="
echo

cat <<'QUESTION'

Context
A cluster configured with kubeadm was recently upgraded, but one node was retained on an older version due to workload compatibility issues.

Task
Upgrade the cluster node node02 to match the version of the control plane node.

Use the following command to connect to this compute node:

[candidate@cks000034] ssh node02

PS:
Do not modify any running workloads in the cluster.

QUESTION

echo ""
echo "✅ Q10 scenario is ready!"
echo ""
echo "  controlplane : v$TARGET_CP_VERSION  ✔"
echo "  node01       : v$TARGET_NODE_VERSION  ✔"
echo ""
echo "  Now ssh node01 and complete the upgrade. 💪"
echo ""

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
