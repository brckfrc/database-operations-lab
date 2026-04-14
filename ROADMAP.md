# BLM4522 — Veritabanı İşlemleri Laboratuvarı · Yol Haritası

> Bu doküman, ders kapsamındaki 5 projeyi **iş bazında** takip etmek için kullanılır.
> Her proje kendi bölümünde tanım, checklist ve teslim çıktılarıyla yer alır.
> Orijinal plan: [`docs/BLM4522_Proje_Roadmap.pdf`](BLM4522_Proje_Roadmap.pdf)
> Teknik detaylar ve geliştirme günlüğü için → [`docs/PROGRESS.md`](PROGRESS.md)

---

## Genel Bakış

| # | Proje | DBMS | Dönem | Durum |
|---|-------|------|-------|-------|
| 1 | Performans Optimizasyonu ve İzleme | MSSQL | Vize | `[ ]` |
| 2 | Yedekleme ve Felaketten Kurtarma | PostgreSQL | Final | `[ ]` |
| 3 | Güvenlik ve Erişim Kontrolü | Oracle | Final | `[ ]` |
| 4 | Yük Dengeleme ve Dağıtık Yapılar | PostgreSQL | Final | `[ ]` |
| 5 | Veri Temizleme ve ETL Süreçleri | PostgreSQL | Vize | `[ ]` |

### Debian Sunucu İhtiyacı

| Proje | İhtiyaç | Sebep | Karar |
|-------|---------|-------|-------|
| 1. Performans | Düşük | Tek makinede rahat gösterilir | Lokal yeterli |
| 2. Backup/Recovery | Orta | Farklı restore senaryoları için faydalı olabilir | Önce lokal, gerekirse server |
| 3. Security | Düşük | Kullanıcı, rol, audit lokalde gösterilebilir | Lokal |
| 4. Load Balancing | **Yüksek** | Primary-standby, replication, failover ve ağ testleri | Server |
| 5. ETL | Düşük | Tek ortamda veri temizleme ve yükleme rahat yapılır | Lokal |

---

## Çalışma Sırası (Önerilen 5 Aşama)

| Aşama | Odak | Çıktı | Not |
|-------|------|-------|-----|
| 1 | Ortamı kur | Docker, repo, veri seti, klasör yapısı | Önce iskeleti kur |
| 2 | Vize projelerini başlat | Proje 5 (ETL) ve Proje 1 (Performans) | Hızlı sonuç ve çeşitlilik |
| 3 | Raporları eş zamanlı yaz | Her proje için taslak rapor | Raporu sona bırakma |
| 4 | Kanıtları topla | Ekran görüntüsü, ölçüm, log, SQL script | Önce-sonra kanıtları kritik |
| 5 | Videoları çek | En az 10 dk anlatım | Rapor tamamlanınca çek |

---

## Ortak Uygulama İskeleti (Her Proje İçin A→G Akışı)

Her projede aşağıdaki omurga takip edilir. Bu yapı rapor, video ve Git düzenini birebir eşleştirir.

| Adım | Açıklama |
|------|----------|
| **A. Problem Tanımı** | Bu projede neyi göstereceğin net yazılacak |
| **B. Ortam Kurulumu** | DBMS kurulumu, veritabanı, tablo yapısı, örnek veri seti, varsa kullanıcı rolleri |
| **C. Başlangıç Durumu** | Sistemi sorunlu / ham haliyle göster (yavaş sorgu, bozuk veri, yanlış yetki vb.) |
| **D. Uygulama** | İndeks ekleme, sorgu rewrite, backup, restore, rol tanımlama, veri temizleme vb. |
| **E. Sonuç / Kanıt** | Önce-sonra mantığıyla somut fark göster |
| **F. Raporlama** | Ekran görüntüleri, SQL kodları, açıklamalar ve sonuç bölümleriyle teknik rapor |
| **G. Video** | Proje amacı → Ortam → Ne test edildi → Ne düzeltildi → Sonuç |

---

## Ortak Altyapı

