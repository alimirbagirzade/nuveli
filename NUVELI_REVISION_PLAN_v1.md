# Nuveli Revizyon Planı v1

**Tarih:** 1 Mayıs 2026
**Hazırlayan:** Claude
**Durum:** Repo yapı dump'ına göre revize edilmiş plan
**Kaynak:** v3/v4/v5 Ürün Raporu, v6 Geliştirme Planı, Prompt Paketi Final

---

## Özet — Neden Bu Plan

Repo'nun yapı dump'ı, MVP'nin **dosya seviyesinde %85 tamamlanmış** olduğunu gösteriyor. Eksikler dosya değil, **bağlantı eksiği (wiring)** ve **operasyonel detay**. Bu plan üç katmandan oluşur:

1. **Diagnostic** — kodu görmeden bilemediklerimizi 1 komutla netleştir
2. **Structural Cleanups** — dump'tan görünen 7 kesin sorunu kapat
3. **Revision Sprint 1** — 7 günlük somut görev listesi

---

## 1. Diagnostic — Önce Gerçeği Gör

Şu komutu Mac'te `~/development/nuveli` içinde çalıştır. Çıktıyı bana yapıştır → 5 dakikada tüm "var ama çalışıyor mu?" sorularına net cevap çıkar.

```bash
cd ~/development/nuveli && cat > /tmp/nuveli_diag.sh << 'DIAG_EOF'
#!/bin/bash
echo "════════════════════════════════════════"
echo "  NUVELI WIRING DIAGNOSTIC"
echo "════════════════════════════════════════"

echo ""
echo "═══ 1. AI PIPELINE (coach_service çağrı zinciri) ═══"
echo "→ coach_service.py decision_engine'i çağırıyor mu?"
grep -c "decision_engine\|DecisionEngine" backend/app/services/coach_service.py 2>/dev/null
echo "→ coach_service.py prompt_engine'i çağırıyor mu?"
grep -c "prompt_engine\|PromptEngine" backend/app/services/coach_service.py 2>/dev/null
echo "→ coach_service.py safety_service'i çağırıyor mu?"
grep -c "safety_service\|SafetyService\|safety_filter" backend/app/services/coach_service.py 2>/dev/null
echo "→ coach_service.py fallback_copy_service'i çağırıyor mu?"
grep -c "fallback_copy\|FallbackCopy" backend/app/services/coach_service.py 2>/dev/null
echo "→ coach.py route'u coach_service.respond'u çağırıyor mu?"
grep -E "coach_service|respond" backend/app/api/routes/coach.py | head -5

echo ""
echo "═══ 2. SAFETY MODES (normal/sensitive/high_risk) ═══"
grep -lE "sensitive_mode|high_risk|safety_mode" backend/app/services/*.py | head -5
echo "→ safety modes referansları:"
grep -rE "(sensitive|high_risk|safety_mode)" backend/app/services/*.py | wc -l

echo ""
echo "═══ 3. REVENUECAT WIRING ═══"
echo "→ purchases_flutter import edildiği yerler:"
grep -rl "purchases_flutter\|Purchases\." app/lib/ 2>/dev/null
echo "→ paywall_screen RevenueCat çağırıyor mu?"
grep -c "Purchases\|purchases_flutter" app/lib/features/premium/screens/paywall_screen.dart 2>/dev/null
echo "→ premium_service.dart içerik özeti:"
grep -E "Purchases|purchaseProduct|getOfferings|configure" app/lib/features/premium/data/premium_service.dart 2>/dev/null | head -10
echo "→ Backend premium_service RevenueCat webhook'u handle ediyor mu?"
grep -E "webhook|REVENUECAT|revenuecat" backend/app/services/premium_service.py 2>/dev/null | head -5

echo ""
echo "═══ 4. FCM WIRING ═══"
echo "→ firebase_messaging initialize:"
grep -rE "FirebaseMessaging|getToken|onMessage" app/lib/core/notifications/ app/lib/core/services/ 2>/dev/null | head -10
echo "→ Backend push token endpoint kullanılıyor mu?"
grep -rE "push-token|/devices/" app/lib/ 2>/dev/null | head -5
echo "→ push_service.py Firebase Admin kullanıyor mu?"
grep -E "firebase|fcm|FCM" backend/app/services/push_service.py 2>/dev/null | head -5

echo ""
echo "═══ 5. TTS WIRING ═══"
echo "→ voice_reply_player TTS endpoint çağırıyor mu?"
grep -E "tts|voice|/coach/voice" app/lib/features/coach/widgets/voice_reply_player.dart 2>/dev/null | head -5
echo "→ Backend tts_service OpenAI TTS çağırıyor mu?"
grep -E "audio.speech|tts|OpenAI" backend/app/services/tts_service.py 2>/dev/null | head -5
echo "→ /coach/voice route'u var mı?"
grep -rE "/voice|/tts" backend/app/api/routes/ 2>/dev/null

echo ""
echo "═══ 6. EMPTY DAY / RECOVERY FLOW ═══"
echo "→ empty_day_screen route'a bağlı mı?"
grep -E "empty_day|EmptyDay" app/lib/core/routing/app_router.dart 2>/dev/null | head -5
echo "→ Empty day backend endpoint'i var mı?"
grep -rE "empty_day|empty-day|/checkins" backend/app/api/routes/ 2>/dev/null | head -5
echo "→ daily_checkins tablosu migration'da var mı?"
grep -l "daily_checkins" backend/migrations/*.sql 2>/dev/null

echo ""
echo "═══ 7. RECOVERY DAY ═══"
echo "→ Recovery / rescue mode dosyaları:"
find app/lib -name "*recovery*" -o -name "*rescue*" 2>/dev/null
find backend/app -name "*recovery*" -o -name "*rescue*" 2>/dev/null

echo ""
echo "═══ 8. USAGE COUNTERS / FEATURE GATING ═══"
echo "→ usage_counters_daily tablosu hangi migration'da?"
grep -l "usage_counters_daily" backend/migrations/*.sql 2>/dev/null
echo "→ premium_status_cache tablosu hangi migration'da?"
grep -l "premium_status_cache" backend/migrations/*.sql 2>/dev/null
echo "→ Feature gating uygulanan endpoint'ler:"
grep -rE "check_usage|check_premium|usage_counter" backend/app/api/routes/ 2>/dev/null | head -10

echo ""
echo "═══ 9. ONBOARDING ADIM SAYISI ═══"
echo "→ onboarding_screens.dart içindeki step sayısı (yaklaşık):"
grep -cE "Step|class.*Screen|_buildStep" app/lib/features/onboarding/screens/onboarding_screens.dart 2>/dev/null
echo "→ acceptance_screens.dart içindeki ekran sayısı:"
grep -cE "AcceptanceScreen|class.*Screen|_buildAcceptance" app/lib/features/onboarding/screens/acceptance_screens.dart 2>/dev/null
echo "→ Onboarding'de ilk meal entry var mı?"
grep -rE "firstMeal|first_meal|onboarding.*meal" app/lib/features/onboarding/ 2>/dev/null | head -5

echo ""
echo "═══ 10. MIGRATION COLLISION ═══"
ls -la backend/migrations/

echo ""
echo "═══ 11. DEAD CODE ═══"
echo "→ Kökteki Swift app boyutu:"
du -sh Nuveli/ 2>/dev/null
echo "→ Kök vs landing/ HTML duplikasyonu:"
for f in iletisim.html kvkk.html sss.html; do
  if [ -f "$f" ] && [ -f "landing/$f" ]; then
    echo "$f: kök=$(wc -c < $f) landing/=$(wc -c < landing/$f) | aynı mı? $(cmp -s $f landing/$f && echo EVET || echo HAYIR)"
  fi
done
echo "→ landing.zip boyutu:"
ls -lh landing.zip 2>/dev/null
echo "→ landing.zip .gitignore'da mı?"
grep -q "landing.zip" .gitignore && echo "EVET" || echo "HAYIR"

echo ""
echo "═══ 12. TEST COVERAGE — KRİTİK SERVİSLER ═══"
for svc in decision_engine prompt_engine fallback_copy tts_service push_service safety_service coach_service meal_service home_service; do
  found=$(find backend/tests -name "*${svc}*" 2>/dev/null | head -1)
  [ -n "$found" ] && echo "✓ $svc → $found" || echo "✗ $svc → test YOK"
done

echo ""
echo "═══ 13. ENV / SECRETS ═══"
echo "→ backend/.env içinde hangi key'ler tanımlı (değerler değil, sadece anahtar adları):"
grep -oE "^[A-Z_]+" backend/.env 2>/dev/null | sort -u
echo "→ app/.env.production'da hangi key'ler:"
grep -oE "^[A-Z_]+" app/.env.production 2>/dev/null | sort -u

echo ""
echo "════════════════════════════════════════"
echo "  DIAGNOSTIC TAMAMLANDI"
echo "════════════════════════════════════════"
DIAG_EOF
chmod +x /tmp/nuveli_diag.sh && /tmp/nuveli_diag.sh
```

