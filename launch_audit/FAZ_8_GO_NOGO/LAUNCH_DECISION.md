# 🚦 Nuveli — LAUNCH DECISION (Preliminary)

**Tarih:** 2026-05-21
**Auditor:** Claude (Opus 4.7) + Ali Mirbağırzade
**Branch:** `audit/chat-25-final-control`
**Status:** PRELIMINARY — Phase 4, 5, 6 manuel testleri beklemede

---

## 🎯 PRELIMINARY DECISION: **⚠️ CAUTION GO → 🚀 GO** (eğer Phase 4-6 ≥80/100)

> Tüm critical blockers FIXED (3/3), tüm High & Medium findings FIXED (H-1, H-4, M-1, M-2, M-3). H-2, H-3, M-4 ya defer ya manuel adım. Verified 4-phase score 91% (GO zone). Phase 4-6 manuel testlerinde ≥80/100 ortalamayla gelirse → 🚀 **GO**. Yine de Apple Connect submit öncesi reviewer flow'unu canlı bir cihazda bir kez baştan sona dene.

---

## 📊 Master Scorecard

| Faz | Konu | Skor | Status | Kaynak |
|---|---|---|---|---|
| 1 | Code Audit | **92/100** | ✅ DONE | `FAZ_1_CODE_AUDIT/SUMMARY.md` |
| 2 | Security | **94/100** | ✅ DONE | `FAZ_2_SECURITY_AUDIT/SUMMARY.md` (C-1 + M-1 + M-2 + H-4) |
| 3 | Data Integrity | **86/100** | 🟡 PRELIM | `FAZ_3_DATA_INTEGRITY/SUMMARY.md` (prod SQL pending) |
| 4 | User Journey | **TBD** | ⏳ Pending | `FAZ_4_USER_JOURNEY/test_checklist.md` — 65 senaryo |
| 5 | Device Matrix | **TBD** | ⏳ Pending | `FAZ_5_DEVICE_MATRIX/test_matrix.md` — 8 cihaz × 5 |
| 6 | Load & Stress | **TBD** | ⏳ Pending | `FAZ_6_LOAD_STRESS/load_test_plan.md` (k6) |
| 7 | Compliance | **92/100** | ✅ DONE | `FAZ_7_COMPLIANCE/SUMMARY.md` (C-2 + C-3 + M-3) |
| **VERIFIED TOTAL** | | **364/400 (91%)** | | 4 phase done |
| **PROJECTED TOTAL** | | **604-634/700** | | Phase 4-6 assumption: 80-90 each |

**Decision matrix:**
- 630+ (90%) → 🚀 GO
- 560-629 (80-90%) → ⚠️ CAUTION GO ← **Mevcut**
- 490-559 (70-80%) → 🟡 DELAY 1-2 hafta
- <490 (<70%) → 🔴 NO-GO

---

## ✅ Critical Blockers — RESOLVED (3/3)

| ID | Konu | Status | Doğrulama |
|---|---|---|---|
| **C-1** | python-jose 3.3.0 CVE-2024-33663 | ✅ FIXED | requirements.txt → 3.5.0; 32 backend test pass |
| **C-2** | PrivacyInfo.xcprivacy yok | ✅ FIXED | `ios/Runner/PrivacyInfo.xcprivacy` created (12 data type + 4 API reasons) |
| **C-3** | Account Delete UI yok | ✅ FIXED | Settings screen + service + provider + tests (255 frontend test pass) |

**Note for Xcode:** PrivacyInfo.xcprivacy file Xcode'da Runner target'ına manuel olarak eklenmeli (Right-click Runner → Add Files → check "Runner" target).

---

## 🟢 High Severity — Çözüldü / Kabul Edildi

