#!/bin/bash

echo "========================================"
echo "CKA/CKAD NetworkPolicy Question"
echo "========================================"
echo
echo "Context"
echo "You must implement NetworkPolicies to control cross-namespace traffic for existing Deployments."
echo
echo "Task"
echo "First, create a NetworkPolicy named deny-policy in the prod namespace"
echo "to block all ingress traffic."
echo
echo "PS: The prod namespace is labeled env: prod."
echo
echo "Then, create a NetworkPolicy named allow-from-prod in the data namespace"
echo "to allow ingress traffic only from Pods in the prod namespace."
echo "Use the prod namespace label to allow traffic."
echo
echo "PS: The data namespace is labeled env: data."
echo
echo "Note:"
echo "Do not modify or delete any namespaces or Pods —"
echo "only create the required NetworkPolicies."
echo
echo "========================================"
echo "Setting up Killercoda Environment..."
echo "========================================"

# Create namespaces
kubectl create namespace prod
kubectl create namespace data

# Label namespaces
kubectl label namespace prod env=prod
kubectl label namespace data env=data

# Create deployments
kubectl create deployment frontend --image=nginx -n prod
kubectl create deployment backend --image=nginx -n data

# Expose deployments
kubectl expose deployment frontend --port=80 -n prod
kubectl expose deployment backend --port=80 -n data

echo
echo "========================================"
echo "Environment Ready"
echo "========================================"