**Çıktıyı sohbete yapıştır.** Geri kalan plan bu çıktıya göre öncelik kazanacak.

---

## 2. Structural Cleanups — Diagnostic'siz Hemen Yap

Bu 7 sorun yapı dump'ından %100 net görülüyor. Risk yok.

### 2.1 Migration 007 Çakışmasını Çöz

İki dosya da `007_*` ile başlıyor → Supabase deploy sırası belirsiz, bir tanesi atlanıyor olabilir.

```bash
cd ~/development/nuveli/backend/migrations

# 1. macro_targets daha sonra eklendiyse onu 008'e al, avatar_url'i 007 yap
git mv 007_avatar_photo_and_macro_targets.sql 008_avatar_photo_and_macro_targets.sql
git mv 008_loosen_profile_constraints.sql 009_loosen_profile_constraints.sql

# 2. Kontrol et
ls -la

# 3. Hangi migration'lar Supabase'de uygulanmış?
# Supabase Dashboard → SQL Editor → şunu çalıştır:
# SELECT name, executed_at FROM supabase_migrations.schema_migrations ORDER BY name;
```

**Önemli:** Yeniden adlandırma `schema_migrations` tablosuna kayıtlı isimleri etkiler. Eğer iki 007 de production'da uygulandıysa, sadece dosya adını değiştir, migration'ı yeniden çalıştırma. Doğru sırayı belirleyemezsek 010'dan başlayan **birleştirilmiş bir consolidate migration** yazıp eski iki dosyayı yorum bloğuna alabilirsin.

