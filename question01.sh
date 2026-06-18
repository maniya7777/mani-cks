#!/bin/bash

clear

#!/bin/bash
# ============================================================
# CKS Practice | Q01: Hardening Kubelet and ETCD
# setup_problem_scenario.sh
# Introduces insecure configuration for practice
# Run on: controlplane node
# ============================================================

set -euo pipefail

KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"

echo ""
echo "==========================================="
echo " CKS Q01 — Setting up insecure scenario..."
echo "==========================================="
echo ""

# ── Patch kubelet config ──────────────────────────────────────
echo "[1/3] Patching kubelet config..."

sudo python3 - <<'EOF'
import yaml

config_path = "/var/lib/kubelet/config.yaml"

with open(config_path, "r") as f:
    config = yaml.safe_load(f)

config["authentication"]["anonymous"]["enabled"] = True
config["authentication"]["webhook"]["enabled"] = False
config["authorization"]["mode"] = "AlwaysAllow"

with open(config_path, "w") as f:
    yaml.dump(config, f, default_flow_style=False)

print("  kubelet config patched.")
EOF

# ── Patch etcd manifest ───────────────────────────────────────
echo "[2/3] Patching etcd manifest..."

sudo sed -i 's/--client-cert-auth=true/--client-cert-auth=false/' "$ETCD_MANIFEST"
echo "  etcd manifest patched."

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

clear

echo ""
echo "✅ Problem scenario is ready!"
echo "   Now go fix them! 💪"
echo ""

clear

echo "============================================================="
echo "            KILLERCODA - CIS BENCHMARK QUESTION"
echo "============================================================="
echo

cat <<'EOT'

When running the CIS benchmark tool on a cluster created with kubeadm,
multiple critical issues requiring immediate resolution were discovered.

Fix all identified issues and restart the affected components to ensure
the new settings take effect.

Fix all the following violations found for kubelet:

• 1.1.1 Ensure the anonymous-auth parameter is set to false (FAIL)

• 1.1.2 Ensure the --authorization-mode parameter is not set to AlwaysAllow (FAIL)

Note: Use Webhook authentication/authorization whenever possible.

Fix all the following violations found for etcd:

• 2.1.1 Ensure the --client-cert-auth parameter is set to true (FAIL)

EOT

echo
echo "============================================================="
echo " Environment Ready"
echo "============================================================="
