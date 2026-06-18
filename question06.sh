#!/bin/bash
# ============================================================
# CKS Practice | Q06: Kubernetes API Log Auditing
# Creates audit dirs, baseline policy, patches kube-apiserver
# Run on: controlplane node
# ============================================================

set -euo pipefail

POLICY_DIR="/etc/kubernetes/logpolicy"
LOG_DIR="/var/log/kubernetes"
POLICY_FILE="$POLICY_DIR/sample-policy.yaml"
APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

echo ""
echo "==========================================="
echo " CKS Q06 — Setting up API Audit scenario..."
echo "==========================================="
echo ""

# ── Step 1: Clean previous Q06 state ─────────────────────────
echo "[1/4] Cleaning up any previous Q06 state..."

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

print("  Audit flags + volumes cleaned from kube-apiserver.")
PYEOF

# Reset policy file to baseline (in case user extended it)
sudo rm -f "$POLICY_FILE"
sudo truncate -s 0 "$LOG_DIR/audit-logs.txt" 2>/dev/null || true

echo "  Audit log cleared."
echo "  Previous state cleaned."

# ── Step 2: Create directories ────────────────────────────────
echo "[2/4] Creating audit directories..."

sudo mkdir -p "$POLICY_DIR"
sudo mkdir -p "$LOG_DIR"
sudo touch "$LOG_DIR/audit-logs.txt"
echo "  $POLICY_DIR created."
echo "  $LOG_DIR/audit-logs.txt created."

# ── Step 3: Create baseline audit policy ─────────────────────
echo "[3/4] Creating baseline audit policy..."

sudo tee "$POLICY_FILE" > /dev/null <<'EOF'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]
      resourceNames: ["controller-leader"]

  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
    - group: ""
      resources: ["endpoints", "services"]
EOF

echo "  Baseline policy created at $POLICY_FILE"

# ── Step 4: Mount volumes in kube-apiserver ───────────────────
echo "[4/4] Patching kube-apiserver with audit volumes..."

sudo python3 - <<'PYEOF'
import yaml

manifest_path = "/etc/kubernetes/manifests/kube-apiserver.yaml"

with open(manifest_path, "r") as f:
    manifest = yaml.safe_load(f)

spec = manifest["spec"]
container = spec["containers"][0]

# Add audit-policy volumeMount
mounts = container.get("volumeMounts", [])
if not any(m.get("name") == "audit-policy" for m in mounts):
    mounts.append({
        "name": "audit-policy",
        "mountPath": "/etc/kubernetes/logpolicy",
        "readOnly": True
    })
if not any(m.get("name") == "audit-logs" for m in mounts):
    mounts.append({
        "name": "audit-logs",
        "mountPath": "/var/log/kubernetes"
    })
container["volumeMounts"] = mounts

# Add audit volumes
volumes = spec.get("volumes", [])
if not any(v.get("name") == "audit-policy" for v in volumes):
    volumes.append({
        "name": "audit-policy",
        "hostPath": {
            "path": "/etc/kubernetes/logpolicy",
            "type": "DirectoryOrCreate"
        }
    })
if not any(v.get("name") == "audit-logs" for v in volumes):
    volumes.append({
        "name": "audit-logs",
        "hostPath": {
            "path": "/var/log/kubernetes",
            "type": "DirectoryOrCreate"
        }
    })
spec["volumes"] = volumes

with open(manifest_path, "w") as f:
    yaml.dump(manifest, f, default_flow_style=False)

print("  audit-policy + audit-logs volumes added to kube-apiserver.")
PYEOF

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
echo "✅ Q06 scenario is ready!"
echo ""
echo "   Start the Solution!:"
echo ""
echo

clear

echo "==============================================="
echo " QUESTION"
echo "==============================================="

echo
echo "Context"
echo "You must implement auditing for a cluster configured with kubeadm."
echo

echo "Task"
echo "First, reconfigure the cluster's API server to:"
echo "- Use the basic audit policy located at /etc/kubernetes/logpolicy/sample-policy.yaml"
echo "- Store logs at /var/log/kubernetes/audit-logs.txt"
echo "- Retain a maximum of 2 log files for up to 10 days"
echo
echo "Note: The basic policy only specifies what not to log."
echo

echo "Then, edit and extend the basic policy to log:"
echo
echo "- persistentvolumes events at the RequestResponse level"
echo "- Request bodies for configmaps events in the front-apps namespace"
echo "- Changes to ConfigMap and Secret in all namespaces at the Metadata level"
echo "- All other requests at the Metadata level"
echo
echo "Note: Ensure the API server uses the extended policy."
echo

echo "Files:"
echo "/etc/kubernetes/logpolicy/sample-policy.yaml"
echo "/etc/kubernetes/manifests/kube-apiserver.yaml"
echo

echo "==============================================="
echo " Environment Ready"
echo "==============================================="