### 2.2 Ölü Swift Klasörünü Sil

Flutter'a geçtikten sonra unutulmuş native iOS app.

```bash
cd ~/development/nuveli
git rm -rf Nuveli/
git commit -m "chore: remove deprecated native iOS Nuveli/ folder (Flutter migration)"
```

### 2.3 Kökteki HTML Dosyalarını Temizle

Kökte `iletisim.html`, `kvkk.html`, `sss.html` var; aynıları `landing/` altında da var. Canonical olan `landing/` (çünkü `index.html` ve diğerleri orada). Kök kopyaları sil.

```bash
cd ~/development/nuveli
git rm iletisim.html kvkk.html sss.html
git commit -m "chore: remove duplicate HTML pages from root (canonical in landing/)"
```

### 2.4 landing.zip Sorunu

```bash
cd ~/development/nuveli
echo "landing.zip" >> .gitignore
git rm --cached landing.zip
git commit -m "chore: untrack landing.zip and add to .gitignore"
# Yerel kopyayı silmek isterseniz:
# rm landing.zip
```

### 2.5 Üçlü Notification Servisi

Üç dosya rakip mi katmanlı mı belirsiz:
- `app/lib/core/notifications/notification_service.dart`
- `app/lib/core/services/local_notification_service.dart`
- `app/lib/core/services/notification_sync_provider.dart`

**Hipotez:** ilk dosya FCM (uzak), ikinci dosya `flutter_local_notifications` (lokal), üçüncü dosya backend tercih senkronu. Eğer öyleyse isimlendirmeyi netleştir:

