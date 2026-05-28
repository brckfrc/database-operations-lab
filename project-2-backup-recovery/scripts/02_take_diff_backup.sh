#!/bin/bash
set -e

echo "Taking a differential backup..."
docker exec -u postgres -i pg-primary pgbackrest --stanza=bankdb backup --type=diff

echo "Done."
