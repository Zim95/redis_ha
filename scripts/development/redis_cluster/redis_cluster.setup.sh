#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE=$1
export NAMESPACE=$NAMESPACE
export REDIS_PASSWORD=${REDIS_PASSWORD:-test123}

echo "Setting up Redis Cluster..."

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

REDIS_CLUSTER_YAML=./redis_cluster/redis-cluster.yaml

# Apply Redis cluster configuration
envsubst < $REDIS_CLUSTER_YAML | kubectl apply -n "$NAMESPACE" -f -

echo "Waiting for Redis cluster pods to be ready..."
kubectl wait --for=condition=ready pod -l app=redis-cluster -n "$NAMESPACE" --timeout=300s

echo "Waiting for cluster initialization job to complete..."
kubectl wait --for=condition=complete job/redis-cluster-init -n "$NAMESPACE" --timeout=600s

echo "Redis cluster setup complete!"
echo ""
echo "Cluster information:"
kubectl get pods -l app=redis-cluster -n "$NAMESPACE"
echo ""
echo "To connect to Redis cluster:"
echo "kubectl exec -it redis-cluster-0 -n $NAMESPACE -- redis-cli -a $REDIS_PASSWORD -c cluster nodes"
echo ""
echo "To check cluster status:"
echo "kubectl exec -it redis-cluster-0 -n $NAMESPACE -- redis-cli -a $REDIS_PASSWORD -c cluster info"
