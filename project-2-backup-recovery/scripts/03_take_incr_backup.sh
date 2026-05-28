#!/bin/bash
set -e

echo "Taking an incremental backup..."
docker exec -u postgres -i pg-primary pgbackrest --stanza=bankdb backup --type=incr

echo "Done."
