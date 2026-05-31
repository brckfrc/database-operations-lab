#!/usr/bin/env bash
# =====================================================================
# run_sql.sh - Executes an SQL file via sqlplus inside the container.
#
# Usage:
#   ./scripts/run_sql.sh '<connect_string>' <sql_dosyasi>
#
# Example:
#   ./scripts/run_sql.sh 'system/"Admin#2026pass"@localhost:1521/FREEPDB1'      sql/00_admin_setup.sql
#   ./scripts/run_sql.sh 'hospital_app/"Hospital#2026app"@localhost:1521/FREEPDB1' sql/01_init_schema.sql
#
# Note: Because 07_security_tests.sql uses CONNECT internally, the initial
#      system can be provided as the connection.
# =====================================================================
set -euo pipefail

CONN="${1:?connect string gerekli}"
FILE="${2:?sql dosyasi gerekli}"
CONTAINER="${ORACLE_CONTAINER:-p3-oracle}"

{ cat "$FILE"; printf '\nEXIT;\n'; } | docker exec -i "$CONTAINER" sqlplus -S -L "$CONN"
