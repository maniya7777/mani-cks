#!/bin/bash

set -e

echo "==============================================="
echo " Kubernetes Audit Logging Lab Setup"
echo "==============================================="

echo
echo "Creating required directories..."

mkdir -p /etc/kubernetes/logpolicy
mkdir -p /var/log/kubernetes

echo
echo "==============================================="
echo " Creating Basic Audit Policy"
echo "==============================================="

cat <<EOF > /etc/kubernetes/logpolicy/sample-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"

rules:

  # Don't log authenticated requests to certain non-resource URL paths.
  - level: None
    userGroups: ["system:authenticated"]
    nonResourceURLs:
      - "/api*"
      - "/version"
EOF

echo
echo "==============================================="
echo " Backing Up kube-apiserver Manifest"
echo "==============================================="

cp /etc/kubernetes/manifests/kube-apiserver.yaml \
/etc/kubernetes/manifests/kube-apiserver.yaml.bak

echo
echo "==============================================="
echo " Preparing Audit Log File"
echo "==============================================="

touch /var/log/kubernetes/audit-logs.txt

echo
echo "==============================================="
echo " Creating Namespace"
echo "==============================================="

kubectl create namespace front-apps --dry-run=client -o yaml | kubectl apply -f -

echo
echo "==============================================="
echo " Creating Sample Resources"
echo "==============================================="

kubectl create configmap app-config \
  --from-literal=color=blue \
  -n front-apps \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic app-secret \
  --from-literal=password=redhat \
  -n front-apps \
  --dry-run=client -o yaml | kubectl apply -f -

echo
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
```

