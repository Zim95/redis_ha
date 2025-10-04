#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE=$1
export NAMESPACE=$NAMESPACE

echo "Tearing down Redis Sentinel HA cluster..."

# Delete resources
kubectl delete statefulset redis-master redis-sentinel redis-replica -n "$NAMESPACE" --ignore-not-found=true
kubectl delete service redis-master-service redis-sentinel-service redis-service redis-master-clusterip -n "$NAMESPACE" --ignore-not-found=true
kubectl delete configmap redis-master-config redis-sentinel-config -n "$NAMESPACE" --ignore-not-found=true

echo "Redis Sentinel HA cluster teardown complete!"
