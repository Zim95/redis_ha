#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE=$1
export NAMESPACE=$NAMESPACE
export REDIS_PASSWORD=${REDIS_PASSWORD:-test123}
export REDIS_MASTER_PASSWORD=${REDIS_MASTER_PASSWORD:-master123}
export REDIS_SENTINEL_PASSWORD=${REDIS_SENTINEL_PASSWORD:-sentinel123}
export REDIS_USER=${REDIS_USER:-redis}

REDIS_MASTER_CONFIG_YAML=./redis_sentinel/redis-master-configmap.yaml
REDIS_SENTINEL_CONFIG_YAML=./redis_sentinel/sentinel-configmap.yaml
REDIS_REPLICA_CONFIG_YAML=./redis_sentinel/redis-replica-statefulset.yaml
REDIS_SERVICES_YAML=./redis_sentinel/redis-services.yaml
REDIS_STATEFULSET_YAML=./redis_sentinel/redis-master-statefulset.yaml

echo "Setting up Redis Sentinel HA cluster..."

# Apply configurations in order
echo "Applying Redis master configuration..."
envsubst < $REDIS_MASTER_CONFIG_YAML | kubectl apply -n "$NAMESPACE" -f -

echo "Applying Redis sentinel configuration..."
envsubst < $REDIS_SENTINEL_CONFIG_YAML | kubectl apply -n "$NAMESPACE" -f -

echo "Applying Redis replica configuration..."
envsubst < $REDIS_REPLICA_CONFIG_YAML | kubectl apply -n "$NAMESPACE" -f -

echo "Applying Redis services..."
envsubst < $REDIS_SERVICES_YAML | kubectl apply -n "$NAMESPACE" -f -

echo "Applying Redis StatefulSets..."
envsubst < $REDIS_STATEFULSET_YAML | kubectl apply -n "$NAMESPACE" -f -

echo "Waiting for Redis pods to be ready..."
kubectl wait --for=condition=ready pod -l app=redis-master -n "$NAMESPACE" --timeout=300s
kubectl wait --for=condition=ready pod -l app=redis-sentinel -n "$NAMESPACE" --timeout=300s

echo "Redis Sentinel HA cluster setup complete!"
echo ""
echo "To connect to Redis:"
echo "- Master: redis-cli -h redis-master-service -p 6379 -a $REDIS_MASTER_PASSWORD"
echo "- Sentinel: redis-cli -h redis-sentinel-service -p 26379 -a $REDIS_SENTINEL_PASSWORD"
echo ""
echo "Sentinel monitoring commands:"
echo "- Check sentinel status: redis-cli -h redis-sentinel-service -p 26379 -a $REDIS_SENTINEL_PASSWORD sentinel masters"
echo "- Check master info: redis-cli -h redis-sentinel-service -p 26379 -a $REDIS_SENTINEL_PASSWORD sentinel master mymaster"
