# Nuveli Analytics Event Taxonomy

Firebase Analytics'te track edilen tüm event'ler.
Veri ekibi ve ürün yöneticileri için referans doküman.

**Kod lokasyonu:** `app/lib/core/monitoring/analytics_service.dart`

---

## İlkeler

1. **Hiçbir PII gönderilmez.** Mesaj içeriği, öğün adı, email, telefon — hiçbiri.
2. **Sadece enum değerler parametre olur.** Serbest metin parametresi yok.
3. **Boolean → 0/1** (Firebase boolean kabul etmez).
4. **Debug build'de event'ler gönderilmez** (development noise'ı temizler).
5. **User property** — `premium_tier` ve auth'da `user_id` set edilir.

---

## User Properties

| İsim | Değerler | Ne zaman set edilir |
|---|---|---|
| `user_id` | Supabase UUID | Login/signup sonrası, logout'ta temizlenir |
| `premium_tier` | `free` / `trial` / `premium` | Premium status değiştiğinde |

---

## Auth Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `signup_started` | — | Kullanıcı signup ekranını açtı |
| `signup_completed` | — | Backend signup başarılı |
| `login_completed` | — | Backend login başarılı |
| `logout` | — | Settings → Çıkış Yap |

---

## Onboarding Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `onboarding_step_completed` | `step: string` (`age_gate`, `wellness_scope`, `goal`, `profile_1`, `profile_2`, `coach`, `notifications`) | Her acceptance/onboarding adımı sonu |
| `onboarding_completed` | `goal: string`, `coach_persona: string`, `calorie_target: int` | Backend submit başarılı, home'a geçerken |

**Funnel analizi:** `onboarding_step_completed` adım bazında drop-off gösterir.

---

## Meal Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `meal_capture_started` | `source: camera\|gallery\|text` | Meal capture başlatıldı |
| `meal_analyzed` | `confidence: high\|medium\|low` | AI Vision sonucu döndü |
| `meal_confirmed` | `meal_type: breakfast\|lunch\|dinner\|snack` | Kullanıcı AI sonucunu değiştirmeden kabul etti |
| `meal_edited` | `meal_type: ...` | Kullanıcı AI sonucunu düzenledi |
| `meal_manual_entered` | — | Manuel giriş (genelde low-confidence sonrası) |
| `meal_deleted` | — | Home'da swipe-to-delete |

**Kritik metrikler:**
- `meal_confirmed / meal_analyzed` oranı → AI güvenilirliği
- `low confidence → meal_manual_entered` oranı → manual redirect etkinliği

---

## Coach Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `coach_message_sent` | `length_chars: int` | Kullanıcı mesaj gönderdi (mesaj içeriği GÖNDERİLMEZ) |
| `coach_audio_played` | — | Koç sesli yanıtını oynattı (premium) |
| `coach_safety_triggered` | `risk_mode: crisis\|distress\|low_intake` | Safety service tetiklendi |

**Kritik:**
- `coach_safety_triggered` **sadece risk_mode gönderir**, mesaj içeriği asla. Mahremiyet kritik.
- Bu event'in spike'ı anlamlı — ürün ekibine alarm verir.

---

## Premium Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `paywall_shown` | `source: home\|meal_limit\|coach_limit\|settings\|trial_gift` | Paywall ekranı veya modal açıldı |
| `purchase_initiated` | `product_id: string` | RevenueCat satın alma başladı |
| `purchase_completed` | `product_id: string` | Satın alma başarılı |
| `purchase_cancelled` | — | Kullanıcı iptal etti |
| `purchase_failed` | `reason: string` | Hata (network, RevenueCat error, vb.) |
| `trial_claimed` | — | 7 günlük hediye claim edildi |
| `restore_purchases_completed` | `success: 0\|1` | Satın almaları geri yükle |

**Conversion funnel:**
1. `paywall_shown` (source kırılımında)
2. `purchase_initiated`
3. `purchase_completed` / `purchase_cancelled` / `purchase_failed`

Source bazında `paywall_shown → purchase_completed` conversion rate'i hangi triggerın en iyi sattığını gösterir.

---

## Feature Gate Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `limit_reached` | `feature: meal_analysis\|coach_message` | Free tier günlük limiti doldu |

**Stratejik:** Bu event spike'ı → limit çok düşük olabilir, veya free tier fazla kısıtlı → retention'ı düşürüyor olabilir. A/B test sinyali.

---

## Settings Events

| Event | Parametreler | Tetikleyici |
|---|---|---|
| `notification_prefs_changed` | `meal_reminders: 0\|1`, `coach_nudges: 0\|1`, `weekly_summary: 0\|1` | Kaydet butonu |
| `account_deleted` | — | GDPR/KVKK account deletion |

---

## Screen Views

Her ekran açıldığında `AnalyticsService.screenView('screen_name')` çağrılmalı. Ekran adları:

| Feature | Screen names |
|---|---|
| Auth | `splash`, `login`, `signup`, `forgot_password` |
| Onboarding | `age_gate`, `wellness_scope`, `ai_estimates`, `special_cases`, `terms`, `goal`, `profile_1`, `profile_2`, `coach_select`, `notifications_optin`, `onboarding_result` |
| Main | `home`, `meal_capture`, `meal_manual`, `meal_result`, `coach_chat` |
| Premium | `paywall`, `trial_gift_modal` |
| Settings | `settings`, `notification_prefs`, `delete_account`, `how_ai_works`, `privacy_safety`, `support` |

---

## Dashboard Önerileri

### Product Dashboard
- Günlük aktif kullanıcı (DAU)
- Onboarding funnel drop-off (step-by-step)
- Meal analizleri / DAU (engagement)
- `paywall_shown → purchase_completed` conversion (source kırılımında)

### Safety Dashboard (Özel)
- `coach_safety_triggered` günlük sayı (zaman serisi)
- Risk mode dağılımı (crisis vs distress vs low_intake)
- `limit_reached` günlük sayı

### Retention Dashboard
- D1, D7, D30 retention (cohort analizi)
- Premium tier kırılımında retention
- Trial → Premium conversion

---

## PII Koruma Kuralları

**ASLA gönderilmez:**
- Email, telefon, isim
- Öğün adı veya açıklaması
- Coach mesaj içeriği (sadece `length_chars`)
- Ölçüm değerleri (kilo, boy, kalori sayıları)
- Fotoğraf URL'leri

**Gönderilir:**
- User ID (Supabase UUID — pseudonymous, PII değil GDPR'a göre)
- Enum parametreler (goal, tier, risk_mode, confidence, vb.)
- Sayısal agregatlar (`length_chars`, `calorie_target`)

Şüphe varsa **gönderme** — veri ekibi ile konuş.
