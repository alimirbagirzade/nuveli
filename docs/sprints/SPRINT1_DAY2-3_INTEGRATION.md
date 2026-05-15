# Sprint 1 Gün 2-3 Çıktıları — Entegrasyon Rehberi

**Tarih:** 1 Mayıs 2026
**Sprint:** AI Pipeline Wire-Up

Bu paket Sprint 1 Gün 2-3 deliverable'larını içerir. Mevcut repodaki dosyalarla **diff'leyerek** entegre etmen gerekiyor — direkt üzerine yazma, çünkü mevcut implementasyonun bilmediğim detayları olabilir.

## Paket İçeriği

```
backend/
├── migrations/
│   ├── 010_premium_and_usage_tables.sql       (YENİ)
│   ├── 011_daily_checkins_and_safety.sql      (YENİ)
│   └── 012_usage_counter_rpc.sql              (YENİ)
├── app/services/
│   ├── decision_engine.py                     (REPLACE)
│   ├── prompt_engine.py                       (REPLACE)
│   ├── safety_service.py                      (REPLACE)
│   ├── fallback_copy_service.py               (REPLACE)
│   ├── coach_service.py                       (REPLACE)
│   └── content/
│       └── coach_fallbacks.json               (YENİ)
├── app/api/routes/
│   └── coach.py                               (REPLACE)
└── tests/
    └── test_ai_pipeline.py                    (YENİ)
```

## Entegrasyon Adımları

### 1. Migration'ları Uygula

Önce mevcut Supabase'de hangi tablolar var kontrol et:

```sql
-- Supabase Dashboard → SQL Editor
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'premium_status_cache', 'usage_counters_daily',
    'device_push_tokens', 'notification_preferences',
    'daily_checkins', 'weekly_insights',
    'safety_flags', 'safety_events'
  )
ORDER BY table_name;
```

**Eğer hiçbiri yoksa:** üç migration'ı sırayla uygula (010, 011, 012).

**Bazıları varsa:** SQL'leri inceleyip eksik olanları seç. `CREATE TABLE IF NOT EXISTS` kullandığım için zaten var olanlar atlanır ama RLS policy'leri zaten varsa hata verir; o satırları yorumla.

```bash
# Lokal test (Supabase CLI varsa)
cd backend
supabase db push

# Veya Dashboard SQL editor'a kopyala-yapıştır
```

### 2. Service Dosyalarını Diff'le

```bash
cd ~/development/nuveli

# Mevcut decision_engine ile karşılaştır
diff backend/app/services/decision_engine.py \
     /path/to/sprint1/backend/app/services/decision_engine.py

# Aynı şekilde diğerleri için
```

**Strateji:**
- Yeni dosyalardaki **public API** (sınıf isimleri, method imzaları) yeni standart kabul et
- Mevcut dosyalardaki repo-spesifik logic'i (örn senin Supabase client kurulumun, kendi loglarınız) yeni dosyalara taşı
- Yeni dosyalar **bağımlılığı net**: `decision_engine` → `prompt_engine` → `coach_service` zinciri import sırası bu

### 3. Dependency Injection

`backend/app/core/dependencies.py` dosyanda muhtemelen `get_coach_service()` fonksiyonu var. Şu şekilde olmalı:

```python
from functools import lru_cache
from openai import AsyncOpenAI
from app.core.config import settings
from app.db.client import get_supabase_client
from app.services.decision_engine import DecisionEngine
from app.services.prompt_engine import PromptEngine
from app.services.safety_service import SafetyService
from app.services.fallback_copy_service import FallbackCopyService
from app.services.coach_service import CoachService
from app.services.tts_service import TTSService  # mevcut

@lru_cache()
def get_decision_engine() -> DecisionEngine:
    return DecisionEngine(get_supabase_client())

@lru_cache()
def get_prompt_engine() -> PromptEngine:
    return PromptEngine()

@lru_cache()
def get_safety_service() -> SafetyService:
    return SafetyService()

@lru_cache()
def get_fallback_copy_service() -> FallbackCopyService:
    return FallbackCopyService()

@lru_cache()
def get_openai_client() -> AsyncOpenAI:
    return AsyncOpenAI(api_key=settings.openai_api_key)

@lru_cache()
def get_coach_service() -> CoachService:
    return CoachService(
        decision_engine=get_decision_engine(),
        prompt_engine=get_prompt_engine(),
        safety_service=get_safety_service(),
        fallback_copy_service=get_fallback_copy_service(),
        openai_client=get_openai_client(),
        tts_service=get_tts_service(),  # mevcut TTSService
    )
```

