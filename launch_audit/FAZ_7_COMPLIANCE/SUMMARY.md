# ⚖️ FAZ 7 — Compliance & Legal Audit Summary

**Tarih:** 2026-05-21
**Şapka:** LAWYER + AUDITOR
**Scope:** Apple, Google, GDPR, KVKK, COPPA, CCPA — kanun ve marketplace kuralları

---

## 🎯 FINAL SKOR: 62/100 ⚠️

**Reject Risk Assessment:** **YÜKSEK**

| Authority | Skor | Status |
|---|---|---|
| Apple App Store | 55/100 | 🔴 RED RISK |
| Google Play Store | 78/100 | 🟢 OK |
| GDPR (AB) | 70/100 | 🟡 |
| COPPA (13 altı) | 90/100 | 🟢 |
| CCPA (California) | 75/100 | 🟢 |
| KVKK (Türkiye) | 80/100 | 🟢 |
| Apple Privacy Nutrition Label | 40/100 | 🔴 |

---

## 🔴 APPLE APP STORE — Critical Findings

### Apple Guideline 5.1.1(v) — Account Deletion
**Status:** 🔴 **FAIL** (uygulamada eksik)
**Detay:** App Store Apple Guideline 5.1.1(v) — kullanıcı hesabını **in-app** silebilmeli.
**Mevcut:**
- ✅ Backend `DELETE /me` endpoint var
- ✅ l10n string'leri var
- ❌ **Frontend UI YOK** (Phase 2 — C-3 finding)
**Verdict:** 🔴 **REJECT RİSKİ ÇOK YÜKSEK**.

### Apple iOS 17 Privacy Manifest
**Status:** 🔴 **FAIL** (dosya yok)
**Detay:** `PrivacyInfo.xcprivacy` Apple 2024 itibarıyla iOS 17+ uygulamalar için ZORUNLU.
**Mevcut:** Dosya yok (Phase 2 — C-2 finding)
**Verdict:** 🔴 **AUTOMATED REJECT**.

### Apple Sign In with Apple (Guideline 4.8)
**Status:** ✅ OK
**Detay:** Apple SI implement edilmiş (`apple_signin_service.dart`).
**Kontrol gereken:** Xcode'da "Sign in with Apple" capability işaretli mi?

### Apple Privacy Nutrition Label
**Status:** 🟡 **CHECK STATUS**
**Detay:** App Store Connect'te 11 data type beyan edilmeli:
| Data Type | Linked to User? | Tracking? | Purpose |
|---|---|---|---|
| Email | ✅ Yes | ❌ No | Account |
| Name | ✅ Yes | ❌ No | Account, Personalization |
| Health & Fitness | ✅ Yes | ❌ No | App Functionality |
| User Content (photos) | ✅ Yes | ❌ No | App Functionality |
| Diagnostics (Crashlytics) | ❌ No | ❌ No | Analytics |
| Performance | ❌ No | ❌ No | Analytics |
| Identifiers (device ID) | ❌ No | ❌ No | Analytics |
| Coarse Location | ❌ — | ❌ — | App kullanıyor mu? — kontrol |
| Purchase History | ✅ Yes | ❌ No | App Functionality (RC) |

**Action:** Submit öncesi App Store Connect → App Privacy form doldurulmalı (10-15 dakika).
**Verdict:** 🟡 Manuel iş — eksik veya yanlış doldurulursa REJECT.

### Apple Guideline 1.4 — Physical Harm (Wellness)
**Status:** 🟡 **REVIEW**
**Detay:** "Yanıltıcı sağlık iddiası" yasak. Description'larda kontrol gerekli:
- ❌ "10 günde 5 kilo ver" → REJECT
- ❌ "Diyabet için diyet" → REJECT (medical)
- ✅ "Wellness için akıllı kalori takibi" → OK

**Mevcut:** `docs/copy/` ve `launch_assets/submission/`'da TR description ~2180 char.
**Action:** TR + EN description'larını incele, "medical/treat/cure" kelimelerini ele.

### Apple Guideline 3.1 — Payments
**Status:** 🟡
**Detay:**
- ✅ In-App Purchase üzerinden (RevenueCat)
- ❓ Subscription disclosure tam mı? (auto-renew, cancel, price)
- ❓ "Restore Purchases" butonu var mı paywall'da?

**Action:** `lib/features/premium/premium_paywall_screen.dart`'ı oku, disclosure var mı kontrol et.

---

## 🟢 GOOGLE PLAY STORE — Findings

### Data Safety Form
**Status:** 🟡 **CHECK**
**Detay:** Play Console'da Data Safety form doldurulmalı.
**Action:** Submit checklist'te işaretli ama UI verify gerekli.

### Health Claims (Play Misleading Health)
**Status:** 🟢 OK
**Detay:** Wellness pozisyonlama doğru, medical claim yok.

