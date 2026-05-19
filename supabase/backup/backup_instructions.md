# Backup Talimatları

**Ne zaman gerekli?**
Audit sonrası eski tablolarda anlamlı veri varsa (test verisi değil, gerçek kullanıcı verisi gibi) — silmeden önce backup şart.

---

## Seçenek A — pg_dump (Önerilen, ücretsiz)

### 1) Connection string'i al
```
Supabase Dashboard → Project Settings → Database → Connection string → URI tab
```
Şuna benzer bir satır göreceksin:
```
postgresql://postgres:[PASSWORD]@db.asicgcnpahdnitzalcva.supabase.co:5432/postgres
```
`[PASSWORD]` yerine gerçek DB şifresini koy.

### 2) pg_dump kurulu mu?

**macOS:**
```bash
brew install libpq
brew link --force libpq
```

**Linux:**
```bash
sudo apt install postgresql-client
```

### 3) Backup al
```bash
# Schema + veri (public schema)
pg_dump "postgresql://postgres:[PASSWORD]@db.asicgcnpahdnitzalcva.supabase.co:5432/postgres" \
  --schema=public \
  --no-owner \
  --no-acl \
  -f ~/Development/nuveli/supabase/backup/nuveli_backup_$(date +%Y%m%d_%H%M).sql

# Sadece veri (DDL olmadan, küçük dosya)
pg_dump "postgresql://postgres:[PASSWORD]@db.asicgcnpahdnitzalcva.supabase.co:5432/postgres" \
  --schema=public \
  --data-only \
  --no-owner \
  -f ~/Development/nuveli/supabase/backup/nuveli_data_$(date +%Y%m%d_%H%M).sql
```

### 4) Backup gerçekten dolu mu kontrol et
```bash
ls -lh ~/Development/nuveli/supabase/backup/
head -50 ~/Development/nuveli/supabase/backup/nuveli_backup_*.sql
# Dosya boyutu > 1KB olmalı; INSERT veya COPY satırları görmeli
```

### 5) .gitignore'a ekle
```bash
echo "supabase/backup/*.sql" >> ~/Development/nuveli/.gitignore
```
**Backup dosyaları git'e ASLA gitmez** — production verisi içerebilir.

---

## Seçenek B — Supabase Dashboard Backup

> Sadece **Pro plan** ($25/ay) ile mevcut. Free plan'de yok.

```
Dashboard → Database → Backups → "Create backup now"
```

---

## Seçenek C — Tek Tablo CSV Export

Sadece 1-2 tablo backup'lamak istiyorsan:
```
Supabase Dashboard → Table Editor → ilgili tablo →
  ⋯ (üç nokta) → Export data → CSV
```

---

## Sonraki Adım

Backup tamamlandıktan sonra Claude'a şunu söyle:
> "Backup aldım, dosya boyutu X MB, içinde gerçek veri var. Cleanup SQL'ini üretebilirsin."

Bu mesaj olmadan Claude DROP SQL üretmeyecek.