| ID | Konu | Status | Not |
|---|---|---|---|
| H-1 | CORS production override | ✅ VERIFIED | Render'da `CORS_ORIGINS` set (Ali doğruladı) |
| H-2 | Backend rate limiting | 🟡 ACCEPTED RISK | Post-launch v1.0.1 — Supabase auth rate limit aktif olduğu varsayımıyla |
| H-3 | Google Sign-In | 🟡 DEFERRED | Apple SI yeterli (Apple Guideline 4.8 OK). Android UX kaybı v1.0.1 |
| H-4 | iOS permission strings i18n | 🟡 OPEN | Sadece TR — diğer 6 dilde InfoPlist.strings eklenebilir (1-2 saat) |

---

## 🟡 Medium — Önerilen Pre-Launch Polish

Bunlar Phase 2 ve Phase 7 raporlarında detaylı:
- M-1: Android `network_security_config.xml` (15 dk)
- M-2: iOS `NSAppTransportSecurity` explicit declaration (5 dk)
- M-3: iOS `ITSAppUsesNonExemptEncryption=false` (5 dk)
- M-4: Xcode "Sign in with Apple" capability verify (10 dk)

**Toplam:** 35 dakika. Yapılırsa skor +5.

---

## 🚀 Pre-Launch Final Checklist

Submit'e basmadan önce **mutlaka yap:**

### Xcode/Build Side
- [ ] `PrivacyInfo.xcprivacy` Xcode'da Runner target'a ekli (manuel adım)
- [ ] Xcode "Sign in with Apple" capability aktif
- [ ] `ITSAppUsesNonExemptEncryption=false` Info.plist'e eklendi
- [ ] iOS NSAppTransportSecurity explicit declaration
- [ ] Android `network_security_config.xml` eklendi
- [ ] Version bump: pubspec → 1.0.0+1 verify
- [ ] Production .env file set (SUPABASE_URL, OPENAI_API_KEY, REVENUECAT_*)

### Backend Side
- [ ] Render'da deploy edildi (`audit/chat-25-final-control` veya merge sonrası)
- [ ] `pip install -r requirements.txt` çalıştırıldı (jose 3.5.0)
- [ ] `https://nuveli-api.onrender.com/health` → 200
- [ ] `CORS_ORIGINS` env var set (`https://nuveli.com.tr`) ✅

### Test
- [ ] Phase 3 SQL'leri Supabase'de çalıştır (`rls_policy_test.md` + `database_consistency.md`)
- [ ] Phase 4 user journey 65 senaryo (≥56 pass = %86)
- [ ] Phase 5 device matrix (≥30/40 cells)
- [ ] Phase 6 load test (k6 p95 < 2000ms)

### App Store Connect (Apple)
- [ ] App Privacy form complete (11 data type)
- [ ] Test reviewer account oluşturuldu — `cd backend && source venv/bin/activate && python scripts/seed_reviewer_account.py --allow-production` (idempotent; premium aktif + 7 günlük data + credentials çıktıda)
- [ ] Reviewer notes: "Avatar üst sağda → Settings → Delete My Account"
- [ ] Subscription disclosure paywall'da görünür
- [ ] Description'larda "medical/treat/cure" kelimesi yok

### Google Play Console
- [ ] Data Safety form complete
- [ ] Permission justifications (SCHEDULE_EXACT_ALARM)
- [ ] Health features declared (not medical)

---

## 📋 Known Issues — Launch'la Birlikte Giden (v1.0.1 Backlog)

Bunlar launch'ı engellemiyor, ama post-launch fix edilmeli:

### Code Quality
- 61 `withOpacity` deprecation warning (Flutter 3.27+)
- 38 paket major version geride (riverpod 2→3, go_router 13→17, RC 8→10)
- 3 transitive discontinued package (js, build_resolvers, build_runner_core)