### 4. Tests'i Çalıştır

```bash
cd ~/development/nuveli/backend
source venv/bin/activate
pip install pytest-asyncio  # eğer yoksa
pytest tests/test_ai_pipeline.py -v
```

Beklenen sonuç: tüm testler geçer. **Geçmeyenler:**
- `TestDecisionEngine.*` failures → muhtemelen `profiles`, `coach_preferences` tablo şemanızda fark vardır. Mock'taki field isimlerini gerçek şemaya uyarla.
- `TestSafetyService.*` failures → regex pattern'leri çok agresif olabilir. Pattern'leri gevşet.

### 5. Smoke Test

Backend ayağa kaldır, gerçek bir kullanıcıyla test et:

```bash
cd backend && uvicorn app.main:app --reload

# Başka terminal:
TOKEN="<bir test kullanıcısının JWT'si>"
curl -X POST http://localhost:8000/coach/respond \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "surface": "chat_response",
    "message": "Bugün biraz dağıldım, ne yapayım?"
  }'
```

Beklenen yanıt:
```json
{
  "text": "...",
  "mode": "normal",
  "persona": "gentle",
  "is_fallback": false,
  "show_premium_upsell": true,
  "usage_remaining": 2,
  ...
}
```

### 6. Frontend Tarafında Hiçbir Değişiklik Gerekmiyor

`/coach/respond` endpoint'inin response şemasında ek field'lar var (`show_resources`, `show_day2_gift`, `usage_remaining`, vs) — frontend bunları henüz kullanmıyor olabilir. Sprint 2'de UI'a bağlanacak. Mevcut çağrılar geriye dönük uyumlu (sadece `text` ve `mode` okuyorsa hâlâ çalışır).

## Kalan İşler (Sprint 1 Gün 4'e geçmeden önce)

- [ ] Migration'lar production Supabase'de uygulandı
- [ ] `dependencies.py` güncellemesi yapıldı
- [ ] `coach.py` route'u yeni service'i kullanıyor
- [ ] `pytest tests/test_ai_pipeline.py` yeşil
- [ ] `curl /coach/respond` lokal'de çalışıyor
- [ ] `coach_fallbacks.json` `services/content/` altında doğru yere konuldu
- [ ] Mevcut `coach_threads` / `coach_messages` persistence kodunu yeni route'a entegre ettim (TODO'lar dosyada işaretli)

## Notlar

**Neden mevcut dosyaları "REPLACE" diyorum?**
Çünkü repo'daki mevcut `decision_engine.py` vb. dosyaların içini görmedim. Eğer mevcut implementasyonun zaten PRD'ye uygunsa, yeni dosyaları **referans** olarak kullan, eksik kısımları (örn `compute_safety_mode`, `_should_show_upsell` mantığı) mevcut dosyana ekle.

**Test mock'ları repo'nun gerçek şemasına uymayabilir.**
Mock'ta `profile.target_weight_loss_per_week_kg` field'ı kullandım ama senin şemada başka isim olabilir. Test'leri çalıştırınca anlarsın.

**TTS Service henüz wire'lı değil.**
`coach_service.py`'da TTS opsiyonel olarak çağrılıyor ama gerçek `tts_service.py` implementasyonunu görmedim. Sprint 1 Gün 6'da FCM ile birlikte ele alacağız.

---

Sıradaki adım: bu paketi entegre et + smoke test → bana bildir → Sprint 1 Gün 4-5 (RevenueCat + Paywall) için kod paketini hazırlıyorum.
