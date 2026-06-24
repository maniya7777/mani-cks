#!/bin/bash
# ============================================================
# CKS Practice | Q15: ImagePolicyWebhook
# reset_to_baseline.sh
# ============================================================

set -euo pipefail

WEBHOOK_DIR="/etc/kubernetes/webhook"
APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
WORK_DIR="/tmp/cks-q02-setup"

echo ""
echo "==========================================="
echo " CKS Q15 — Restoring cluster to baseline..."
echo "==========================================="
echo ""

# ── Step 1: Remove K8s resources FIRST (apiserver still up) ───
echo "[1/4] Removing webhook Deployment, Service, Secret, and CSR..."

kubectl delete deployment image-policy-webhook -n default --ignore-not-found
kubectl delete service    image-policy-webhook -n default --ignore-not-found
kubectl delete secret     image-policy-webhook-tls -n default --ignore-not-found
kubectl delete csr        image-policy-webhook --ignore-not-found
kubectl delete deploy -n default --all --ignore-not-found
echo "  K8s resources removed."

# ── Step 2: Patch kube-apiserver manifest ─────────────────────
echo "[2/4] Removing Q15 changes from kube-apiserver manifest..."

sudo python3 - <<'PYEOF'
import yaml

manifest_path = "/etc/kubernetes/manifests/kube-apiserver.yaml"

with open(manifest_path, "r") as f:
    manifest = yaml.safe_load(f)

spec = manifest["spec"]
container = spec["containers"][0]
args = container.get("command", [])

cleaned_args = []
for a in args:
    if a.startswith("--enable-admission-plugins="):
        prefix, _, values = a.partition("=")
        plugins = [p.strip() for p in values.split(",") if p.strip() != "ImagePolicyWebhook"]
        cleaned_args.append(f"--enable-admission-plugins={','.join(plugins)}")
    elif "admission-control-config-file" in a:
        pass  # remove entirely
    else:
        cleaned_args.append(a)
container["command"] = cleaned_args

# Remove webhook volumeMount
mounts = container.get("volumeMounts", [])
container["volumeMounts"] = [m for m in mounts if m.get("name") != "webhook-config"]

# Remove webhook volume
volumes = spec.get("volumes", [])
spec["volumes"] = [v for v in volumes if v.get("name") != "webhook-config"]

# Remove dnsPolicy and dnsConfig
spec.pop("dnsPolicy", None)
spec.pop("dnsConfig", None)

with open(manifest_path, "w") as f:
    yaml.dump(manifest, f, default_flow_style=False)

print("  kube-apiserver manifest cleaned.")
PYEOF

# ── Step 3: Remove config files and work dir ──────────────────
echo "[3/4] Removing webhook config directory and temp files..."

sudo rm -rf "$WEBHOOK_DIR"
rm -rf "$WORK_DIR"
sudo rm -f $HOME/nginx-deployment.yaml
echo "  Files cleaned up."

# ── Step 4: Restart kubelet ───────────────────────────────────
echo "[4/4] Restarting kubelet..."
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
echo "✅ Cluster is back to baseline!"
echo ""
echo "   Safe to move to next problem. 🚀"
echo ""
