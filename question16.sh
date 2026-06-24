#!/bin/bash

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q16: Securing API Server Auth & Authz
# setup_problem_scenario.sh
# Run on: controlplane node
# ============================================================

set -euo pipefail


echo ""
echo "==========================================="
echo " CKS Q16 — Setting up insecure API server..."
echo "==========================================="
echo ""

# ── Step 1: Patch kube-apiserver — add anonymous-auth=true ───
echo "[1/5] Patching kube-apiserver..."

# ── Step 1: Clean --anonymous-auth if left from previous practice ──
echo "[1/5] Cleaning kube-apiserver (removing --anonymous-auth if present)..."

sudo python3 - <<'PYEOF'
import yaml

manifest_path = "/etc/kubernetes/manifests/kube-apiserver.yaml"

with open(manifest_path, "r") as f:
    manifest = yaml.safe_load(f)

container = manifest["spec"]["containers"][0]
args = container.get("command", [])

if any(a.startswith("--anonymous-auth=") for a in args):
    args = [a for a in args if not a.startswith("--anonymous-auth=")]
    container["command"] = args
    with open(manifest_path, "w") as f:
        yaml.dump(manifest, f, default_flow_style=False)
    print("  --anonymous-auth removed (left from previous practice).")
else:
    print("  --anonymous-auth not present — nothing to clean.")

print("  --authorization-mode       → unchanged (Node,RBAC)")
print("  --enable-admission-plugins → unchanged (NodeRestriction)")
PYEOF

# ── Step 2: Backup admin.conf ─────────────────────────────────
echo "[2/5] Backing up admin.conf to ~/.kube/admin.conf..."

mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/admin.conf"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/admin.conf"
echo "  admin.conf backed up."


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
echo "[3/5] Waiting for API server to restart..."

sleep 10
for i in $(seq 1 30); do
    if kubectl --kubeconfig="$HOME/.kube/admin.conf" get nodes &>/dev/null; then
        echo "  API server is back up."
        break
    fi
    echo "  Waiting... ($i/30)"
    sleep 3
done

# ── Step 4: Create system:anonymous ClusterRoleBinding ────────
echo "[4/5] Creating system:anonymous ClusterRoleBinding..."

kubectl --kubeconfig="$HOME/.kube/admin.conf" \
    delete clusterrolebinding system:anonymous --ignore-not-found

kubectl --kubeconfig="$HOME/.kube/admin.conf" \
    create clusterrolebinding system:anonymous \
    --clusterrole=cluster-admin \
    --user=system:anonymous
echo "  ClusterRoleBinding system:anonymous → cluster-admin created."

# ── Step 5: Replace ~/.kube/config with anonymous kubeconfig ──
echo "[5/5] Creating anonymous kubeconfig..."

APISERVER_IP=$(grep server "$HOME/.kube/admin.conf" \
    | awk -F'https://' '{print $2}' | awk -F':' '{print $1}')

# Remove current config
rm -f "$HOME/.kube/config"

kubectl config set-cluster kubernetes \
    --server="https://${APISERVER_IP}:6443" \
    --insecure-skip-tls-verify=true \
    --kubeconfig="$HOME/.kube/config"

kubectl config set-credentials anon \
    --username=system:anonymous \
    --password=anything \
    --kubeconfig="$HOME/.kube/config"

kubectl config set-context anonymous-context \
    --cluster=kubernetes \
    --user=anon \
    --kubeconfig="$HOME/.kube/config"

kubectl config use-context anonymous-context \
    --kubeconfig="$HOME/.kube/config"

echo "  ~/.kube/config replaced with anonymous kubeconfig."



clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 16"
echo "============================================================="
echo

cat <<'QUESTION'

A Kubernetes cluster built using kubeadm was temporarily left in an insecure state for testing purposes.

The API server is currently configured to allow requests without proper authentication and authorization. This presents a serious security risk.

Your task is to restore secure access controls by hardening the API server configuration and removing any anonymous permissions.

🎯 Task
Update the Kubernetes API server configuration to enforce the following security settings:

Disable anonymous authentication

Configure authorization to use only:

Node
RBAC
Enable the admission controller:

NodeRestriction
After securing the API server, remove unnecessary anonymous access by deleting the following ClusterRoleBinding:

system:anonymous

QUESTION

echo ""
echo "✅ Q16 scenario is ready!"
echo ""
echo "Start the solution!"
echo ""
echo "============================================================="
echo " Ready for execution"
echo "============================================================="
