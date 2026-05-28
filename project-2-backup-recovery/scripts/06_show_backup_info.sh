#!/bin/bash
set -e

echo "Showing pgBackRest repository info..."
docker exec -u postgres -i pg-primary pgbackrest info
