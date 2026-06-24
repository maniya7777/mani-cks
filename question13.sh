#!/bin/bash

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

#!/bin/bash
# ============================================================
# CKS Practice | Q13: Securing the Docker Daemon
# Installs Docker + creates insecure config for practice
# ============================================================

set -euo pipefail

echo ""
echo "==========================================="
echo " CKS Q13 — Setting up Docker daemon scenario..."
echo "==========================================="
echo ""

# ── Step 1: Clean previous state ─────────────────────────────
# ── Step 1: Clean previous state ─────────────────────────────
# ── Step 1: Clean previous state ─────────────────────────────
echo "[1/5] Cleaning up any previous Q13 state..."

if ! command -v docker &>/dev/null; then
    echo "  Docker not installed — nothing to clean."
else
    # Re-add developer to docker group if removed during previous practice
    if id developer &>/dev/null; then
        if ! id -nG developer | grep -qw docker; then
            sudo usermod -aG docker developer
            echo "  developer re-added to docker group."
        fi
    fi

    # Restore docker.service TCP flag if removed during previous practice
    if [ -f /usr/lib/systemd/system/docker.service ]; then
        if ! grep -q "tcp://0.0.0.0:2375" /usr/lib/systemd/system/docker.service; then
            sudo sed -i \
                's|ExecStart=/usr/bin/dockerd -H fd://|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375|' \
                /usr/lib/systemd/system/docker.service
            echo "  TCP 2375 flag restored in docker.service."
        fi
    fi

    # Restore docker.socket SocketGroup if changed during previous practice
    if [ -f /usr/lib/systemd/system/docker.socket ]; then
        sudo sed -i 's/SocketGroup=root/SocketGroup=docker/' \
            /usr/lib/systemd/system/docker.socket
        echo "  docker.socket SocketGroup restored to docker."
    fi

    # Reload after all file changes in cleanup
    sudo systemctl daemon-reload
    sudo systemctl stop docker docker.socket 2>/dev/null || true
    sudo systemctl start docker.socket
    echo "  Previous state cleaned."
fi

# ── Step 2: Install Docker (skip if already installed) ───────
echo "[2/5] Checking Docker installation..."

if command -v docker &>/dev/null; then
    echo "  Docker already installed — skipping."
else
    echo "  Installing Docker..."

    sudo apt-get update -qq
    sudo apt-get install -y -qq ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    echo "  Docker installed."
fi

# ── Step 3: Create developer user ────────────────────────────
echo "[3/5] Setting up developer user..."

if id developer &>/dev/null; then
    echo "  User developer already exists — skipping."
else
    sudo useradd developer
    echo "  User developer created."
fi

# Add developer to docker group
if ! id -nG developer | grep -qw docker; then
    sudo usermod -aG docker developer
    echo "  developer added to docker group."
else
    echo "  developer already in docker group — skipping."
fi

echo "  Verify: $(id developer)"

# ── Step 4: Enable TCP 2375 in docker.service ────────────────
echo "[4/5] Enabling TCP 2375 in docker.service..."

if grep -q "tcp://0.0.0.0:2375" /usr/lib/systemd/system/docker.service; then
    echo "  TCP 2375 already configured — skipping."
else
    sudo sed -i \
        's|ExecStart=/usr/bin/dockerd -H fd://|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375|' \
        /usr/lib/systemd/system/docker.service
    echo "  TCP 2375 added to docker.service."
fi

# ── Step 5: Reload + restart Docker ──────────────────────────
# ── Step 5: Reload + restart Docker ──────────────────────────
echo "[5/5] Reloading and restarting Docker..."

sudo systemctl daemon-reload
sudo systemctl stop docker docker.socket 2>/dev/null || true
sudo systemctl start docker.socket
sudo systemctl start docker

echo "  Verifying TCP port 2375..."
sleep 3
if sudo ss -tunlp | grep -q 2375; then
    echo "  ✔ Docker listening on TCP 2375."
else
    echo "  ⚠ TCP 2375 not detected — check docker.service manually."
fi

echo "  Verifying docker.sock group..."
ls -lh /var/run/docker.sock


clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 13"
echo "============================================================="
echo

cat <<'QUESTION'

A Kubernetes worker node requires immediate hardening due to insecure Docker daemon configuration.

The node currently:

Allows unnecessary user-level access to the Docker socket
May be exposing the Docker API over the network
Both issues can lead to serious security risks.

You must log in to node cks1011 and apply the required security fixes without impacting cluster stability.

🎯 Task
On node, complete the following:

Remove user developer from the docker group

Do not remove the user from any other groups
Update and restart Docker so that:

/var/run/docker.sock is owned by the root group
Ensure Docker is not listening on any TCP port

It should only use the Unix socket

QUESTION

echo ""
echo "✅ Q13 scenario is ready!"
echo ""
echo "Start the Solution!"
echo ""

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
