#!/bin/bash
set -e

echo "Verifying backup integrity in repository..."
docker exec -u postgres -i pg-primary pgbackrest verify --stanza=bankdb


echo "Starting test restore process..."
echo "Stopping any running test container..."
docker compose stop pg-restore-test || true

# We will run restore on the pgdata-restore volume via ephemeral container
echo "Running pgbackrest restore on test data volume..."
docker run --rm \
  -v project-2-backup-recovery_pgdata-restore:/var/lib/postgresql/data \
  -v project-2-backup-recovery_pgbackrest-repo:/var/lib/pgbackrest \
  -v project-2-backup-recovery_pgarchive:/var/lib/postgresql/archive \
  -v $(pwd)/config/pgbackrest.conf:/etc/pgbackrest/pgbackrest.conf:ro \
  postgres:16 \
  bash -c "apt-get update && apt-get install -y pgbackrest && chown -R postgres:postgres /var/lib/postgresql/data && su - postgres -c 'pgbackrest restore --stanza=bankdb --type=name --target=\"before_disaster_b\" --delta'"

echo "Starting pg-restore-test container..."
docker compose start pg-restore-test || docker compose up -d pg-restore-test

echo "Waiting for test postgres to be ready..."
sleep 5

echo "Comparing data..."
# Run some queries to check data on restore
# You can compare counts directly
PRIMARY_COUNT=$(docker exec -i pg-primary psql -U postgres -d bankdb -t -c "SELECT COUNT(*) FROM transactions;")
RESTORE_COUNT=$(docker exec -i pg-restore-test psql -U postgres -d bankdb -t -c "SELECT COUNT(*) FROM transactions;")

echo "Primary Transaction Count: $PRIMARY_COUNT"
echo "Restore Transaction Count: $RESTORE_COUNT"

if [ "$PRIMARY_COUNT" == "$RESTORE_COUNT" ]; then
    echo "PASS: Backup restored successfully and data matches!"
else
    echo "FAIL: Data mismatch!"
fi
