#!/bin/bash
# ============================================================
# CKS Practice | Q15: Kubernetes API Log Auditing
# Removes audit config, volumes and directories
# Run on: controlplane node
# ============================================================

set -euo pipefail

POLICY_DIR="/etc/kubernetes/logpolicy"
LOG_DIR="/var/log/kubernetes"

echo ""
echo "==========================================="
echo " CKS Q15 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Remove audit config from kube-apiserver ──────────
echo "[1/3] Removing audit config from kube-apiserver..."

sudo python3 - <<'PYEOF'
import yaml

manifest_path = "/etc/kubernetes/manifests/kube-apiserver.yaml"

with open(manifest_path, "r") as f:
    manifest = yaml.safe_load(f)

spec = manifest["spec"]
container = spec["containers"][0]

# Remove audit flags
audit_flags = [
    "--audit-policy-file",
    "--audit-log-path",
    "--audit-log-maxage",
    "--audit-log-maxbackup",
    "--audit-log-maxsize"
]
args = container.get("command", [])
args = [a for a in args if not any(a.startswith(f) for f in audit_flags)]
container["command"] = args

# Remove audit volumeMounts
mounts = container.get("volumeMounts", [])
container["volumeMounts"] = [
    m for m in mounts
    if m.get("name") not in ("audit-policy", "audit-logs")
]

# Remove audit volumes
volumes = spec.get("volumes", [])
spec["volumes"] = [
    v for v in volumes
    if v.get("name") not in ("audit-policy", "audit-logs")
]

with open(manifest_path, "w") as f:
    yaml.dump(manifest, f, default_flow_style=False)

print("  Audit flags + volumes removed from kube-apiserver.")
PYEOF

# ── Step 2: Remove audit directories ─────────────────────────
echo "[2/3] Removing audit directories..."

sudo rm -rf "$POLICY_DIR"
sudo rm -rf "$LOG_DIR"
echo "  $POLICY_DIR removed."
echo "  $LOG_DIR removed."

# ── Force restart kube-apiserver via crictl ───────────────────
echo "  Force restarting kube-apiserver..."

APISERVER_ID=$(sudo crictl ps | grep kube-apiserver | awk '{print $1}')
if [ -n "$APISERVER_ID" ]; then
    sudo crictl stop "$APISERVER_ID"
    echo "  kube-apiserver container stopped — kubelet will recreate it."
else
    echo "  kube-apiserver container not found — may already be restarting."
fi

# ── Step 3: Wait for API server to restart ───────────────────
echo "[3/3] Waiting for API server to restart..."

sleep 10
for i in $(seq 1 30); do
    if kubectl get nodes &>/dev/null; then
        echo "  API server is back up."
        break
    fi
    echo "  Waiting... ($i/30)"
    sleep 3
done

echo ""
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
