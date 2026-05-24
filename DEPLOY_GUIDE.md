# 🚀 Nuveli — Chat 11b Deploy Guide

**Chat:** 11b — AI Coach Backend
**Tarih:** 18 Mayıs 2026
**Önkoşul:** Chat 11a tamamlandı (Flutter UI mock mode'da çalışıyor)

---

## 📋 İçindekiler
1. [Dosyaları yerine koy](#1-dosyaları-yerine-koy)
2. [Supabase migration çalıştır](#2-supabase-migration-çalıştır)
3. [Lokal test (backend)](#3-lokal-test-backend)
4. [Render env vars güncelle](#4-render-env-vars-güncelle)
5. [Render'a deploy](#5-rendera-deploy)
6. [Cron job kurulumu](#6-cron-job-kurulumu)
7. [Flutter mock mode'u kapat](#7-flutter-mock-modeu-kapat)
8. [Doğrulama testleri](#8-doğrulama-testleri)

---

## 1. Dosyaları yerine koy

İndirdiğin zip'i `~/Development/nuveli/` altında aç. Yapı:

```
~/Development/nuveli/
├── backend/
│   ├── routers/ai_coach.py             ✨ YENİ
│   ├── services/
│   │   ├── nutrition_score_service.py  ✨ YENİ
│   │   ├── insights_generation_service.py ✨ YENİ
│   │   ├── coach_cache_service.py      ✨ YENİ
│   │   └── user_context_service.py     ✨ YENİ
│   ├── models/coach_response.py        ✨ YENİ
│   ├── prompts/coach_prompts.py        ✨ YENİ
│   ├── cron/daily_insights_job.py      ✨ YENİ
│   ├── migrations/002_ai_insights_table.sql ✨ YENİ
│   ├── tests/test_ai_coach.py          ✨ YENİ
│   ├── main_snippet.py                 ℹ️ Mevcut main.py'ye ekle
│   ├── requirements.txt                🔄 GÜNCELLENDİ (openai==1.51.0 eklendi)
│   └── .env.example                    🔄 GÜNCELLENDİ
├── app/lib/features/ai_coach/providers/
│   └── ai_coach_provider.dart          🔄 GÜNCELLENDİ (kMockMode=false)
└── assets/
    └── nuveli_logo.png                 ✨ YENİ (Chat 12+'da kullanılacak)
```

**Eylem adımları:**
```bash
cd ~/Development/nuveli

# 1. Backend kısmı: zip'ten gelen dosyaları yerlerine koy
#    (zip yapısı zaten doğru, kopyala)

# 2. Mevcut main.py'ye satırları ekle (main_snippet.py'ye bak)
#    - "from routers import ai_coach"
#    - "app.include_router(ai_coach.router)"

# 3. __init__.py dosyalarının var olduğunu doğrula
ls backend/routers/__init__.py
ls backend/services/__init__.py
ls backend/models/__init__.py
ls backend/prompts/__init__.py
ls backend/cron/__init__.py

# Yoksa oluştur:
touch backend/{routers,services,models,prompts,cron,tests}/__init__.py
```

---

## 2. Supabase migration çalıştır

### Seçenek A — Supabase Dashboard (önerilen, hızlı)

1. https://supabase.com/dashboard → **nuveli-dev** projesini aç
2. Sol menü → **SQL Editor**
3. **New query** → `backend/migrations/002_ai_insights_table.sql` içeriğini yapıştır
4. **Run** butonuna bas
5. Sol menü → **Table Editor** → `ai_insights` tablosunun göründüğünü doğrula

### Seçenek B — Supabase CLI

```bash
cd ~/Development/nuveli
npx supabase login
npx supabase link --project-ref asicgcnpahdnitzalcva
npx supabase db push
```

### Doğrulama
SQL Editor'da çalıştır:
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ai_insights';
```

Beklenen: `id`, `user_id`, `date`, `nutrition_score`, `main_insight`, `small_insights`, `recommendation`, `daily_recap`, `model_version`, `generated_at`, `updated_at` kolonları.

---

## 3. Lokal test (backend)

### 3.1 Environment hazırla
```bash
cd ~/Development/nuveli/backend

# .env dosyasını oluştur (1Password'dan al)
cp .env.example .env
nano .env  # gerçek değerleri yaz: SUPABASE_*, OPENAI_API_KEY, ...
```

### 3.2 Bağımlılıkları yükle
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3.3 Testleri çalıştır
```bash
pytest tests/test_ai_coach.py -v
```

Beklenen: **25 passed**. Bunlar network'e çıkmıyor, OpenAI çağrısı mock'lu.

### 3.4 Servisi ayağa kaldır
```bash
uvicorn main:app --reload --port 8000
```

### 3.5 Endpoint'leri test et
```bash
# Sağlık
curl http://localhost:8000/coach/health

# Bugünün insights'ı (X-User-Id header ile dev mode)
# İlk çağrı: cache miss → GPT-4o tetiklenir (~2-4 saniye)
curl -H "X-User-Id: dev-user-1" http://localhost:8000/coach/today | jq

# İkinci çağrı: cache hit → instant
curl -H "X-User-Id: dev-user-1" http://localhost:8000/coach/today | jq '.cached'
# beklenen: true

# Manuel yenileme (force=true → cache bypass)
curl -X POST \
  -H "X-User-Id: dev-user-1" \
  -H "Content-Type: application/json" \
  -d '{"force": true}' \
  http://localhost:8000/coach/generate | jq
```

### 3.6 Cron job lokalde dene
```bash
cd ~/Development/nuveli/backend
python -m cron.daily_insights_job
```

Beklenen çıktı: aktif kullanıcı sayısı + kaç başarılı/başarısız.

---

## 4. Render env vars güncelle

Render Dashboard:
1. https://dashboard.render.com → **Nuveli-api** servisi
2. **Environment** sekmesi
3. Şu var'ları kontrol et / ekle:

| Key | Değer | Kaynak |
|-----|-------|--------|
| `APP_ENV` | `production` | Sabit |
| `SUPABASE_URL` | `https://asicgcnpahdnitzalcva.supabase.co` | Credentials guide |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGci...` | Supabase → API → service_role |
| `SUPABASE_JWT_SECRET` | `792108ee-...` | Supabase → API → JWT Secret |
| `OPENAI_API_KEY` | `sk-proj-...` | OpenAI → API Keys |
| `CRON_SECRET` | Yeni random string | `openssl rand -hex 32` |

`OPENAI_API_KEY` muhtemelen zaten var (Chat 5'ten meal scan için kullanılıyordu) — kontrol et.

4. **Save Changes** → otomatik redeploy başlar.

---

## 5. Render'a deploy

### Otomatik (GitHub'a push)
```bash
cd ~/Development/nuveli
git checkout -b feature/chat-11b-ai-coach-backend
git add backend/ app/ assets/
git commit -m "feat(chat-11b): AI Coach backend — GPT-4o insights + cache + cron"
git push origin feature/chat-11b-ai-coach-backend

# PR aç → main'e merge'le → Render otomatik deploy
```

Render dashboard'ta:
- Build log → `pip install -r requirements.txt` başarılı mı?
- Live → `https://nuveli-api.onrender.com/coach/health` 200 dönüyor mu?

### Manuel deploy
Render dashboard → Nuveli-api → **Manual Deploy** → **Deploy latest commit**.

---

## 6. Cron job kurulumu

İki seçenek var.

### Seçenek A — Render Cron Job (paid, $7/ay)
1. Render dashboard → **New +** → **Cron Job**
2. Doldur:
   - **Name:** nuveli-daily-insights
   - **Schedule:** `30 0 * * *` (her gece 00:30 UTC)
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `python -m cron.daily_insights_job`
   - **Repo:** alimirbagirzade/nuveli
   - **Branch:** main
   - **Root Directory:** `backend`
3. Aynı env var'ları gir (SUPABASE_*, OPENAI_API_KEY)
4. **Create Cron Job**

### Seçenek B — GitHub Actions (free, önerilen)

Repo'ya bu dosyayı ekle: `.github/workflows/daily-insights.yml`

```yaml
name: Daily AI Insights

on:
  schedule:
    # Her gece 00:30 UTC (Türkiye için 03:30)
    - cron: '30 0 * * *'
  workflow_dispatch:  # Manuel trigger için

jobs:
  generate-insights:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        working-directory: backend
        run: pip install -r requirements.txt

      - name: Run job
        working-directory: backend
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: python -m cron.daily_insights_job
```

GitHub repo settings → **Secrets and variables** → **Actions** → secrets'ları ekle.

İlk manuel tetikleme: Actions tab → Daily AI Insights → Run workflow.

---

## 7. Flutter mock mode'u kapat

```bash
cd ~/Development/nuveli/app/lib/features/ai_coach/providers
```

`ai_coach_provider.dart` dosyasında:
```dart
const bool kMockMode = false;  // Chat 11b sonrası
```

Eğer lokal backend'e bağlanmak istersen:
```bash
flutter run --dart-define=NUVELI_BACKEND_URL=http://localhost:8000
```

Aksi halde production'a (Render) bağlanır.

---

## 8. Doğrulama testleri

### Backend
```bash
# 1. Health check
curl https://nuveli-api.onrender.com/coach/health
# beklenen: {"status":"ok","service":"ai_coach",...}

# 2. Auth gerektiriyor mu?
curl https://nuveli-api.onrender.com/coach/today
# beklenen: 401 Unauthorized

# 3. Dev user ile
curl -H "X-User-Id: dev-user-1" https://nuveli-api.onrender.com/coach/today
# beklenen: 200 JSON response
```

### Supabase
```sql
-- Cache'lenmiş kayıtları gör
SELECT user_id, date, nutrition_score->>'value' as score, generated_at
FROM ai_insights
ORDER BY generated_at DESC
LIMIT 10;
```

### Flutter
1. App'i çalıştır → AI Coach ekranını aç
2. Loading state göründü mü? (skeleton)
3. Score halkası 0'dan animasyonla yükseldi mi?
4. Apply Tip butonu tıklanınca disable mi oluyor?
5. Pull-to-refresh çalışıyor mu? (yeni eklenecekse)

---

## ✅ Chat 11b Tamamlandı Checklist

- [ ] `002_ai_insights_table.sql` Supabase'de çalıştırıldı
- [ ] Tüm 25 backend testi geçti (`pytest -v`)
- [ ] Render env vars güncel (OPENAI_API_KEY dahil)
- [ ] `GET /coach/today` lokalde 200 döndü
- [ ] `POST /coach/generate` cache'i bypass etti
- [ ] Cron job kuruldu (Render veya GH Actions)
- [ ] Flutter `kMockMode = false` → app real backend'e bağlandı
- [ ] Görsel 8 ekranı GPT-4o'dan gelen insights ile dolduruluyor

---

## 🚨 Sorun Giderme

| Hata | Çözüm |
|------|-------|
| `OPENAI_API_KEY env var not set` | Render env vars'a ekle ve redeploy |
| `Authentication failed` (Supabase) | SERVICE_ROLE_KEY doğru mu? RLS bypass edebiliyor mu? |
| `ai_insights table does not exist` | Migration çalıştırılmadı → adım 2'ye dön |
| GPT-4o yanıtı parse edilemiyor | Loglara bak: `_validate_schema` false dönüyorsa fallback kullanılıyor |
| Cron job başarısız (Render) | Free tier 750 saat limiti aşıldı mı? Plan upgrade |
| Flutter 401 alıyor | `X-User-Id` header'ı set ediliyor mu? Chat 16'a kadar dev mode |
| OpenAI bütçesi aşılırsa | https://platform.openai.com/settings/organization/limits → $5 limit |

---

## 📊 Maliyet Tahmini (Chat 11b)

**OpenAI GPT-4o kullanımı:**
- Her insight ~600 input token + ~400 output token = ~1000 token
- gpt-4o: $2.50/M input + $10/M output → kullanıcı başına günde ~$0.0055
- 100 aktif kullanıcı × 30 gün = $16.50/ay
- 1000 aktif kullanıcı × 30 gün = $165/ay

**Render:**
- Free tier (750 saat/ay) yeterli olur, cron paid plan ($7/ay) opsiyonel
- GH Actions cron → free

**Supabase:**
- ai_insights tablosu çok küçük (kullanıcı × gün × ~5KB)
- Free tier 500MB yeterli

**Toplam başlangıç:** ~$20/ay (100 user senaryosu)

---

## 🎉 Sonraki Adım: Chat 12

**Tüm 8 ekran tamamlandı!**
Sıradaki: **Chat 12 — Navigation & Routing** (`go_router` ile tüm ekranları birleştir, bottom nav çalışsın).

Master plan'da Chat 11 işaretini ✅ olarak güncelle.
