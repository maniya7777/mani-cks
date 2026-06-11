#!/bin/bash
# ============================================================
# CKS Practice | Q01: Hardening Kubelet and ETCD
# reset_to_baseline.sh
# Restores cluster to clean kubeadm baseline (secure defaults)
# Run on: controlplane node
# ============================================================

set -euo pipefail

KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"

echo ""
echo "==========================================="
echo " CKS Q01 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Restore kubelet config ────────────────────────────────────
echo "[1/3] Restoring kubelet config to secure defaults..."

sudo python3 - <<'EOF'
import yaml

config_path = "/var/lib/kubelet/config.yaml"

with open(config_path, "r") as f:
    config = yaml.safe_load(f)

config["authentication"]["anonymous"]["enabled"] = False
config["authentication"]["webhook"]["enabled"] = True
config["authorization"]["mode"] = "Webhook"

with open(config_path, "w") as f:
    yaml.dump(config, f, default_flow_style=False)

print("  kubelet config restored.")
EOF

# ── Restore etcd manifest ─────────────────────────────────────
echo "[2/3] Restoring etcd manifest..."

# Handle both directions (whether currently true or false)
sudo sed -i 's/--client-cert-auth=false/--client-cert-auth=true/' "$ETCD_MANIFEST"
echo "  etcd manifest restored."

# ── Restart kubelet ───────────────────────────────────────────
echo "[3/3] Restarting kubelet..."

sudo systemctl daemon-reload
sudo systemctl restart kubelet
echo "  kubelet restarted."

# ── Force restart kube-apiserver via crictl ───────────────────
echo "  Force restarting kube-apiserver..."

APISERVER_ID=$(sudo crictl ps | grep kube-apiserver | awk '{print $1}')
if [ -n "$APISERVER_ID" ]; then
    sudo crictl stop "$APISERVER_ID"
    echo "  kube-apiserver container stopped — kubelet will recreate it."
else
    echo "  kube-apiserver container not found — may already be restarting."
fi

# ── Wait for API server to come back up ───────────────────────
echo "  Waiting for API server to restart..."
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