```bash
cd ~/development/nuveli/app/lib

# Beklenen yapı:
# core/notifications/
#   ├── push_notification_service.dart   (FCM, eski notification_service.dart)
#   ├── local_notification_service.dart  (flutter_local_notifications, taşınacak)
#   └── notification_sync_provider.dart  (backend tercih senkronu, taşınacak)

# Diagnostic çıktısı geldiğinde isimlendirmeyi netleştirip uygulayacağız.
# Şimdilik tek bir TODO yorumu ekle:
```

> ⚠️ Diagnostic'in 4. bölüm çıktısı geldiğinde bu refactor'ı netleştireceğim.

### 2.6 Test Gap

Kritik 6 servisten 5'i test edilmemiş:
- `decision_engine.py` ❌
- `prompt_engine.py` ❌
- `fallback_copy_service.py` ❌
- `tts_service.py` ❌
- `push_service.py` ❌
- `safety_service.py` ✓ (var)

Sprint 1'de her birine en az 1 smoke test ekleyeceğiz.

### 2.7 RevenueCat Tabloları

Yapı dump'ında `premium_status_cache`, `usage_counters_daily` adında migration **dosyası** görünmüyor. İki olasılık:
- Mevcut migration'lardan birinin içine gömülmüş
- Hiç oluşturulmamış (RevenueCat backend wiring eksik)

Diagnostic'in 8. bölümü bunu netleştirecek.

---

## 3. Revision Sprint 1 — 7 Günlük Plan

Sprint hedefi: **AI pipeline + Premium + FCM zincirlerinin uçtan uca çalışır olduğu doğrulanmış olsun.**

### Gün 1 — Diagnostic & Structural Cleanup

- ✅ Yukarıdaki diagnostic'i çalıştır, çıktıyı paylaş
- ✅ Section 2.1 — 2.4'ü uygula (4 commit)
- ✅ `git push` ve Render'da deploy doğrula

### Gün 2-3 — AI Pipeline Wire-Up

**Amaç:** Coach response'u şu zincirden geçsin: route → coach_service → decision_engine → prompt_engine → OpenAI → safety_service → fallback_copy_service.

Cursor/Claude Code'a verilecek prompt:

```
[CURSOR/CLAUDE CODE PROMPTU — GÜN 2-3]

Amaç: Nuveli AI Coach pipeline'ını docs/protocols/coach-ai-protocol.md'ye uygun hale getir.

Mevcut dosyalar (var ama wire'lı olmayabilir):
- backend/app/services/coach_service.py
- backend/app/services/decision_engine.py
- backend/app/services/prompt_engine.py
- backend/app/services/safety_service.py
- backend/app/services/fallback_copy_service.py
- backend/app/api/routes/coach.py

Görev:
1. coach_service.respond() metodunu şu zincire çevir:
   a) decision_engine.resolve(user_id, event) → returns { mode: 'normal'|'sensitive'|'high_risk', persona, surface, premium_state }
   b) prompt_engine.build(decision, context) → returns prompt_messages (locale + persona uygulanmış)
   c) OpenAI chat.completions.create(messages=prompt_messages)
   d) safety_service.filter(response, decision.mode) → returns { passed: bool, filtered_text: str }
   e) Eğer safety filter fail veya OpenAI hata → fallback_copy_service.get(decision.persona, decision.surface)

2. high_risk modda:
   - Mizah kapalı (prompt_engine handle eder)
   - Premium upsell gösterilmez (decision_engine handle eder)
   - Profesyonel destek yönlendirmesi cevaba eklenir

3. Response formatı:
   { "text": "...", "tts_url": null|str, "mode": "normal", "is_fallback": false }

4. Tests:
   - tests/test_decision_engine.py — 3 test (normal/sensitive/high_risk modu doğru çözüyor mu)
   - tests/test_prompt_engine.py — 2 test (locale TR/EN ve persona switch)
   - tests/test_coach_pipeline.py — 1 entegrasyon testi (fake openai client ile)
   - tests/test_safety_service.py'a — high_risk filter testi ekle

Kurallar:
- V2/V3 özellik EKLEME (memory, kriz radarı yok)
- Medikal claim EKLEME
- Fallback metinleri docs/copy/coach-persona-examples.md'den çek
- Mevcut testleri kırma

Çıktı formatı: değişen dosyalar listesi + nasıl test edilir + kalan işler
```

