# Nuveli — Session Handoff (last updated 2026-05-25, ~13:30 TRT)

> Bir Claude Code oturumundan diğerine geçişi temiz tutar. Yeni chat:
> ```
> Read docs/SESSION_HANDOFF.md and continue from "Google Play launch roadmap".
> ```

---

## Şu anda neredeyiz — v1.6.5+28, main

**Odak: Android / Google Play. Apple ASKIDA** (enrollment $99 ertelendi; iOS kodu
hazır tutuluyor ama yayınlanmayacak).

Backend + infra prod-ready, app'in tüm sekmeleri cihazda (iOS sim) doğrulandı +
çalışıyor. Bu oturumda (2026-05-25) main'e inen 3 PR:

- **#140 Device-QA + AI localization** — profil-kartı overflow, Coach empty-state,
  paywall/scan/dashboard i18n leak'leri, düzenlenebilir meal-name alanı, ve
  **backend AI food-name localization** (scan'de yiyecek adları artık kullanıcı
  dilinde — prod'a deploy edildi + `/scan` API ile doğrulandı: "Sebzeli pizza
  dilimi").
- **#141 Brand** — kod-çizimi gülümseyen su-damlası mark (`shared/widgets/smiling_drop.dart`,
  welcome/auth-gate/onboarding/su-kartında tutarlı) + tasarlanmış "Nuveli" PNG
  wordmark (`assets/icons/nuveli_wordmark.png`).
- **#142 Play-readiness P1** — AuthGate profil-error artık onboarding'e DÜŞÜRMÜYOR
  (retry ekranı); `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` izinleri söküldü;
  repo scratch temizliği (`flutter analyze lib/` temiz).

**Testler:** 503 flutter / 155 pytest, analyze temiz.
**Migration:** `user_profiles.language` prod Supabase'e UYGULANDI (2026-05-25).
**Paywall:** APK'da hâlâ RC **TEST** key — Play Billing config bekliyor (aşağıda).

---

## Google Play launch roadmap (kalan iş — audit 2026-05-25)

### 🔴 P0 — Launch blocker
1. **Monetization config** (SEN — dashboard işi, kod değil). Tam checklist:
   `docs/ops/revenuecat-play-billing-setup.md`. Özet: RC entitlement `premium` +
   offering (monthly+annual) + Play Console subscriptions (aktif) + RC↔Play
   service account. `RC_GOOGLE_KEY` (`goog_…`) `app/.env.production`'a.
2. **Signed AAB → Play Internal Testing.** `RC_GOOGLE_KEY` girilince
   `flutter build appbundle --release --dart-define-from-file=.env.production`
   (CLAUDE çalıştırır). Yükleme + tester ekleme SEN.
3. **Gerçek Android cihaz QA** (SEN — donanım). AAB kur, tüm akış + FCM push
   (sim APNS/Play Billing yapamaz).

### 🟠 P1 — kalan (karar/infra)
4. **Cron güvenilirliği.** APScheduler in-process (`APP_ENABLE_INTERNAL_CRON`),
   Render free-tier 15dk sleep'te gece 02:00 insight'ı kaçar. Seçenek: Render
   Cron Service (~$7/ay, `docs/ops/cron.md` Option B) ya da web'i keep-warm.
5. **Render cold-start.** Free-tier ilk istek ~30-50s + bazen hata (analytics'te
   görüldü). Launch güvenilirliği için paid instance ya da kabul.
   - (P1 kod fix'leri #4 AuthGate / #5 exact-alarm / #13 cleanup ✅ #142'de bitti.)

### 🟡 P2 — Store / legal (SEN — Play zorunlu)
- Store listing: başlık, kısa/uzun açıklama (TR + diğer diller), screenshot,
  feature graphic 1024×500, ikon.
- **Privacy policy URL** (hosted) + **Data Safety formu** (kamera, hesap,
  sağlık-benzeri veri).
- Content rating anketi.
- Hesap silme: in-app var (Ayarlar → delete account); Play web-URL de isteyebilir
  — doğrula.

### ⚪ P3 — temizlik/known
- CI broken (main, pre-existing — `project_ci_broken.md`): fix ya da admin-merge.
- weight_goals duplicate-active warning (kozmetik, UX etkisiz).
- Kalan AI-output: coach tip metinleri prompt'ta zaten localize; scan ✅.

---

## Mimari / kalıcı notlar

- **Coach** = insight-only (`/coach/chat`, `/coach/audio` YOK; mood-bubble ayrı
  lokal katman). Cron 02:00 UTC GPT-4o insight üretir.
- **Schema drift endemic** — yeni endpoint yazınca `information_schema.columns`
  ile prod kolon doğrula (pytest Supabase mock'lar, drift yakalamaz).
- **i18n iki track**: UI string'leri `.arb` (template `app_tr.arb`); AI çıktısı
  (yiyecek adı/insight) backend prompt + `_get_user_language` (drift-safe).
- **Squash-merge** convention (`… (#NN)`). **Her fix sonrası version bump +
  CHANGELOG.** **Co-Authored-By yok** (settings'te attribution kapalı).

## Memory state
| Memory | Özet |
|---|---|
| `user_ali.md` | Solo dev, Android-first, iOS paused |
| `project_launch_state_real.md` | UI artık shipped+verified; "PR merged ≠ prod-ready", cihaz QA şart |
| `project_i18n_activated.md` | i18n iki-track; scan AI-localize shipped+deployed+verified |
| `project_lang_migration_pending.md` | DONE — `user_profiles.language` prod'da |
| `project_schema_drift_endemic.md` | prod migration ≠ repo; her zaman doğrula |
| `feedback_verify_on_device.md` | test-green ≠ done; cihazda gez |
| `feedback_version_bump_per_fix.md` | her fix → version + CHANGELOG |

---

**Hazırlandı:** 2026-05-25 (Play-readiness audit + P1 fix'ler sonrası).
**Sonraki güncelleme:** Play Billing config bitince ya da AAB Internal Testing'e çıkınca.
