#!/usr/bin/env bash
# Cluster status + lag check (from any DB node).
ssh node1 'sudo docker exec patroni patronictl -c /etc/patroni/patroni.yml list'