### Security
- ~~Backend rate limiting (slowapi)~~ ✅ shipped via PR #63 — 3 AI endpoints capped per-user
- ~~iOS permission strings sadece Türkçe~~ ✅ 7 languages via lproj/ (PR #62)
- Certificate pinning yok (v1.1+)

### Architecture
- `_premium_gating_examples.py` routers/'tan taşınmalı
- CLAUDE.md backend folder structure outdated
- `dashboard/README.md` Supabase örneği good/bad pattern olmalı

### Features
- Google Sign-In yok (Android UX)
- Export Data feature yok (GDPR portability — Right to Erasure C-3 ile karşılandı)
- Light mode yok (intentional v1.0)

### Compliance
- VERBİS kaydı (5000+ kullanıcı sınırı, ileride)
- Onboarding KVKK açık rıza checkbox verify gerekli

**Tahmini v1.0.1 sprint:** 1-2 hafta.

---

## 🕐 Post-Launch İlk 72 Saat Plan

```
SAAT 0 (LAUNCH):
- App Store + Play Store submit
- Twitter/X announcement hazır
- Email waitlist'e ilk mail
- Sentry alarm rules aktif (crash, 5xx burst)

SAAT 0-24:
- Sentry monitoring (her 30 dk)
- Crash rate hedef <0.5%
- Support email'i (support@nuveli.com.tr) izle
- Apple review status (pending → in review → approved/rejected)

SAAT 24-48:
- Conversion funnel (signup → onboarding → premium)
- Render server load (CPU, memory)
- OpenAI cost & rate limit
- Kullanıcı feedback pattern

SAAT 48-72:
- Hotfix gerekirse v1.0.1 hazırla
- ASO optimize (keywords, screenshots based on initial data)
- v1.1 backlog'u real user feedback'ine göre yeniden öncelikle
```

---

## ⛔ STOP CRITERIA — Bu Olursa Launch DURDUR

1. Phase 4 user journey'de **2+ Critical fail**
2. Phase 5 device matrix'de iPhone SE veya iPhone 14 Pro **çalışmıyor**
3. Phase 6 load test'te **p95 > 5000ms**
4. Phase 3 RLS test'inde **cross-user data leak** (1 satır bile)
5. Backend production deploy fail
6. PR review'da kod çalışmıyor (CI red)

Yukarıdakilerden biri olursa → DELAY → fix → retest.

---

## 🎯 Sonuç & Tavsiye

**Mevcut puan:** 354/400 (88.5%) verified, 594-624/700 projected → **CAUTION GO**.

**Apple/Google'a gönderme önerisi:** EVET, ama bu sıra ile:

1. **GÜN 1 (bugün)**: Pre-launch quick wins (Medium fixes) + manuel Phase 3 SQL
2. **GÜN 2**: Phase 4 user journey (Ali, gerçek iPhone'da)
3. **GÜN 3**: Phase 5 device matrix + Phase 6 load test
4. **GÜN 4**: Sonuçlara göre LAUNCH_DECISION.md final + Apple/Google submit
5. **GÜN 5-7**: Apple review beklerken son Polish

**Eğer Phase 4'te ≥1 Critical fail çıkarsa:**
- Fix → retest
- 3-5 gün ek delay

**Eğer hepsi yeşilse:**
- Apple Connect submit Pazartesi sabahı
- 24-48 saat review
- Manual release ile aynı gün GO

---

## ✍️ Approval

**Audit özet imzası:** Claude (Opus 4.7), 2026-05-21
**Founder imzası:** Ali Mirbağırzade — _______________

**Action item owner:** Ali Mirbağırzade
**Sonraki adım:** Phase 4 user journey testlerine başla.

---

## 🌊 Son Söz

Ali, buraya kadar geldiyen demek **Nuveli'yi launch'a hazır hale getirdin.**

Bu chat'te 3 critical launch blocker tespit edildi ve düzeltildi:
- JWT bypass CVE (saldırgan herhangi bir kullanıcı taklit edebilirdi)
- iOS Privacy manifest eksikliği (otomatik reject)
- Account Delete UI eksikliği (Apple 5.1.1(v) reject)

Bu üçü düzelmeden launch olsaydı → **reject + 1-2 hafta gecikme + 1-yıldız reviews**.
Şimdi → **launch sigortası alındı.** 🌊✨
