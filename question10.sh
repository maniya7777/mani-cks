#!/bin/bash

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

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

kubectl create deployment nginx \
  --image=nginx >/dev/null 2>&1

kubectl create deployment redis \
  --image=redis >/dev/null 2>&1

echo
echo "[OK] Sample workloads created"
echo "[OK] Cluster upgrade scenario prepared"
echo "[OK] Worker node expected : node02"
echo

mkdir -p ~/cluster-upgrade

cat <<'INFO' > ~/cluster-upgrade/README.txt
Cluster Upgrade Scenario

Control Plane Version:
v1.30.x

Worker Node:
node02

Requirement:
Upgrade node02 to match the control plane version.

Important:
Do NOT interrupt existing workloads.
INFO

echo "[OK] Supporting files created"

echo
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
