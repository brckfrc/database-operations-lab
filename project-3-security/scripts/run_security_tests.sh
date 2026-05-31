#!/usr/bin/env bash
# =====================================================================
# run_security_tests.sh
# Runs security tests sequentially with a SEPARATE connection PER USER.
# (Consecutive CONNECT in a single sqlplus session prevents default roles from activating,
#  so each test uses a separate connection to avoid unreliable behavior.)
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

R='reception1/"Recept1#2026"@localhost:1521/FREEPDB1'
D='dr_house/"DrHouse#2026"@localhost:1521/FREEPDB1'
A='auditor1/"Auditor1#2026"@localhost:1521/FREEPDB1'
S='system/"Admin#2026pass"@localhost:1521/FREEPDB1'

echo "############## 07 reception1 (most restricted) ##############"
./scripts/run_sql.sh "$R" sql/07_test_reception.sql

echo "############## 08 dr_house (fully privileged) ##############"
./scripts/run_sql.sh "$D" sql/08_test_doctor.sql

echo "############## 09 auditor1 (segregation of duties) ##############"
./scripts/run_sql.sh "$A" sql/09_test_auditor.sql

echo "############## 10 system (audit review) ##############"
./scripts/run_sql.sh "$S" sql/10_audit_review.sql
