# 🤝 Claude Handoff — Nuveli (2026-05-22)

**Bu doküman bir önceki chat'te (Chat 25 → smoke test → Phase 1 implementation) yapılanları sonraki chat için özetler. Bir sonraki Claude oturumu sıfırdan başladığında, bu dosyayı okuyup ne ile uğraşıldığını ve sıradakini hızlıca anlayabilmeli.**

---

## 🎯 Bu Session'da Ne Yapıldı

Üç ana faz:
1. **Chat 25 audit kapanışı** (PR #62–#79) — 379/400 = 94.75% audit skoruyla launch-ready ilan edildi
2. **Smoke test prodüksiyonda 9 katmanlı schema drift ortaya çıkardı** → PR #80–#93 ile her birini onarımladı
3. **Render free tier yavaşlığı için optimistic UX** (PR #94 + #95)

**Toplam: 33 PR merged + 3 migration applied + 2 minor schema-fix SQL pending**

---

## ✅ Şu An Çalışan / Yeşil Olanlar

### Frontend (`app/`)
- Auth + Onboarding (7 screen, hepsi çalışıyor)
- **Dashboard** — calorie ring + macros + water tile + meals empty state + Add Food CTA (placeholder)
- **5-tab Bottom Nav** (`MainShellScreen` — `app/lib/features/main/`):
  - Dashboard ✅ functional
  - Scan ⚠️ `PlaceholderTabScreen` ("Coming in v1.1") — no UI
  - Analytics ⚠️ same placeholder pattern
  - Profile ✅ functional (`goals_profile_screen.dart` 352 LOC)
  - Settings ✅ functional (Export + Delete + Sign out + notifications)
- **Optimistic UX**:
  - Water +250 ml → tile zıplar anında (PR #94, `water_quick_card.dart` _pendingMl pattern)
  - Weight save → sheet hemen kapanır, snackbar "Saving → Saved" (PR #95)
- 8 chart widget hazır (`shared/widgets/charts/`) — Analytics tab'a bağlanabilir v1.1'de
- 264 flutter test passing
- `flutter analyze` clean (No issues found)

### Backend (`backend/`)
- 45 pytest passing (8 skipped)
- Live on Render free tier: `https://nuveli-api.onrender.com`
- `/health` 200 OK
- `/docs` / `/redoc` / `/openapi.json` → **404 in prod** (hidden by PR #76)
- RC webhook timing-safe + fail-closed (PR #77)
- Defensive try/except on `/today/summary` + `/analytics/dashboard` — schema drift won't 500 dashboard
- `/me/export` GDPR Article 20 working

### Supabase Schema (prod)
- Migration 014 (calorie sanity bounds) → repo'da, Ali henüz apply etmedi
- **Migration 015 APPLIED** ✅ — water_logs.logged_at + .source, weight_logs.logged_at
- **Migration 016 APPLIED** ✅ — weight_logs.local_day DEFAULT, weight_goals.status
- **Migration 017 APPLIED** ✅ — FK constraints repointed to auth.users
- FK doğrulama yapıldı (4 satır: weight_logs, water_logs, weight_goals, meals → auth.users)

---

## 🟡 Hâlâ Açık / Yapılacaklar

### 🔥 Phase 1 MVP — En Kritik (Launch'tan önce)

1. **`MealEntrySheet` build** (en büyük tek iş)
   - Add Food butonu hâlâ `_showComingSoon` toast veriyor
   - Manuel meal entry form: name, kcal, protein/carbs/fat, meal_type, time
   - `POST /meals` integration
   - Dashboard refresh on save
   - Tahminim: 1 günlük iş, ~250-400 LOC

2. **App Store description rewrite**
   - `launch_assets/metadata/app_description_en.md` ve `app_description_tr.md`
   - "AI camera scan" promise → v1.0'da yok, v1.1'e yaz
   - "Calorie + macro tracker with AI-assisted recommendations" gibi wellness odaklı dile çevir
   - Apple reject riski: %95 (mevcut state'le promise edilen feature yok)

3. **App Store Age Rating düzeltmesi** (Submission anında)
   - `launch_assets/submission/app_store_connect_form.md` line 111: "Medical/Treatment Information" → **None** (Infrequent değil)

### 🟡 Schema Drift — Minor Kalan

4. **ai_insights.payload column missing in prod** (Render log'larında WARNING olarak görünür)
   - Şu an: defensive try/except yakalıyor, 500 dönmüyor
   - Daha temiz: migration 018 ile ekle
   - Backend: `routers/analytics.py` line ~51 try/except içinde
   - Olası fix:
     ```sql
     ALTER TABLE public.ai_insights ADD COLUMN IF NOT EXISTS payload JSONB;
     ```

5. **water_logs.local_day SET DEFAULT** (cosmetic, backend gönderiyor zaten)
   ```sql
   ALTER TABLE public.water_logs ALTER COLUMN local_day SET DEFAULT CURRENT_DATE;
   ```

6. **`alimirbagirzade@gmail.com` signup fail mystery**
   - "Database error saving new user" — trigger zincirinde bir şey çakılıyor (sadece bu email için)
   - `ambz@yandex.com` çalışıyor
   - Test farklı email ile başarılı
   - Sebep tam diagnose edilmedi — muhtemelen soft-delete history veya rate limit
   - **Çözüm:** Ali bu email ile dene + Supabase Auth → Users → "All users" filtresine bak

7. **Dashboard'da "0 of 0 kcal"**
   - Profile tab'da Daily Target 2,046 kcal görünüyor ama Dashboard summary card 0 gösteriyor
   - `/analytics/dashboard` veya `dashboard_today` view stale dönüyor
   - Defensive fallback 2000 kcal'a düşüyor ama bu user'ın 2046'sı görünmüyor
   - Backend: `routers/meals.py todays_summary` daha derinden bakılmalı
   - Quick fix: `dashboard_today` view'ını refresh / drop&recreate

### 🟢 V1.1 Backlog (deferred)

- Camera/AI scan UI (`features/scan/`)
- AI Coach chat UI (`features/coach/`)
- Habit tracking UI (`features/habits/`)
- Recipe / Meal planner UI (`features/recipes/`)
- Apple Watch app
- Flutter web build

---

## 📂 Önemli Doc Dosyaları

| Doc | Ne için |
|---|---|
| `launch_audit/PRODUCTION_LAUNCH_CHECKLIST.md` | Submission gününde tek-kaynak rehber |
| `launch_audit/MISSING_UI_IMPLEMENTATION_PLAN.md` | Phase 1 MVP scope detayı (smoke test sonrası yazıldı) |
| `launch_audit/00_audit_overview.md` | Master scorecard (379/400) |
| `launch_audit/FAZ_8_GO_NOGO/LAUNCH_DECISION.md` | GO/NO-GO karar matrisi |
| `launch_audit/FAZ_8_GO_NOGO/known_issues_v1.md` | v1.0.1 backlog |
| `docs/auth/google-signin-setup.md` | Google Sign-In Firebase + Supabase wiring |
| `docs/FIREBASE_SETUP.md` | Firebase genel config |
| `CLAUDE.md` (root) | Project context |
| `app/CLAUDE.md` | App-specific rules |

---

## 🚀 Render Production

- URL: `https://nuveli-api.onrender.com`
- Tier: **Free** — cold start 30-60s after 15 min idle
- Keepalive: cron-job.org `/health` her 5 dakikada
- **ÖNERİ:** Submission öncesi paid tier ($7/ay) — cold start tamamen biter

Environment vars (her şey set):
- `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET`
- `OPENAI_API_KEY`, `REVENUECAT_WEBHOOK_SECRET`
- `CORS_ORIGINS=https://nuveli.com.tr,https://nuveli.app`
- `SENTRY_DSN`, `APP_ENV=production`

---

## 🧪 Test Komutları

```bash
# Backend
cd backend && source venv/bin/activate && python -m pytest -q
# → 45 passed, 8 skipped

# Frontend
cd app && flutter analyze --no-pub
# → No issues found
cd app && flutter test --no-pub --concurrency=2
# → 264 passed

# Run iOS simulator
cd app && flutter run -d "iPhone 17"

# Production health
curl https://nuveli-api.onrender.com/health
# → {"status":"ok","version":"1.0.0","env":"production"}
```

---

## ⏭️ Bir Sonraki Chat İçin Önerilen Plan

1. **Önce bu handoff'u oku**, sonra `launch_audit/MISSING_UI_IMPLEMENTATION_PLAN.md`
2. **MealEntrySheet implement et** — Phase 1'in son büyük parçası:
   - Yeni dosya: `app/lib/features/meal/meal_entry_sheet.dart`
   - Form fields: name (text), kcal (int), protein/carbs/fat (optional double), meal_type (dropdown: breakfast/lunch/dinner/snack), consumed_at (default now)
   - `POST /meals` with foods array format
   - Dashboard'a refresh trigger after save
   - Optimistic UX (su gibi): sheet hemen kapansın, snackbar status
   - Test: simulator'da fasulye girer, dashboard'da meal count + kcal artmalı

3. **Add Food butonunu wire et** — `dashboard_screen.dart` line ~92:
   ```dart
   onPressed: () => showMealEntrySheet(context),
   ```
   (şu an `_showComingSoon` toast veriyor)

4. **App Store description'ı düzelt** — V1.0 promise'lerinden AI scan'i çıkar

5. **Tekrar smoke test** — iOS simulator'da yeni meal entry flow'u test et

6. Eğer bunlar yeşil → submission window açık

---

## 📌 Sahada-Yapacaklar (Ali, Submission Öncesi)

- [ ] Phase 3 SQL probes Supabase'de (`launch_audit/FAZ_3_DATA_INTEGRITY/rls_policy_test.md` + `database_consistency.md`)
- [ ] Phase 4 user journey (65 senaryo, real iPhone)
- [ ] Phase 5 device matrix (8 cihaz)
- [ ] Phase 6 k6 load test
- [ ] Migration 014 + 018 (opsiyonel) SQL Editor'da apply
- [ ] Production SHA-1/256 → Firebase Android app
- [ ] App Store Age Rating "Medical/Treatment" → **None**
- [ ] `python scripts/seed_reviewer_account.py --allow-production`
- [ ] **Render paid tier** ($7/ay) — submission öncesi kesinlikle
- [ ] App Store Connect + Play Console submission

---

## 🧠 Kritik İçgörüler

1. **Audit kod-only yapıldı, scope check'i yetmedi.** Chat 25 audit'i %94 verdi ama smoke test ortaya 8 katman schema drift + boş meal/scan/coach UI'lar çıkardı. Sonraki audit'ler **runtime smoke test'i** içermeli.

2. **Schema drift kaynağı:** Prod Supabase'i eski bir DDL template'ten kuruldu (pre-2024 Supabase `profiles` table convention'ı vs. yeni `user_profiles`). Migration'lar prod'a baştan re-apply edilmedi. Migration 015-017 bu drift'i kapattı.

3. **Render free tier yetersiz:** 30-60s cold start + Render-Supabase round-trip her POST için 1-2s. Optimistic UX (PR #94 + #95) UX'i kurtarıyor ama submission öncesi paid tier şart.

4. **Build edilmemiş feature'ları "Coming soon" panel olarak göstermek** App Store reject riskini azaltır. Boş tab → reject. Açıklamalı placeholder → review'dan geçer (orta risk).

5. **Bu chat'te 33 PR ship'lendi.** Tüm CI yeşil, hiç merge conflict olmadı. Backend + Flutter + SQL migration'lar koordineli ilerledi.

---

**Bu doc handoff zamanında, Ali'nin isteğiyle yazıldı (2026-05-22). Bir sonraki Claude oturumunun ilk adımı: bu doc'u read edip context'i kafasına yerleştir, sonra MealEntrySheet'e başla.** 🌊
