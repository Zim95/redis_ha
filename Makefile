include env.mk

dev_setup:
	./scripts/development/etcd/etcd.setup.sh $(NAMESPACE)
	./scripts/development/postgres/postgres.setup.sh $(NAMESPACE)

dev_teardown:
	./scripts/development/etcd/etcd.teardown.sh $(NAMESPACE)
	./scripts/development/postgres/postgres.teardown.sh $(NAMESPACE)

dev_redis_single_setup:
	./scripts/development/redis_single/redis_single.setup.sh $(NAMESPACE) $(REDIS_USER) $(REDIS_PASSWORD)

dev_redis_single_teardown:
	./scripts/development/redis_single/redis_single.teardown.sh $(NAMESPACE)

dev_redis_sentinel_setup:
	./scripts/development/redis_sentinel/redis_sentinel.setup.sh $(NAMESPACE)

dev_redis_sentinel_teardown:
	./scripts/development/redis_sentinel/redis_sentinel.teardown.sh $(NAMESPACE)

dev_redis_cluster_setup:
	./scripts/development/redis_cluster/redis_cluster.setup.sh $(NAMESPACE)

dev_redis_cluster_teardown:
	./scripts/development/redis_cluster/redis_cluster.teardown.sh $(NAMESPACE)

# Help target
help:
	@echo "Available targets:"
	@echo "Redis HA targets:"
	@echo "  dev_redis_single_setup     - Setup Redis single instance"
	@echo "  dev_redis_single_teardown  - Teardown Redis single instance"
	@echo "  dev_redis_sentinel_setup   - Setup Redis Sentinel HA cluster"
	@echo "  dev_redis_sentinel_teardown - Teardown Redis Sentinel HA cluster"
	@echo "  dev_redis_cluster_setup    - Setup Redis Cluster"
	@echo "  dev_redis_cluster_teardown - Teardown Redis Cluster"
	@echo ""