- `[ ]` Repo klasör yapısını oluştur (`project-1-performance/` … `project-5-etl/`)
- `[ ]` Her proje klasöründe `sql/`, `report/`, `screenshots/`, `README.md` iskeletini kur
- `[ ]` Docker ortamını hazırla (PostgreSQL, MSSQL, Oracle container'ları)
- `[ ]` Ortak rapor şablonunu oluştur (aşağıdaki 10 başlıklı format)
- `[ ]` `.gitignore` düzenle

---

## Vize Projeleri

### Proje 5 — Veri Temizleme ve ETL Süreçleri (PostgreSQL)

**Amaç:** Kirli veriyi temizlemek, standartlaştırmak ve hedef tabloya/şemaya yüklemek.

**Gösterilecek Problemler:** Eksik değer · yanlış format · mükerrer kayıt · tutarsız isimlendirme · bozuk tarih ve telefon alanları.

**Kanıt:** Ham veri ve temiz veri karşılaştırması, ETL adımları, quality report, dönüşüm kuralları.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` PostgreSQL container kur
- `[ ]` Veritabanı ve tablo yapısını oluştur
- `[ ]` Ham veri seti al / oluştur

**C. Başlangıç Durumu**
- `[ ]` Kirli veriyi staging tabloya yükle
- `[ ]` Sorunları göster (NULL, duplikasyon, format hataları)

**D. Uygulama**
- `[ ]` Temizlik scriptleri yaz (NULL, duplikasyon, format)
- `[ ]` Veri dönüştürme kurallarını uygula
- `[ ]` Hedef tabloya yükleme (ETL pipeline)

**E. Sonuç / Kanıt**
- `[ ]` Kalite raporu çıkar (ham vs temiz karşılaştırma)
- `[ ]` Önce-sonra ekran görüntüleri al

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

### Proje 1 — Veritabanı Performans Optimizasyonu ve İzleme (MSSQL)

**Amaç:** Yavaş sorguları tespit etmek, indeks ve sorgu iyileştirmesi uygulamak, izleme araçlarıyla önce-sonra farkını göstermek.

**Gösterilecek Problemler:** Yavaş SELECT sorguları · gereksiz indeksler · eksik indeksler · kötü filtreleme · yüksek IO / uzun execution süresi.

**Kanıt:** Önce-sonra sorgu süreleri, execution plan görüntüleri, kullanılan index listesi, kısa performans özeti.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` MSSQL container kur (Apple Silicon → `azure-sql-edge`)
- `[ ]` Örnek veritabanı oluştur; büyük tablo + yapay veri ekle

**C. Başlangıç Durumu**
- `[ ]` Yavaş sorguları ölç (baseline)
- `[ ]` Execution plan görüntülerini al (önce)

**D. Uygulama**
- `[ ]` İndeks ekleme / çıkarma denemeleri
- `[ ]` Sorgu rewrite
- `[ ]` Profiler / DMV ile gözlem al

**E. Sonuç / Kanıt**
- `[ ]` Önce-sonra sorgu sürelerini karşılaştır
- `[ ]` Execution plan görüntüleri (sonra)
- `[ ]` Kullanılan index listesi ve performans özeti

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

## Final Projeleri

### Proje 2 — Veritabanı Yedekleme ve Felaketten Kurtarma (PostgreSQL)

**Amaç:** Yedek alma, veri kaybı senaryosu oluşturma ve geri dönüş sürecini göstermek.

**Gösterilecek Problemler:** Yanlışlıkla veri silinmesi · bozulmuş tablo senaryosu · manuel backup sürecinin yetersizliği.

**Kanıt:** Backup dosyaları, restore sonrası veri bütünlüğü, senaryo bazlı kurtarma açıklaması, ekran görüntüleri.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` PostgreSQL container kur
- `[ ]` Veritabanı oluştur ve örnek veri yükle

**C. Başlangıç Durumu**
- `[ ]` Manuel backup yetersizliğini göster

**D. Uygulama**
- `[ ]` Tam yedek (full backup) al — `pg_dump --format=custom`
- `[ ]` Zamanlanmış yedek mantığı kur
- `[ ]` Veri silme senaryosu oluştur
- `[ ]` Silinen veriyi geri getir (restore)
- `[ ]` Farklı restore denemeleri
- `[ ]` Point-in-time recovery mantığını açıkla / uygula

**E. Sonuç / Kanıt**
- `[ ]` Backup dosyaları ve restore sonrası bütünlük kanıtı
- `[ ]` Senaryo bazlı kurtarma ekran görüntüleri

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

### Proje 3 — Veritabanı Güvenliği ve Erişim Kontrolü (Oracle)

**Amaç:** Kullanıcı yetkileri, roller, hassas veri koruması ve aktivite izlemesini göstermek.

**Gösterilecek Problemler:** Aşırı yetkili kullanıcı · korumasız hassas veri alanları · audit kapalı ortam · rol ayrımının olmaması.

**Kanıt:** Yetki verilen ve engellenen kullanıcı örnekleri, audit çıktıları, güvenlik farkı gösteren önce-sonra tablosu.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` Oracle container kur (`gvenzl/oracle-xe` — ~8GB+, erken pull)
- `[ ]` Veritabanı ve tablo yapısını oluştur
- `[ ]` Örnek veri yükle

**C. Başlangıç Durumu**
- `[ ]` Aşırı yetkili kullanıcı / korumasız veri / audit kapalı durumu göster

**D. Uygulama**
- `[ ]` Kullanıcı ve rol tanımları oluştur
- `[ ]` Tablo bazlı yetki verme / kısıtlama
- `[ ]` Hassas alanlarda koruma yaklaşımı (masking / encryption)
- `[ ]` Audit / aktivite izleme aç
- `[ ]` Güvenlik test senaryosu çalıştır

**E. Sonuç / Kanıt**
- `[ ]` Yetki verilen ve engellenen kullanıcı örnekleri
- `[ ]` Audit çıktıları
- `[ ]` Önce-sonra güvenlik farkı tablosu

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

### Proje 4 — Veritabanı Yük Dengeleme ve Dağıtık Yapılar (PostgreSQL)

**Amaç:** Replication, standby, failover ve temel yük dağıtımı mantığını gerçek bir senaryo halinde göstermek.

**Gösterilecek Problemler:** Tek sunucu bağımlılığı · failover eksikliği · okuma yükünün tek node üzerinde kalması.

**Kanıt:** Node diyagramı, replication çalıştığını gösteren veri kanıtı, failover testi, kısa uptime / davranış özeti.

> ⚠️ Bu proje diğerlerinden daha fazla ortam ve test gerektirir. Erken prototip çıkarmak önemlidir.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` Debian sunucuyu hazırla (veya multi-container Docker Compose)
- `[ ]` En az 2 PostgreSQL node kur (primary + standby)

**C. Başlangıç Durumu**
- `[ ]` Tek sunucu bağımlılığını ve failover eksikliğini göster

**D. Uygulama**
- `[ ]` Streaming replication yapılandır
- `[ ]` Veri çoğaltmayı doğrula
- `[ ]` Failover testi (primary'yi kapat, standby promote)
- `[ ]` Read replica / temel load balancing mantığı

**E. Sonuç / Kanıt**
- `[ ]` Replication çalıştığını gösteren veri kanıtı
- `[ ]` Failover test sonuçları
- `[ ]` Node diyagramı
- `[ ]` Uptime / davranış özeti

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

## Rapor Şablonu (10 Başlık — Her Proje İçin)

Her proje raporunda aynı başlıkları kullanmak profesyonel görünüm sağlar ve video ile birebir eşleşir.

1. Projenin amacı
2. Kullanılan platform ve araçlar
3. Kullanılan veri seti / veritabanı
4. Başlangıç durumu
5. Yapılan işlemler
6. Kullanılan SQL komutları ve açıklamaları
7. Ekran görüntüleri
8. Elde edilen sonuçlar
9. Karşılaşılan problemler ve çözümleri
10. Sonuç ve değerlendirme

---

## Video Anlatım Şablonu (Her Proje İçin)

1. **Açılış:** Proje başlığı, amaç ve hangi veritabanının kullanıldığı
2. **Kurulum özeti:** Container, tablo, veri seti, kullanıcılar
3. **Başlangıç sorunu:** Ne bozuktu veya ne eksikti?
4. **Uygulanan çözüm adımları**
5. **Sonuç:** Önce-sonra karşılaştırması
6. **Kapanış:** Kısa değerlendirme ve öğrenilen teknik noktalar

> Video süresi: **en az 10 dakika**.

---

## Teslim Çıktıları (Her Proje İçin)

| Çıktı | Açıklama |
|-------|----------|
| **Rapor** | 10 başlıklı teknik rapor (yukarıdaki şablon) |
| **Video** | ≥ 10 dk anlatım (yukarıdaki şablon) |
| **SQL Scriptleri** | Numaralı, açıklamalı dosyalar halinde `sql/` altında |
| **Ekran Görüntüleri** | Başlıklarla isimlendirilmiş, `screenshots/` altında |
| **README** | Proje özeti + video linki |
| **Git Geçmişi** | Her anlamlı adım için küçük commit |

---

## Riskler ve Hatırlatmalar

- Proje 4 erken prototip ister — ortam kurulumunu sona bırakma.
- Oracle container imageları büyük (~8GB+). Erken pull et.
- MSSQL Apple Silicon'da `azure-sql-edge` image gerektirir.
- Rapor ve Git işini sona bırakmak en büyük hata — süreç boyunca küçük commitlerle ilerle.
- **Her projede önce-sonra farkını somut kanıtla göstermek en kritik unsur.**

---

## Son Karar Özeti

- **Seçilen projeler:** 1, 2, 3, 4, 5
- **DBMS dağılımı:** P1 → MSSQL, P2 → PostgreSQL, P3 → Oracle, P4 → PostgreSQL, P5 → PostgreSQL
- **Vize:** Proje 5 (ETL) + Proje 1 (Performans)
- **Final:** Proje 2 (Backup) + Proje 3 (Güvenlik) + Proje 4 (Load Balancing)
- **Debian sunucu:** Özellikle Proje 4 için hazır tutulacak; diğerleri lokal
