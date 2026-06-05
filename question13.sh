#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 13"
echo "============================================================="
echo

cat <<'QUESTION'

Task
Perform the following tasks to secure the cluster node cks000037:

1. Remove the user developer from the docker group.

PS:
Do not remove the user from any other groups.

2. Reconfigure and restart the Docker daemon to ensure the socket file at:

/var/run/docker.sock

is owned by the root group.

3. Reconfigure and restart the Docker daemon to ensure it does not listen on any TCP ports.

PS:
After completing the tasks, ensure the Kubernetes cluster remains healthy.

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

sudo groupadd docker >/dev/null 2>&1

sudo useradd developer >/dev/null 2>&1

sudo usermod -aG docker developer >/dev/null 2>&1

mkdir -p /usr/lib/systemd/system

cat <<'EOF' > /usr/lib/systemd/system/docker.socket
[Socket]
ListenStream=/run/docker.sock
SocketMode=0660
SocketUser=root
EOF

sudo tee /usr/lib/systemd/system/docker.service > /dev/null <<'EOF'
[Service]
Type=notify

# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker

ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
EOF

echo
echo "[OK] User created                  : developer"
echo "[OK] Docker group assigned"
echo "[OK] Insecure Docker daemon config created"
echo "[OK] Scenario files prepared"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
