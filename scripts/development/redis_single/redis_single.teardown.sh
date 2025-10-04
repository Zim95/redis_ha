#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE=$1
export NAMESPACE=$NAMESPACE

echo "Tearing down Redis single instance..."

# Delete resources
kubectl delete pod browseterm-redis -n "$NAMESPACE" --ignore-not-found=true
kubectl delete service browseterm-redis-service -n "$NAMESPACE" --ignore-not-found=true
kubectl delete pvc browseterm-redis-pvc -n "$NAMESPACE" --ignore-not-found=true
kubectl delete pv browseterm-redis-pv -n "$NAMESPACE" --ignore-not-found=true
kubectl delete secret redis-password -n "$NAMESPACE" --ignore-not-found=true

echo "Redis single instance teardown complete!"
echo ""
echo "Note: Redis data in /data/browseterm-redis is preserved for manual cleanup if needed."
