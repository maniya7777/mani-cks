#!/bin/bash

clear

echo "============================================================="
echo "              KILLERCODA - QUESTION 11"
echo "============================================================="
echo

cat <<'QUESTION'

Task
The alpine Deployment in the alpine namespace has three containers running different versions of the alpine image.

First, identify which version of the alpine image contains the libcrypto3 package version 3.1.4-r5.

Second, use the pre-installed bom tool to create an SPDX document at:

~/alpine.spdx

for the identified image version.

Finally, update the alpine Deployment and delete the container using the identified image version.

The Deployment manifest file can be found at:

~/alipine-deployment.yaml

PS:
Do not modify any other containers in the Deployment.

QUESTION

echo
echo "============================================================="
echo " Creating Killercoda Environment"
echo "============================================================="
echo

kubectl create namespace alpine >/dev/null 2>&1

cat <<'YAML' > ~/alipine-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine
  namespace: alpine
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alpine
  template:
    metadata:
      labels:
        app: alpine
    spec:
      containers:
      - name: alpine-a
        image: registry.cn-qingdao.aliyuncs.com/containerhub/alpine:3.20.0
        imagePullPolicy: IfNotPresent
        args:
        - /bin/sh
        - -c
        - while true; do sleep 360000; done

      - name: alpine-b
        image: registry.cn-qingdao.aliyuncs.com/containerhub/alpine:3.19.1
        imagePullPolicy: IfNotPresent
        args:
        - /bin/sh
        - -c
        - while true; do sleep 360000; done

      - name: alpine-c
        image: registry.cn-qingdao.aliyuncs.com/containerhub/alpine:3.16.9
        imagePullPolicy: IfNotPresent
        args:
        - /bin/sh
        - -c
        - while true; do sleep 360000; done
YAML

kubectl apply -f ~/alipine-deployment.yaml >/dev/null 2>&1

mkdir -p ~/tools

cat <<'BOM' > ~/tools/bom
#!/bin/bash
echo "SPDX document generated for image: \$1"
touch ~/alpine.spdx
BOM

chmod +x ~/tools/bom

echo 'export PATH=$PATH:~/tools' >> ~/.bashrc

echo
echo "[OK] Namespace created          : alpine"
echo "[OK] Deployment created         : alpine"
echo "[OK] Manifest file created      : ~/alipine-deployment.yaml"
echo "[OK] Mock bom tool configured"
echo

echo "============================================================="
echo " Ready for execution"
echo "============================================================="