### Gün 4-5 — RevenueCat Tam Wire-Up

**Amaç:** Day 0 paywall → Day 2 trial gift → trial start → premium status sync chain çalışsın.

```
[CURSOR/CLAUDE CODE PROMPTU — GÜN 4-5]

Amaç: RevenueCat freemium → trial → premium akışını uçtan uca çalıştır.

Frontend (var ama wire'lı olmayabilir):
- app/lib/features/premium/data/premium_service.dart
- app/lib/features/premium/screens/paywall_screen.dart
- app/lib/features/premium/screens/trial_gift_modal.dart
- app/lib/features/premium/utils/trial_gift_trigger.dart

Backend:
- backend/app/services/premium_service.py
- backend/app/api/routes/premium.py

Görev:
1. premium_service.dart:
   - Purchases.configure(apiKey) initialize (iOS: RC_APPLE_KEY, Android: RC_GOOGLE_KEY env'den)
   - getOfferings(), purchaseProduct(), restorePurchases()
   - Stream<EntitlementStatus> entitlement değişiklikleri

2. paywall_screen.dart:
   - Offering'leri RevenueCat'ten çek, plan kartlarını render et
   - "Satın al" → purchaseProduct → success → backend /premium/sync POST
   - Hata durumunda PRD §15'teki ton: "Premium erişimini kontrol ediyorum..."

3. Backend:
   - POST /premium/sync — RevenueCat customer info gelir, premium_status_cache tablosuna yaz
   - POST /premium/webhook — RevenueCat webhook (REVENUECAT_WEBHOOK_SECRET ile header doğrulama)
   - GET /premium/status — cache'ten döner
   - Migration: eğer premium_status_cache yoksa yeni 010_premium_tables.sql ekle

4. Trial Gift Day 2:
   - trial_gift_trigger.dart kullanıcının ikinci açılışını yakalıyor mu kontrol et
   - Yakalamıyorsa app_analytics'ten last_open + trial_offered_at field'ı oku, modal koşulu kur
   - Modal premium_service.startTrial() çağırır, RevenueCat trial start

5. Feature Gating:
   - meals/analyze, coach/respond, coach/voice endpoint'lerine usage_counters_daily kontrolü ekle
   - Limit aşıldığında HTTP 402 + "Bugünkü hakkın doldu, yarın tekrar" mesajı (PRD §6.3)
   - Premium kullanıcı için limit kontrolü atlanır

Tests:
- tests/test_premium_service.py — purchase success/fail
- tests/test_feature_gating.py — limit aşımı, premium bypass

Kurallar:
- API key client'ta hardcode YOK, env'den
- Webhook secret backend env'de
- Trial bittiğinde feature kapanmaz, sadece "premium preview" görünür (PRD §6.4)

Çıktı formatı: değişen dosyalar + test komutları + kalan işler
```

### Gün 6-7 — FCM Wire-Up + Empty Day Validation

**Amaç:** Local notification + FCM senkron çalışır, boş gün ekranı tetiklenebilir.

