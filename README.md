# Nuveli — Chat 11b Çıktıları

**Tarih:** 18 Mayıs 2026
**Chat:** 11b — AI Coach Backend
**Hazırlayan:** Claude (Anthropic) + Ali

---

## 📦 Bu klasör ne içeriyor?

Chat 11b kapsamında üretilen tüm dosyalar. Bunları `~/Development/nuveli/` klasörüne kopyala.

### Yapı
```
nuveli/
├── backend/                                   # FastAPI backend (yeni dosyalar)
│   ├── routers/ai_coach.py                   # GET /coach/today + POST /coach/generate
│   ├── services/
│   │   ├── nutrition_score_service.py        # 40+30+15+15=100 algoritması
│   │   ├── insights_generation_service.py    # GPT-4o entegrasyonu
│   │   ├── coach_cache_service.py            # Supabase ai_insights okuma/yazma
│   │   └── user_context_service.py           # Son 7 gün veri toplama
│   ├── models/coach_response.py              # Pydantic response modelleri
│   ├── prompts/coach_prompts.py              # Daily insight + fallback
│   ├── cron/daily_insights_job.py            # Gece çalışan job
│   ├── migrations/002_ai_insights_table.sql  # Supabase migration
│   ├── tests/test_ai_coach.py                # 25 test (network'siz)
│   ├── main_snippet.py                       # Mevcut main.py'ye eklenecek
│   ├── requirements.txt                      # openai==1.51.0 eklendi
│   └── .env.example                          # Env var template
│
├── app/lib/features/ai_coach/providers/
│   └── ai_coach_provider.dart                # Backend'e bağlandı (kMockMode=false)
│
├── assets/
│   └── nuveli_logo.png                       # Yeni logo (Chat 12+'ta kullanılır)
│
└── DEPLOY_GUIDE.md                           # ⭐ ADIM ADIM KURULUM
```

---

## 🚀 Nereden Başlamalı?

**1. `DEPLOY_GUIDE.md` dosyasını oku.**

Tüm adımlar orada — Supabase migration, env vars, Render deploy, cron kurulumu, Flutter mock mode kapatma.

---

## ✅ Hızlı Doğrulama (5 dakika)

```bash
# Dosyaları yerine koy
cp -r nuveli/* ~/Development/nuveli/

# Backend test (network'siz)
cd ~/Development/nuveli/backend
pip install -r requirements.txt --break-system-packages  # ya da venv kullan
pytest tests/test_ai_coach.py -v

# Beklenen: 25 passed
```

---

## 📊 Ne Çalışıyor?

✅ **Nutrition Score** algoritması (deterministic, test'li)
✅ **GPT-4o insights** üretimi (fallback'li, schema validation'lı)
✅ **Supabase cache** (günde 1 kez üret, sonra cache'ten oku)
✅ **Cron job** (gece tüm aktif kullanıcılar için yeniden üret)
✅ **Flutter provider** backend'e bağlı (kMockMode toggle ile)
✅ **25 unit test** geçiyor

## 🔜 Daha Sonra Yapılacak (Chat 16+)

- Gerçek Supabase JWT doğrulama (şu an X-User-Id dev header'ı)
- Apply Tip için habit/meal otomatik ekleme
- Dashboard ↔ AI Coach state birleştirme (TodaysMacros'u tek noktadan al)
- Multi-language insight prompt (kullanıcı dil tercihine göre)
- Cron job için Sentry / monitoring

---

**Detaylar için → [DEPLOY_GUIDE.md](DEPLOY_GUIDE.md)**
