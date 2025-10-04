```bash
#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Usage: $0 <namespace> <redis_user> <redis_password>"
    exit 1
fi

NAMESPACE=$1
REDIS_USER=$2
REDIS_PASSWORD=$3
REDIS_PASSWORD_BASE64=$(echo -n $REDIS_PASSWORD | base64)

export NAMESPACE=$NAMESPACE
export REDIS_USER=$REDIS_USER
export REDIS_PASSWORD=$REDIS_PASSWORD
export REDIS_PASSWORD_BASE64=$REDIS_PASSWORD_BASE64
export REDIS_DATA_DIR=${REDIS_DATA_DIR:-$(pwd)/data}

REDIS_SINGLE_YAML=./redis_single/redis-single.yaml

echo "Setting up Redis single instance with ACL user..."

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Apply Redis single configuration (no requirepass, only ACL users)
envsubst < $REDIS_SINGLE_YAML | kubectl apply -n "$NAMESPACE" -f -

# Create data directory on host if it doesn't exist
mkdir -p "$REDIS_DATA_DIR/browseterm-redis"
chmod 755 "$REDIS_DATA_DIR/browseterm-redis"

echo "Waiting for Redis pod to be ready..."
kubectl wait --for=condition=ready pod -l app=browseterm-redis -n "$NAMESPACE" --timeout=300s

echo "Creating Redis ACL user: $REDIS_USER"
kubectl exec -i browseterm-redis -n "$NAMESPACE" -- redis-cli --no-auth-warning << EOF
ACL SETUSER $REDIS_USER on +@all ~* >$REDIS_PASSWORD
ACL SETUSER default off
EOF

echo "Verifying user creation..."
kubectl exec browseterm-redis -n "$NAMESPACE" -- redis-cli --user "$REDIS_USER" -a "$REDIS_PASSWORD" --no-auth-warning ACL LIST

echo "Redis single instance setup complete!"
echo ""
echo "To connect to Redis:"
echo "kubectl exec -it browseterm-redis -n $NAMESPACE -- redis-cli --user $REDIS_USER -a $REDIS_PASSWORD"
echo ""
echo "Or port-forward to access from outside:"
echo "kubectl port-forward service/browseterm-redis-service -n $NAMESPACE 6379:6379"
echo "Then: redis-cli -h localhost -p 6379 --user $REDIS_USER -a $REDIS_PASSWORD"
```
