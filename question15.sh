#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 15"
echo "============================================================="
echo

cat <<'QUESTION'

Task
Assume an incomplete configuration located at:

/etc/kubernetes/epconfig

and a functional container image scanner with the HTTPS endpoint:

https://image-bouncer-webhook.default.svc:1323/image_policy

Perform the following tasks to implement a Validating Admission Controller:

1. Reconfigure the API server to enable all admission plugins to support the provided AdmissionConfiguration.

2. Reconfigure the ImagePolicyWebhook to reject images if the backend fails.

3. Finally, to test the configuration, deploy the test resource defined in:

~/web1.yaml

which uses an image that should be rejected.

You may delete and recreate this resource as needed.

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

sudo mkdir -p /etc/kubernetes/epconfig

cat <<'CFG' | sudo tee /etc/kubernetes/epconfig/admission_configuration.yaml >/dev/null
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/epconfig/webhook.kubeconfig
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: true
CFG

cat <<'KCFG' | sudo tee /etc/kubernetes/epconfig/webhook.kubeconfig >/dev/null
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: https://image-bouncer-webhook.default.svc:1323/image_policy
  name: image-bouncer
contexts:
- context:
    cluster: image-bouncer
    user: api-server
  name: webhook
current-context: webhook
users:
- name: api-server
KCFG

cat <<'YAML' > ~/web1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web1
spec:
  containers:
  - name: nginx
    image: nginx:latest
YAML

mkdir -p ~/admission-controller

cat <<'INFO' > ~/admission-controller/README.txt
Admission Controller Scenario

Tasks:
1. Enable admission plugins for AdmissionConfiguration
2. Configure ImagePolicyWebhook
3. Ensure backend failures reject images
4. Deploy and test ~/web1.yaml
INFO

echo
echo "[OK] AdmissionConfiguration prepared"
echo "[OK] Webhook kubeconfig created"
echo "[OK] Test manifest created        : ~/web1.yaml"
echo "[OK] Scenario files ready"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
