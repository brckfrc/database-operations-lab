#!/usr/bin/env python3
"""
SQL Injection demosu (Bolum 3)
------------------------------------------------------------------
Ayni kullanici girdisi (`payload`) iki sekilde calistirilir:

  1) ZAFIYETLI : girdi dogrudan SQL metnine gomulur (string birlestirme)
                 -> ' OR '1'='1 ile TUM hastalar sizar.
  2) GUVENLI   : bind variable (parametreli sorgu)
                 -> ayni girdi hicbir kayit dondurmez.

Ek savunma: uygulama en az yetkili kullanici (nurse_joy, sadece SELECT)
ile baglanir; injection basarili olsa bile hasar sinirlidir.

python-oracledb "thin" modda calisir -> Oracle Client kurulumu gerekmez.

Kullanim:
    pip install -r requirements.txt
    python injection_demo.py
"""

import oracledb

DSN = "localhost:1521/FREEPDB1"
USER = "nurse_joy"          # en az yetkili (sadece SELECT)
PASSWORD = "NurseJoy#2026"

# Saldirganin "hasta arama" kutusuna yazdigi klasik injection girdisi
PAYLOAD = "x' OR '1'='1"


def vulnerable_search(conn, user_input: str):
    """KOTU ORNEK - girdiyi dogrudan SQL'e gomer (ASLA YAPMA)."""
    sql = (
        "SELECT patient_id, full_name "
        "FROM hospital_app.patients "
        f"WHERE full_name = '{user_input}'"      # <-- ZAFIYET
    )
    print("  [zafiyetli SQL] ", sql)
    with conn.cursor() as cur:
        cur.execute(sql)
        return cur.fetchall()


def safe_search(conn, user_input: str):
    """IYI ORNEK - bind variable kullanir (parametreli sorgu)."""
    sql = "SELECT patient_id, full_name FROM hospital_app.patients WHERE full_name = :name"
    print("  [guvenli SQL]   ", sql, " | bind name =", repr(user_input))
    with conn.cursor() as cur:
        cur.execute(sql, name=user_input)
        return cur.fetchall()


def main():
    with oracledb.connect(user=USER, password=PASSWORD, dsn=DSN) as conn:
        total = conn.cursor().execute("SELECT COUNT(*) FROM hospital_app.patients").fetchone()[0]
        print(f"\nVeritabaninda toplam {total} hasta var.")
        print(f"Saldirgan girdisi (payload): {PAYLOAD!r}\n")

        print("=" * 60)
        print("1) ZAFIYETLI SORGU")
        print("=" * 60)
        rows = vulnerable_search(conn, PAYLOAD)
        print(f"  -> Donen kayit sayisi: {len(rows)}")
        if len(rows) == total:
            print("  -> !! TUM hastalar sizdi (injection BASARILI)\n")
        else:
            print()

        print("=" * 60)
        print("2) GUVENLI SORGU (bind variable)")
        print("=" * 60)
        rows = safe_search(conn, PAYLOAD)
        print(f"  -> Donen kayit sayisi: {len(rows)}")
        print("  -> Injection ETKISIZ (girdi veri olarak islendi)\n")


if __name__ == "__main__":
    main()
