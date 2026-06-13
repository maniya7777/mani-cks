#!/bin/bash
# ============================================================
# CKS Practice | Q08: Securing API Server Auth & Authz
# reset_to_baseline.sh
# Run on: controlplane node
# ============================================================

set -euo pipefail


echo ""
echo "==========================================="
echo " CKS Q08 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Delete system:anonymous CRB ──────────────────────
echo "[1/3] Removing system:anonymous ClusterRoleBinding..."

kubectl --kubeconfig="$HOME/.kube/admin.conf" \
    delete clusterrolebinding system:anonymous --ignore-not-found
echo "  ClusterRoleBinding removed."

# ── Step 2: Remove --anonymous-auth from kube-apiserver ──────
echo "[2/3] Restoring kube-apiserver to baseline..."

sudo python3 - <<'PYEOF'
import yaml

manifest_path = "/etc/kubernetes/manifests/kube-apiserver.yaml"

with open(manifest_path, "r") as f:
    manifest = yaml.safe_load(f)

container = manifest["spec"]["containers"][0]
args = container.get("command", [])

# Only remove --anonymous-auth — leave all other flags untouched
args = [a for a in args if not a.startswith("--anonymous-auth=")]

container["command"] = args

with open(manifest_path, "w") as f:
    yaml.dump(manifest, f, default_flow_style=False)

print("  --anonymous-auth           → removed (kubeadm baseline: not set)")
print("  --authorization-mode       → unchanged (Node,RBAC)")
print("  --enable-admission-plugins → unchanged (NodeRestriction)")
PYEOF

# ── Step 3: Restore ~/.kube/config ───────────────────────────
echo "[3/3] Restoring ~/.kube/config..."

if [ -f "$HOME/.kube/admin.conf" ]; then
    cp "$HOME/.kube/admin.conf" "$HOME/.kube/config"
    echo "  $HOME/.kube/config restored from $HOME/.kube/admin.conf"
else
    echo "  ⚠ admin.conf backup not found — copying from /etc/kubernetes/admin.conf"
    sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
    sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
fi

# ── Force restart kube-apiserver via crictl ───────────────────
echo "  Force restarting kube-apiserver..."

APISERVER_ID=$(sudo crictl ps | grep kube-apiserver | awk '{print $1}')
if [ -n "$APISERVER_ID" ]; then
    sudo crictl stop "$APISERVER_ID"
    echo "  kube-apiserver container stopped — kubelet will recreate it."
else
    echo "  kube-apiserver container not found — may already be restarting."
fi

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
