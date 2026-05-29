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

sudo mkdir -p /etc/docker

cat <<'JSON' | sudo tee /etc/docker/daemon.json >/dev/null
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://0.0.0.0:2375"
  ],
  "group": "docker"
}
JSON

mkdir -p ~/docker-security

cat <<'INFO' > ~/docker-security/README.txt
Docker Security Scenario

Tasks:
- Remove developer user from docker group
- Configure docker.sock ownership to root group
- Remove TCP listener from Docker daemon
- Restart Docker daemon
- Ensure cluster remains healthy
INFO

echo
echo "[OK] User created                  : developer"
echo "[OK] Docker group assigned"
echo "[OK] Insecure Docker daemon config created"
echo "[OK] Scenario files prepared"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
