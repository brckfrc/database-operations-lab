# Proje 2: PostgreSQL Yedekleme ve Felaketten Kurtarma Planı

Bu plan, **Database Operations Lab** kapsamındaki `project-2-backup-recovery` projesinin adım adım nasıl uygulanacağını tanımlar.

## Hedef

PostgreSQL üzerinde **pgBackRest** kullanarak üç farklı yedekleme stratejisini (Full, Differential, Incremental) uygulamak, zamanlayıcılarla otomatik yedekleme kurmak, Point-In-Time Recovery (PITR) ile felaketten kurtarmak ve yedeklerin doğruluğunu otomatik test etmek.

## Senaryo Seçimi

Projede **"Banka İşlemleri" (Bank Transactions)** veritabanı kullanılacak. Böylece "yanlışlıkla tablonun silinmesi", "yanlış toplu güncelleme" gibi felaket senaryoları daha kritik ve gerçekçi bir his verecektir.

---

## Mimari Genel Bakış

```
┌─────────────────────────────────────────────────┐
│            Docker Compose Stack                  │
├─────────────────────────────────────────────────┤
│  PostgreSQL 16  ←──── pgBackRest (stanza)       │
│       │                     │                   │
│       ▼                     ▼                   │
│  WAL Archiving ───► pgBackRest Repo             │
│                     (full/diff/incr)            │
│                                                 │
│  pg_cron ───► Scheduled backup jobs             │
└─────────────────────────────────────────────────┘
```

---

## Bölüm 1: Tam, Artık ve Fark Yedeklemeleri

### Kullanılacak Araç: pgBackRest

pgBackRest, PostgreSQL için full/differential/incremental yedeklemeyi native destekleyen profesyonel bir yedekleme aracıdır.

### Yedekleme Tipleri

| Tip | pgBackRest Komutu | Açıklama |
|-----|-------------------|----------|
| **Full** | `pgbackrest backup --type=full` | Veritabanının tamamını yedekler |
| **Differential** | `pgbackrest backup --type=diff` | Son full backup'tan bu yana değişenleri yedekler |
| **Incremental** | `pgbackrest backup --type=incr` | Son herhangi bir backup'tan bu yana değişenleri yedekler |

### Gösterilecek Senaryo

1. Full backup al → 100 kayıt
2. 20 yeni kayıt ekle → Differential backup al
3. 10 yeni kayıt daha ekle → Incremental backup al
4. `pgbackrest info` ile üç tip yedeğin listelendiğini göster (boyut farkları dahil)

---

## Bölüm 2: Zamanlayıcılarla Otomatik Yedekleme

### Kullanılacak Araç: pg_cron (PostgreSQL extension)

Container içinde `pg_cron` extension'ı aktif edilerek yedekleme schedule'ları veritabanı seviyesinde tanımlanacak.

### Tanımlanacak Schedule'lar

| Schedule | Tip | Cron İfadesi | Açıklama |
|----------|-----|--------------|----------|
| Günlük gece 02:00 | Incremental | `0 2 * * *` | Her gece küçük artımlı yedek |
| Haftalık Pazar 03:00 | Differential | `0 3 * * 0` | Haftalık fark yedeği |
| Aylık 1. gün 04:00 | Full | `0 4 1 * *` | Aylık tam yedek |

### Gösterilecek Senaryo

1. `pg_cron` ile schedule tanımla
2. Manuel tetikleyerek çalıştığını doğrula (video için beklememek adına)
3. `cron.job_run_details` tablosundan çalışma loglarını göster
4. Başarısız bir yedekleme simüle et ve log'da hata kaydını göster

---

## Bölüm 3: Felaketten Kurtarma Senaryoları

### Senaryo A: Yanlışlıkla Toplu Silme (DELETE)

1. Tüm transaction kayıtları yanlışlıkla silinir
2. Felaket anının timestamp'i not edilir
3. pgBackRest ile PITR uygulanır (`--target-time`)
4. Veriler felaketten hemen önceki haline döner

### Senaryo B: Yanlış Toplu Güncelleme (UPDATE)

1. Tüm hesap bakiyeleri yanlışlıkla 0'a güncellenir
2. PITR ile güncelleme öncesine dönülür
3. Bakiyelerin orijinal halinde olduğu doğrulanır

### PITR Restore Adımları (pgBackRest ile)

```bash
# 1. PostgreSQL durdur
pg_ctl stop -D /var/lib/postgresql/data

# 2. pgBackRest restore (belirli zamana)
pgbackrest restore --stanza=bankdb \
  --type=time \
  --target="2026-05-05 14:30:00+03" \
  --target-action=promote \
  --delta

# 3. PostgreSQL başlat (recovery otomatik uygulanır)
pg_ctl start -D /var/lib/postgresql/data
```

---

## Bölüm 4: Test Yedekleme Senaryoları

### 4.1 Yedek Bütünlük Doğrulaması