### Sensitive Permissions
**Status:** 🟢 OK
**Permissions:**
- INTERNET ✅
- ACCESS_NETWORK_STATE ✅
- CAMERA ✅ (rationale gerekli)
- READ_MEDIA_IMAGES ✅
- POST_NOTIFICATIONS ✅
- SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM ⚠️ — gerekçe açıklamalı (Play Console'da)
- RECEIVE_BOOT_COMPLETED ⚠️ — gerekçe açıklamalı

**Action:** Schedule_exact_alarm Play Console'da justification gerektirir. Submit form'da açıkla.

---

## 🇪🇺 GDPR Audit

| Hak | Status | Detay |
|---|---|---|
| Right to Access | 🟡 PARTIAL | Profile edit var, ama "Export data" feature görünür değil |
| Right to Erasure | 🟠 PARTIAL | Backend var, UI yok (C-3) |
| Right to Portability | ❌ EKSİK | CSV/JSON export yok |
| Right to Rectification | ✅ OK | Profile edit |
| Consent (Analytics) | 🟡 CHECK | Firebase Analytics opt-in? |
| Privacy Policy | ✅ OK | nuveli.com.tr/privacy 7 dilde |
| DPO Contact | ✅ OK | privacy@nuveli.app aktif (BUGS_TODO doğrulanmadı — verify) |

**Action:**
- Export Data feature gerekli mi karar (v1.1+ acceptable)
- Account delete UI (C-3) bunu zaten karşılar (Right to Erasure)
- Cookie banner web için (subscription portal)

---

## 👶 COPPA Audit (13 yaş altı)

**Status:** ✅ **PASS**

| Kontrol | Status |
|---|---|
| Yaş gate signup'ta | ✅ `dateOfBirth` zorunlu |
| 13 altı reject | ✅ 7 dilde error mesajı (`ageGateUnderageError`) |
| Privacy policy 13+ açık | ✅ KVKK doc'ta var |
| Parental consent | ❌ N/A (13+ targeted, parental gerekli değil) |

**Action:** Apple Age Rating: 17+ veya 12+ verify (wellness + sağlık verisi → 17+ tavsiye).

---

## 🇺🇸 CCPA (California)

**Status:** 🟢 **OK**

- ✅ Privacy Policy CCPA disclosure var (presume from 7-lang policy)
- ✅ "Do Not Sell" link — Nuveli veri satmıyor, ama statement açık olmalı
- ✅ Account deletion (right to erasure) — UI eklendikten sonra OK

---

## 🇹🇷 KVKK (Türkiye)

**Status:** 🟢 **OK** — sağlam dokümantasyon

**Mevcut:** `docs/product/kvkk-compliance.md` kapsamlı:
- Hassas sağlık verisi kategorize edilmiş
- IP retention 30 gün belirtilmiş
- Yurt dışı veri aktarımı (Supabase EU, OpenAI US) açık

**Eksiklikler:**
- ❓ VERBİS kaydı — 5000+ kullanıcı varsa zorunlu (ileride)
- ❓ Açık rıza UI'ı — onboarding'de checkbox var mı?

**Action:**
- Onboarding'de KVKK açık rıza checkbox'ı verify edilmeli (Phase 4'te test)
- VERBİS post-launch (5000 kullanıcı sınırı)

---

## ♿ Accessibility Legal (ADA Compliance)

**Status:** 🟡 **CHECK**

**Mevcut:**
- A11y için Semantics widget kullanımı tespit edilmedi (Phase 5'te test)
- Color contrast: dark theme (cyan on #0B1A3D) — verify 4.5:1
- Touch target ≥44x44pt — verify

**Action:**
- Phase 5'te VoiceOver/TalkBack manual test
- Phase 5'te color contrast Accessibility Inspector

---

## 🎯 Reject Risk Matrisi

| Risk Yeri | Olasılık | Severity | Önlem |
|---|---|---|---|
| **Account delete UI eksik** | 95% | 🔴 Çok Yüksek | C-3 fix gerekli |
| **PrivacyInfo.xcprivacy yok** | 99% | 🔴 Çok Yüksek | C-2 fix gerekli |
| Privacy Nutrition Label yanlış | 30% | 🔴 Yüksek | App Store Connect manuel |
| Subscription disclosure unclear | 20% | 🟠 Yüksek | Paywall review |
| Health claim language | 15% | 🟠 Yüksek | Description review |
| Test account broken | 10% | 🟡 Orta | Submit öncesi final test |
| Apple Sign-In capability missing | 10% | 🟠 Yüksek | Xcode verify |

**Toplam risk skoru: 7+ → STRONG DELAY recommendation** (eğer C-2 ve C-3 fix'lenmezse).

---

## 🏆 Skor: 62/100

**Breakdown:**
- Apple compliance: 25/40 (C-2, C-3, Privacy Label)
- Google compliance: 18/20
- GDPR: 12/15 (export missing)
- COPPA/CCPA/KVKK: 7/10
- A11y: 0/15 (henüz test edilmedi — Phase 5)

**Fix sonrası tahmini:** C-2 + C-3 + Privacy Label + A11y test → **88/100**

---

## 📋 Pre-Launch BLOCKER Action Items (Phase 7)

(Phase 2 ile çakışan kritik maddeler):
1. [ ] `PrivacyInfo.xcprivacy` oluştur (Phase 2 — C-2)
2. [ ] Account Delete UI implement (Phase 2 — C-3)
3. [ ] Apple Privacy Nutrition Label App Store Connect'te doldur (10-15 dk)
4. [ ] TR + EN description'larda "medical/treat/cure" kelimelerini ele
5. [ ] Paywall'da subscription disclosure (auto-renew, cancel, price) verify
6. [ ] Xcode "Sign in with Apple" capability işaretli mi verify

## v1.0.1 Action Items
- Export Data feature (GDPR portability)
- Onboarding KVKK açık rıza checkbox verify
- A11y semantic labels (Phase 5 sonrası)

---

## 🎯 Sonuç

**Mevcut compliance posture: 62/100 — DELAY önerisi.**

C-2 (Privacy Manifest) + C-3 (Account Delete UI) **kesinlikle yapılmalı** — bunlar otomatik reject sebebi.

Onlar yapıldıktan sonra Phase 7 skoru: **88/100 → CAUTION GO mümkün.**
