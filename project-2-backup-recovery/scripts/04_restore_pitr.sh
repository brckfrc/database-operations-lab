#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <restore_point_name>"
  echo "Example: $0 before_disaster_a"
  exit 1
fi

TARGET=$1

echo "Stopping pg-primary to safely restore data..."
docker compose stop pg-primary

echo "Running pgbackrest restore via ephemeral container for target '$TARGET'..."
# Use an ephemeral container to restore directly to the pgdata volume
docker run --rm \
  -v project-2-backup-recovery_pgdata:/var/lib/postgresql/data \
  -v project-2-backup-recovery_pgbackrest-repo:/var/lib/pgbackrest \
  -v project-2-backup-recovery_pgarchive:/var/lib/postgresql/archive \
  -v $(pwd)/config/pgbackrest.conf:/etc/pgbackrest/pgbackrest.conf:ro \
  --name pgbackrest-restore-job \
  postgres:16 \
  bash -c "apt-get update && apt-get install -y pgbackrest && chown -R postgres:postgres /var/lib/postgresql/data && su - postgres -c 'pgbackrest restore --stanza=bankdb --type=name --target=\"$TARGET\" --target-action=promote --delta'"

echo "Starting pg-primary back up..."
docker compose start pg-primary

echo "Restore complete!"