```bash
# pgBackRest verify komutu ile tüm yedeklerin bütünlüğünü kontrol et
pgbackrest verify --stanza=bankdb
```

### 4.2 Restore Testi (Ayrı Container'a)

Yedeği ayrı bir "test" PostgreSQL container'ına restore ederek doğrulama:

1. İkinci bir PostgreSQL container ayağa kaldır (`pg-restore-test`)
2. pgBackRest ile son yedeği bu container'a restore et
3. Otomatik karşılaştırma scripti çalıştır:
   - Tablo sayıları eşleşiyor mu?
   - Kayıt sayıları eşleşiyor mu?
   - Checksum (md5 hash) karşılaştırması
4. Sonuçları raporla

### 4.3 Otomatik Doğrulama Scripti

`scripts/03_verify_backup.sh` scripti şunları yapacak:
- `pgbackrest verify` çalıştır
- Son yedeği test container'ına restore et
- Kayıt sayısı ve tablo checksum kontrolü
- PASS/FAIL sonucu çıktı ver

---

## Dosya ve Klasör Yapısı

```
project-2-backup-recovery/
├── docker-compose.yml
├── Dockerfile                    # PostgreSQL + pgBackRest + pg_cron
├── config/
│   ├── pgbackrest.conf           # pgBackRest konfigürasyonu
│   ├── postgresql.conf           # WAL ve archive ayarları
│   └── pg_hba.conf               # Erişim ayarları
├── sql/
│   ├── 00_init_schema.sql        # Şema + 100 kayıt başlangıç verisi
│   ├── 01_setup_pg_cron.sql      # pg_cron extension + schedule tanımları
│   ├── 02_simulate_workload.sql  # Artan veri yükü (diff/incr backup arası)
│   ├── 03_disaster_delete.sql    # Felaket A: toplu silme
│   └── 04_disaster_update.sql    # Felaket B: yanlış güncelleme
├── scripts/
│   ├── 01_init_pgbackrest.sh     # Stanza oluştur + ilk full backup
│   ├── 02_take_diff_backup.sh    # Differential backup al
│   ├── 03_take_incr_backup.sh    # Incremental backup al
│   ├── 04_restore_pitr.sh        # PITR ile felaketten kurtarma
│   ├── 05_verify_backup.sh       # Yedek doğrulama (verify + restore test)
│   └── 06_show_backup_info.sh    # pgbackrest info çıktısı (boyutlar, tipler)
├── screenshots/
├── report/
│   └── README.md                 # Teknik rapor
└── README.md                     # Proje özeti + video linki
```

---

## Docker Compose Yapısı

### Servisler

| Servis | Açıklama |
|--------|----------|
| `pg-primary` | PostgreSQL 16 + pgBackRest + pg_cron (ana sunucu) |
| `pg-restore-test` | Yedek doğrulama için ikinci PostgreSQL instance |

### Volumes

| Volume | İçerik |
|--------|--------|
| `pgdata` | PostgreSQL data dizini |
| `pgbackrest-repo` | pgBackRest yedek deposu |
| `pgarchive` | WAL arşiv dosyaları |

### Dockerfile Özeti

PostgreSQL 16 base image üzerine:
- pgBackRest kurulumu
- pg_cron extension kurulumu
- `pgbackrest.conf` konfigürasyonu
- WAL archiving parametreleri

---

## Doğrulama ve Video Akışı Planı

Video en az 10 dk olacak. Önerilen akış:

### Giriş (~1 dk)
- Projenin amacını ve kullanılan araçları tanıt

### Bölüm 1: Yedekleme Tipleri (~3 dk)
1. Docker Compose ile sistem ayağa kaldırılır
2. Tabloların dolu olduğu (100 kayıt) gösterilir
3. **Full backup** alınır → `pgbackrest info` ile gösterilir
4. 20 yeni kayıt eklenir → **Differential backup** alınır
5. 10 yeni kayıt daha → **Incremental backup** alınır
6. `pgbackrest info` ile üç yedeğin boyut farklarıyla listelenmesi

### Bölüm 2: Otomatik Yedekleme (~2 dk)
7. `pg_cron` schedule'ları gösterilir
8. Manuel tetikleme ile çalıştığı doğrulanır
9. `cron.job_run_details` logları gösterilir

### Bölüm 3: Felaketten Kurtarma (~3 dk)
10. **Felaket A**: `DELETE FROM transactions;` çalıştırılır
11. PITR ile kurtarma yapılır, veriler geri gelir
12. **Felaket B**: Tüm bakiyeler 0'a güncellenir
13. PITR ile kurtarma yapılır, bakiyeler orijinal haline döner

### Bölüm 4: Yedek Doğrulama (~2 dk)
14. `pgbackrest verify` çalıştırılır
15. Test container'ına restore + otomatik karşılaştırma çalıştırılır
16. PASS/FAIL sonucu gösterilir

### Kapanış (~1 dk)
- Özet ve yedekleme stratejisinin gerçek dünya değeri
