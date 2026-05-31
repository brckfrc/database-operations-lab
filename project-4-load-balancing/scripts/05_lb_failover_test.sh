#!/usr/bin/env bash
# LB-HA test: when one HAProxy crashes, app falls back to the other (multi-host conn).
# Prerequisite: HAProxy is running on both nodes (Contabo + AWS).
set -euo pipefail
CONN='postgresql://postgres:<PASSWORD>@10.10.0.1:5000,10.10.0.2:5000/postgres?target_session_attrs=read-write'

echo "1) Both LBs are running -> connects via multi-host write string:"
psql "$CONN" -t -c "SELECT 'OK primary='||inet_server_addr();"

echo "2) Stopping Contabo HAProxy (simulating 1st LB crash):"
ssh contabo 'sudo docker stop haproxy'

echo "3) Same connection string -> routes via AWS LB (write access uninterrupted):"
psql "$CONN" -t -c "SELECT 'LB switch OK primary='||inet_server_addr();"

echo "4) Restarting Contabo HAProxy:"
ssh contabo 'sudo docker start haproxy'
