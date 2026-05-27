#!/bin/bash

clear

echo "============================================================="
echo "            KILLERCODA - CIS BENCHMARK QUESTION"
echo "============================================================="
echo

cat <<'EOT'

When running the CIS benchmark tool on a cluster created with kubeadm,
multiple critical issues requiring immediate resolution were discovered.

Fix all identified issues and restart the affected components to ensure
the new settings take effect.

Fix all the following violations found for kubelet:

• 1.1.1 Ensure the anonymous-auth parameter is set to false (FAIL)

• 1.1.2 Ensure the --authorization-mode parameter is not set to AlwaysAllow (FAIL)

Note: Use Webhook authentication/authorization whenever possible.

Fix all the following violations found for etcd:

• 2.1.1 Ensure the --client-cert-auth parameter is set to true (FAIL)

EOT

echo
echo "============================================================="
echo " Environment Ready"
echo "============================================================="
