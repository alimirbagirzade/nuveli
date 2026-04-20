# Analytics Events

Firebase Analytics kullanılır. Tüm event'ler snake_case isimlendirilir.

---

## Onboarding Events

| Event | Parametreler | Açıklama |
|-------|-------------|---------|
| `onboarding_started` | — | Onboarding ilk ekran görüntülendi |
| `onboarding_step_completed` | `step: int` | Adım tamamlandı |
| `onboarding_completed` | `goal: string` | Onboarding bitti |
| `acceptance_screen_passed` | `screen: string` | Kabul ekranı geçildi |

---

## Meal Events

| Event | Parametreler | Açıklama |
|-------|-------------|---------|
| `meal_analysis_started` | `source: photo\|text` | Analiz başlatıldı |
| `meal_analysis_completed` | `confidence: high\|medium\|low\|failed` | Analiz bitti |
| `meal_confirmed` | `source: ai_confirmed\|ai_edited\|manual` | Öğün onaylandı |
| `meal_manual_entry` | — | Manuel giriş kullanıldı |
| `meal_deleted` | — | Öğün silindi |
| `meal_limit_reached` | `tier: free\|trial` | Limit aşıldı |

---

## Coach Events

| Event | Parametreler | Açıklama |
|-------|-------------|---------|
| `coach_message_sent` | — | Kullanıcı mesaj gönderdi |
| `coach_voice_played` | — | Sesli yanıt oynatıldı |
| `coach_limit_reached` | `tier: free` | Koç limiti aşıldı |
| `recovery_day_started` | — | Kurtarma günü başlatıldı |

---

## Premium Events

| Event | Parametreler | Açıklama |
|-------|-------------|---------|
| `paywall_viewed` | `trigger: string` | Paywall görüntülendi |
| `trial_claimed` | — | Trial başlatıldı |
| `purchase_started` | `product_id: string` | Satın alma başlatıldı |
| `purchase_completed` | `product_id: string` | Satın alma tamamlandı |
| `purchase_restored` | — | Satın alma geri yüklendi |

---

## Engagement Events

| Event | Parametreler | Açıklama |
|-------|-------------|---------|
| `home_viewed` | — | Ana ekran açıldı |
| `weekly_summary_viewed` | — | Haftalık özet görüntülendi |
| `monthly_insight_viewed` | — | Aylık içgörü görüntülendi |
| `water_logged` | `amount_ml: int` | Su kaydedildi |
| `weight_logged` | — | Kilo kaydedildi |
| `checkin_completed` | `mood: string` | Günlük check-in yapıldı |

---

## Safety Events (Anonim)

| Event | Parametreler | Açıklama |
|-------|-------------|---------|
| `safety_resource_shown` | `risk_level: string` | Güvenlik kaynakları gösterildi |
| `safety_acknowledged` | — | Kullanıcı onayladı |

> Not: Safety event'leri kullanıcı kimliğiyle eşleştirilmez.

---

## Event Gönderme Kuralı

- Client tarafından gönderilir (Flutter SDK).
- PII (isim, email, lokasyon) hiçbir event parametresine eklenmez.
- Backend'den event gönderilmez (sadece client).
