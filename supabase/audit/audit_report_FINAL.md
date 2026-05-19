# Nuveli Supabase Audit & Cleanup Raporu

**Tarih:** 2026-05-18 — 2026-05-19
**Yapan:** Ali (Claude eşliğinde)
**Chat:** 12 — Supabase Audit & Cleanup
**Project:** nuveli-dev (`asicgcnpahdnitzalcva`)

---

## 🎯 Hedef

Eski projeden kalma 22 tablo + bağımlılıklarını silmek, Nuveli için temiz `public` schema bırakmak.

## 📋 Başlangıç Durumu (Audit)

| Obje türü | Adet |
|---|---|
| Tablolar (public) | 22 (hepsi boş) |
| Views | 0 |
| User-defined functions | 6 |
| Triggers | 11 |
| RLS Policies | 27 |
| Index'ler (pkey hariç) | 24 |
| Storage buckets | 2 (`avatars`: 2 dosya, `coach-audio`: 0) |
| auth.users | 1 (test hesabı, dokunulmadı) |
| Extensions (public'te) | 0 ✓ |

### Silinmesi gereken 22 tablo

```
ai_insights, coach_messages, coach_preferences, coach_threads,
daily_checkins, daily_summaries, deletion_requests,
device_push_tokens, device_tokens, meal_analysis_results,
meal_logs, notification_logs, notification_preferences,
premium_status_cache, profiles, safety_acknowledgements,
safety_events, safety_flags, usage_counters_daily,
water_logs, weekly_insights, weight_logs
```

## ⚙️ Uygulanan Strateji

**A) Nükleer reset** — `DROP SCHEMA public CASCADE` + `CREATE SCHEMA public` + permission restore.

Veri kaybı riski yoktu (tablolar boş), bu yüzden backup atlandı. Önce ekstension'ların `public` dışında olduğu doğrulandı (pre-check), sonra ana cleanup çalıştırıldı.

### Akış

1. ✅ Audit script'leri (`01_full_audit.sql`, `02_data_count_check.sql`) — hepsini gör
2. ✅ Satır sayıları kontrol — 22'nin 22'si boş, backup gereksiz
3. ✅ Pre-check (`03_pre_check_extensions.sql`) — 5 extension'ın hiçbiri public'te değil
4. ✅ Storage UI temizliği — `avatars` ve `coach-audio` bucket'ları silindi
5. ✅ Nükleer cleanup (`000_cleanup_old_schema.sql`) — `Success. No rows returned`
6. ✅ Doğrulama — tüm sayaçlar 0, sadece `auth_users = 1`

### Karşılaşılan hata + çözüm

İlk versiyonda Aşama 3'te storage'dan SQL DELETE denedi → Supabase'in `storage.protect_delete()` trigger'ı engelledi → tüm transaction ROLLBACK oldu (BEGIN/COMMIT sayesinde) → veri kaybı yok. v2'de storage SQL'den çıkarıldı, manuel UI üzerinden silindi.

## ✅ Final Durum

```
auth_users       | 1    ← korundu
functions        | 0
indexes_non_pkey | 0
policies         | 0
storage_buckets  | 0
storage_objects  | 0
tables           | 0
triggers         | 0
views            | 0
```

## 🛡️ Korunan / Dokunulmayan

- `auth.*` — Supabase Auth, managed
- `storage.*` — tablo yapısı (sadece bucket içerikleri silindi)
- `extensions.*` — `pgcrypto`, `uuid-ossp`, `pg_stat_statements`
- `vault.*` — `supabase_vault`
- `pg_catalog.plpgsql`

## 📦 Üretilen Artifact'lar

```
supabase/
├── audit/
│   ├── 01_full_audit.sql              ← şema envanteri
│   ├── 02_data_count_check.sql        ← satır sayıları (DO block, Messages'a yazar)
│   ├── 03_pre_check_extensions.sql    ← extension lokasyon kontrolü
│   └── audit_report_FINAL.md          ← bu dosya
├── backup/
│   └── backup_instructions.md         ← pg_dump rehberi (kullanılmadı, referans için)
└── migrations/
    └── 000_cleanup_old_schema.sql     ← nükleer cleanup (uygulandı)
```

## 🔜 Sonraki Adım

**Chat 13 — Supabase Schema Setup**
Nuveli'nin 10 tablosu (`user_profiles`, `meals`, `weight_logs`, `water_logs`, `meal_plans`, `recipes`, `habits`, `habit_completions`, `ai_insights`, `user_achievements`) + RLS policies + indexes + Supabase Auth trigger (yeni user → profil otomatik oluştur).
