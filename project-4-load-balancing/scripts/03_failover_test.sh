#!/usr/bin/env bash
# Automatic failover test: stop primary patroni -> Patroni+quorum elects new leader.
# Execution: this script is descriptive; actual node commands are given as comments.
set -euo pipefail
echo "1) BEFORE state:"
ssh node1 'sudo docker exec patroni patronictl -c /etc/patroni/patroni.yml list'
echo "2) DISASTER: stop primary patroni"
ssh node1 'sudo docker stop patroni'
echo "3) After TTL(30s), quorum elects new leader; wait..."
sleep 35
echo "4) AFTER state (new leader):"
ssh node2 'sudo docker exec patroni patronictl -c /etc/patroni/patroni.yml list'
echo "5) FAILBACK: old primary returns (as a replica)"
ssh node1 'sudo docker start patroni'
