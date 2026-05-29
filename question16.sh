#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 16"
echo "============================================================="
echo

cat <<'QUESTION'

Task

For testing purposes, the Kubernetes API server of a cluster created with kubeadm was temporarily configured to allow unauthenticated and unauthorized access.

First, configure the cluster's API server to ensure security as follows:

- Disable anonymous authentication
- Use the authorization modes Node and RBAC
- Use the admission controller NodeRestriction

Note:
All kubectl configuration environments/files are also configured to use unauthenticated and unauthorized access.

You do not need to change this, but note that once the cluster is secured, the kubectl configuration will no longer work.

You can use the cluster's original kubectl configuration file located at:

/etc/kubernetes/admin.conf

to access the protected cluster.

Then, clean up by deleting the ClusterRoleBinding:

system:anonymous

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

sudo mkdir -p /etc/kubernetes/manifests

cat <<'YAML' | sudo tee /etc/kubernetes/manifests/kube-apiserver.yaml >/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - name: kube-apiserver
    image: registry.k8s.io/kube-apiserver:v1.30.0
    command:
    - kube-apiserver
    - --anonymous-auth=true
    - --authorization-mode=AlwaysAllow
    - --enable-admission-plugins=AlwaysPullImages
YAML

cat <<'RBAC' > ~/system-anonymous.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:anonymous
subjects:
- kind: User
  name: system:anonymous
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
RBAC

mkdir -p ~/.kube

cat <<'CFG' > ~/.kube/config
apiVersion: v1
kind: Config
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://127.0.0.1:6443
  name: insecure-cluster
contexts:
- context:
    cluster: insecure-cluster
    user: anonymous
  name: insecure-context
current-context: insecure-context
users:
- name: anonymous
CFG

echo
echo "[OK] Insecure kube-apiserver manifest created"
echo "[OK] Anonymous ClusterRoleBinding manifest created"
echo "[OK] Insecure kubectl config prepared"
echo "[OK] Original admin kubeconfig expected at:"
echo "     /etc/kubernetes/admin.conf"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