```
[CURSOR/CLAUDE CODE PROMPTU — GÜN 6-7]

Amaç 1: FCM token kayıt + sessiz saat (22:30-08:00) + haftalık bildirim Pazartesi

Mevcut:
- app/lib/core/notifications/notification_service.dart (FCM olduğunu varsayıyoruz)
- app/lib/core/services/local_notification_service.dart (flutter_local_notifications)
- app/lib/core/services/notification_sync_provider.dart
- backend/app/services/push_service.py
- backend/app/api/routes/notifications.py

Görev:
1. notification_service.dart:
   - FirebaseMessaging.instance.getToken() → POST /devices/push-token
   - onMessage / onMessageOpenedApp handler'ları
   - permission request → opt-in akışı

2. push_service.py:
   - Firebase Admin SDK initialize (env'den service account JSON)
   - send_notification(user_id, title, body, deeplink, quiet_hours_check=True)
   - Kullanıcı timezone'undan 22:30-08:00 ise gönderme (PRD §6.2)

3. Scheduled jobs (basit Render cron veya FastAPI background):
   - Pazartesi 09:00 (kullanıcı timezone): haftalık özet bildirimi
   - Haftada 1 kilo girişi hatırlatması
   - Akşam tek "boş gün" dürtmesi (kullanıcı veri girmemişse)

Amaç 2: Empty day flow validation

- empty_day_screen.dart route'unun home'dan tetiklenme koşulu:
  - Kullanıcı bugün hiç meal logla'mamışsa, akşam 20:00+ home açıldığında
  - Modal gibi gösterilir, "İyiydim / Yoğundum / Dağıldım / Sonra" 4 buton
  - Seçim → POST /checkins → daily_checkins tablosuna kayıt

- Kontrol: backend'de daily_checkins tablosu var mı? Yoksa migration ekle:

```sql
-- 011_daily_checkins.sql
CREATE TABLE IF NOT EXISTS daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('empty_day', 'mood', 'craving')),
  payload JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, date, type)
);
ALTER TABLE daily_checkins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users own checkins" ON daily_checkins
  FOR ALL USING (auth.uid() = user_id);
```

Tests:
- test_push_service.py — quiet_hours doğru çalışıyor mu
- test_empty_day_flow.py — checkin POST → DB kayıt

Çıktı: değişen dosyalar + test komutları + kalan işler
```

### Gün 7 Sonu — Smoke Test

```bash
# Backend
cd ~/development/nuveli/backend
source venv/bin/activate
pytest -v 2>&1 | tail -30
curl https://nuveli-api.onrender.com/health

# Frontend
cd ~/development/nuveli/app
flutter analyze
flutter test
flutter test integration_test/
```

Sprint 1 done kriteri:
- [ ] AI pipeline 4 servis aracılığıyla akıyor (zincir doğrulandı)
- [ ] RevenueCat trial start → backend sync → /premium/status premium döndürüyor
- [ ] FCM token backend'e kayıt oluyor, test bildirimi alındı
- [ ] Empty day modal akşam koşulunda görünüyor, checkin DB'ye düşüyor
- [ ] Yeni 6 servisten her biri için en az 1 smoke test
- [ ] Migration sayısı tutarlı, schema tablolar canlıda doğrulandı
- [ ] Render deploy yeşil

---

## 4. Sprint 2 Önizleme (Sonra Konuşacağız)

- Gün 8-10: Onboarding revizyonu (13 adımlı PRD akışına yaklaştırma — ilk meal + ilk başarı + trial card eklemek)
- Gün 11-12: Recovery day flow (rescue_screen, mini reset planı, high_risk handle)
- Gün 13-14: 30 günlük içgörü ekranı + Day 2 hediye trial timing fixleri

## 5. Sprint 3 Önizleme

- Coach personas tam aktivasyon (PRD §11.1 normal/sensitive/high_risk × 4 persona)
- TestFlight build + 5-10 kişi beta
- App Store / Play Store metadata son haline
- Health apps declaration

---

## Notlar

- **Hukuk metinleri (KVKK, Gizlilik, Şartlar):** `landing/kvkk.html`, `landing/gizlilik.html`, `landing/sartlar.html` mevcut. Bu dosyalar yayında mı kontrol et: `curl -I https://nuveli.com.tr/kvkk.html`. Yoksa landing'i deploy et. **Hukukçu son kontrol** dış doğrulama gerektiriyor (PRD §16.4).
- **App Store collision taraması:** "Nuveli" trademark search yapılmadıysa profesyonel hizmet al.
- **Support mailbox:** support@nuveli.com.tr aktif mi? Forwarded mı? Test maili gönder.
- **Apple Developer enrollment:** $99 ödendi mi? Yoksa TestFlight build alamayız.

---

**Sıradaki adım:** Diagnostic çalıştır → çıktıyı paylaş → Sprint 1 Gün 2'ye geçiyoruz.
