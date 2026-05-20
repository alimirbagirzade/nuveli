# 💥 FAZ 6 — Load & Stress Test Plan

**Tarih:** Pre-launch
**Beklenen süre:** 2-3 saat
**Hedef:** Production'da kapasite limiti bilmek

---

## 🛠️ Tooling Setup

### k6 (Load testing)
```bash
brew install k6
# veya download: https://k6.io/docs/getting-started/installation/
```

### Flutter DevTools (Memory profiling)
```bash
# Profile build başlat
flutter run --profile

# Sonra ayrı terminal:
dart devtools
# Tarayıcıda http://localhost:9100 — Memory tab
```

---

## 6.1 Backend Load Test (k6)

**Dosya:** `launch_audit/FAZ_6_LOAD_STRESS/load_test.js`

Aşağıdaki k6 script'ini bu dosyaya kaydet, sonra:
```bash
export TEST_TOKEN="<paste real JWT from a test user>"
k6 run --vus 50 --duration 5m load_test.js
```

### Hedefler
- p95 latency < 2000ms
- Error rate < 1%
- 100 concurrent user sustain edebilmeli
- Render free tier dayanıyor mu (kafa sayısı: hayır, ücretli plan gerekli olabilir)

### Senaryo
3 farklı endpoint'i test et:
1. `GET /me` — auth dependency stres
2. `GET /meals/today/summary` — DB query stres
3. `GET /analytics/dashboard` — aggregation stres

---

## 6.2 Database Stress

```sql
-- Supabase SQL Editor'da çalıştır
-- (1) Slow query identification (pg_stat_statements aktif olmalı)
SELECT 
  query,
  calls,
  total_exec_time::int AS total_ms,
  mean_exec_time::int AS mean_ms,
  rows
FROM pg_stat_statements
WHERE query ILIKE '%meals%' OR query ILIKE '%water%'
ORDER BY mean_exec_time DESC
LIMIT 20;
-- Hedef: mean_ms < 100 her satırda. 200+ varsa index ekle.

-- (2) Index kontrolü
SELECT schemaname, tablename, indexname FROM pg_indexes
WHERE schemaname = 'public' ORDER BY tablename;
-- Beklenen: her tabloda user_id üzerinde index OLMALI.

-- (3) EXPLAIN ANALYZE — dashboard query
EXPLAIN ANALYZE
SELECT m.*, SUM(mf.calories) AS total_cal
FROM meals m
LEFT JOIN meal_foods mf ON mf.meal_id = m.id
WHERE m.user_id = '<test_user_id>' AND DATE(m.consumed_at) = CURRENT_DATE
GROUP BY m.id;
-- Beklenen: Index Scan (Sequential Scan değil). Total < 50ms.
```

---

## 6.3 OpenAI Rate Limit

```bash
# 50 paralel meal scan request (ayrı script)
# Buradaki TOKEN'ı premium test user'ından al
export TOKEN="..."
export IMG="$(base64 < test_meal.jpg | tr -d '\n')"

for i in {1..50}; do
  (curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_base64\":\"$IMG\"}" \
    -w "%{http_code} %{time_total}s\n" \
    https://nuveli-api.onrender.com/meals/scan) &
done
wait
```

**Beklen:**
- Çoğu 200, bazıları 429 → OK (rate limit aktif)
- Tümü 500 → backend hatası
- Tümü 200 ama latency uçuyor → OpenAI tier upgrade gerekli

---

## 6.4 Memory Profiling

```bash
flutter run --profile -d <device>
# DevTools → Memory tab → "Snapshot"

# Snapshot sequence:
# 1. App açıldı, login öncesi → Snapshot 1
# 2. Login + dashboard yüklendi → Snapshot 2
# 3. 5 dakika gezinti (meal scan, water, habit) → Snapshot 3
# 4. Settings → back to dashboard → Snapshot 4

# Diff Snapshot 3 vs Snapshot 1 → growth (MB)
```

### Hedefler
- Baseline: < 100 MB
- Heavy: < 200 MB
- Leak: 5 dk gezindikten sonra memory sabit kalmalı (delta < 20 MB)

---

## 6.5 Battery Drain

```
1. Cihaz pil %100, app kapalı
2. Saat ayarla
3. App aç, 30 dakika aktif kullan:
   - 5 meal scan
   - 10 water +250ml
   - 5 habit complete
   - 10 sekme geçişi
4. Saat ve pil yüzdesini not al
```

**Hedef:** 30 dakika = %3-5 düşüş.
**Sorun:** %15+ düşüş → background polling kontrol, sensor leak.

---

## 6.6 Cold Start

```bash
# iOS
flutter build ios --release --trace-startup
open build/ios/iphoneos/Runner.app

# Android
flutter build apk --release --trace-startup
# install + open
```

**Output:** `build/start_up_info.json`

**Hedefler:**
- timeToFirstFrameRasterized < 1500ms
- timeToFrameworkInit < 800ms

**Improvement actions:**
- Sentry, Firebase init'lerini post-first-frame'e taşı
- Splash daha uzun göster, ana ekrana smooth geçiş

---

## Results Template

```
k6 Load Test:
- p95 latency: __ ms (hedef: <2000)
- Error rate: __ % (hedef: <1)
- Max concurrent: __ (hedef: 100)

DB Stress:
- Slowest mean_ms: __
- Missing indexes: __ tane

OpenAI Rate Limit:
- 50 parallel: __ × 200, __ × 429, __ × 5xx

Memory:
- Baseline: __ MB
- Heavy: __ MB
- Leak after 5min: __ MB delta

Battery:
- 30min drain: __ % (hedef: 3-5%)

Cold Start:
- timeToFirstFrame: __ ms (hedef: <1500)
```

**Pre-Launch Bar:** Tüm hedefler tutuldu = GO. 2+ hedef miss = optimization sprint.
