#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE=$1
export NAMESPACE=$NAMESPACE

echo "Teardown Redis cluster..."

# Delete resources
kubectl delete statefulset redis-cluster -n "$NAMESPACE" --ignore-not-found=true
kubectl delete service redis-cluster-service -n "$NAMESPACE" --ignore-not-found=true
kubectl delete configmap redis-cluster-config -n "$NAMESPACE" --ignore-not-found=true
kubectl delete job redis-cluster-init -n "$NAMESPACE" --ignore-not-found=true

# Wait for pods to terminate
kubectl wait --for=delete pod -l app=redis-cluster -n "$NAMESPACE" --timeout=300s

echo "Redis cluster teardown complete!"
