#!/bin/bash
set -e

echo "Initializing pgBackRest stanza..."
docker exec -u postgres -i pg-primary pgbackrest --stanza=bankdb stanza-create

echo "Taking the first full backup..."
docker exec -u postgres -i pg-primary pgbackrest --stanza=bankdb backup --type=full

echo "Done."
