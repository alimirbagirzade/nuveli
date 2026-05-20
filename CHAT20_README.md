# 🚀 Nuveli — Chat 20 Launch Hazırlık Paketi

**Tarih:** 18 Mayıs 2026
**Hedef:** App Store + Google Play submission için tam dokümantasyon paketi.

---

## 📦 Paket İçeriği

5 KISIM halinde tamamlandı:
- **KISIM A** — Asset Üretim Rehberi (icons, splash, screenshots, feature graphic, promo video)
- **KISIM B** — Metadata & Copy (app name, descriptions, keywords, promo text, release notes)
- **KISIM C** — Privacy & Legal (Privacy Policy, ToS, Apple Privacy Label, Account Delete, Cookie Banner)
- **KISIM D** — Build Configs (pubspec, Info.plist, Android manifest, keystore, gitignore)
- **KISIM E** — Submission Workflow (App Store Connect, Play Console, TestFlight, build, upload, reviewer account, checklist, reject reasons)

---

## 📂 Klasör Yapısı

```
nuveli/
├── CHAT20_README.md (bu dosya)
└── launch_assets/
    ├── icons/
    │   └── ICON_SPEC.md
    ├── splash/
    │   └── SPLASH_SETUP.md
    ├── screenshots/
    │   └── SCREENSHOT_STORY.md
    ├── feature_graphic/
    │   └── FEATURE_GRAPHIC_SPEC.md
    ├── promo_video/
    │   └── PROMO_VIDEO_SPEC.md
    ├── metadata/
    │   ├── app_name_subtitle.md
    │   ├── app_description_en.md
    │   ├── app_description_tr.md
    │   ├── keywords.md
    │   ├── promotional_text.md
    │   ├── release_notes_v1.0.md
    │   └── category_age_rating.md
    ├── legal/
    │   ├── privacy_policy.md
    │   ├── terms_of_service.md
    │   ├── apple_privacy_label.md
    │   ├── account_delete_flow.md
    │   └── gdpr_cookie_banner.md
    ├── build_configs/
    │   ├── pubspec_final.yaml.md
    │   ├── Info.plist.md
    │   ├── android_build.md
    │   ├── keystore_setup.md
    │   └── gitignore_additions.md
    └── submission/
        ├── app_store_connect_form.md
        ├── google_play_console_form.md
        ├── testflight_workflow.md
        ├── build_commands.md
        ├── upload_workflow.md
        ├── reviewer_test_account.md
        ├── submit_checklist.md
        └── reject_reasons.md
```

---

## 🗓️ Önerilen Launch Timeline

### Hafta 1 — Hazırlık
- [ ] **Pazartesi-Salı:** Asset üretim (Figma'da icon, splash, screenshots)
- [ ] **Çarşamba:** Web sitesi (nuveli.app) — Privacy Policy + ToS yayınla
- [ ] **Perşembe:** Backend production deploy (Render)
- [ ] **Cuma:** Reviewer test account + sample data seed

### Hafta 2 — Build & Test
- [ ] **Pazartesi:** iOS IPA + Android AAB build
- [ ] **Salı:** TestFlight Internal + Play Internal Testing upload
- [ ] **Çarşamba-Perşembe:** Beta test (3-5 friend tester)
- [ ] **Cuma:** External beta (Apple Beta App Review submit)

### Hafta 3 — Public Beta
- [ ] Public link paylaş (Twitter, Reddit, Indie Hackers)
- [ ] 50-100 beta tester
- [ ] Feedback topla, critical bug fix'ler

### Hafta 4 — Submission
- [ ] **Pazartesi:** App Store Connect → Submit for Review
- [ ] **Pazartesi:** Play Console → Production rollout (20%)
- [ ] **Salı-Perşembe:** Apple review (24-72h)
- [ ] **Cuma:** Google Play review (3-7 gün)

### Hafta 5 — Launch
- [ ] Apple onay → Manuel release
- [ ] Google production → 50% → 100%
- [ ] **🎉 LAUNCH DAY**
- [ ] Product Hunt, Twitter, Email blast
- [ ] Crash monitoring, support inbox aktif

---

## 🎯 Kritik Başarı Faktörleri

### ✅ Mutlaka Yapılmalı
1. **Reviewer test account ÇALIŞIYOR** (test et!)
2. **Privacy Policy URL CANLI** (browser'da kontrol)
3. **Account deletion flow GERÇEKTEN siliyor**
4. **In-app subscription disclosure TAM**
5. **AI meal scan production'a bağlı**
6. **Crash-free start** (Sentry yeşil)

### ⚠️ Sık Yapılan Hatalar
1. Build number tekrarı (her upload'da +1 olmalı)
2. Keystore yedeklemeden Android upload
3. Privacy Policy URL erişilemez
4. Reviewer notes detaysız
5. Apple Sign-In eksik (Google login varsa zorunlu)
6. iOS PrivacyInfo.xcprivacy eksik (iOS 17+ zorunlu)

---

## 📋 Bu Paketten Sonra Kullanıcı Görevleri

Bu paket sana dokümanları verdi. Sıradaki adımlar **manuel iş**:

### Tasarım / Asset (Figma)
- [ ] App icon (1024×1024)
- [ ] Splash screen logo
- [ ] 6 adet screenshot (iOS 6.5", 5.5"; Android phone)
- [ ] Feature graphic (1024×500, Google Play)
- [ ] Promo video (opsiyonel)

### Web (nuveli.app)
- [ ] Landing page
- [ ] Privacy Policy sayfası (legal/privacy_policy.md içeriği)
- [ ] Terms of Service sayfası (legal/terms_of_service.md içeriği)
- [ ] Support sayfası
- [ ] Cookie banner (eğer Google Analytics kullanıyorsan)

### Backend
- [ ] Render.com production deployment
- [ ] API domain: api.nuveli.app
- [ ] Health endpoint
- [ ] Account delete endpoint
- [ ] 30-day cleanup cron

### Database (Supabase)
- [ ] Production project oluştur
- [ ] Schema apply
- [ ] RLS policies
- [ ] Storage bucket: meals
- [ ] Reviewer account + sample data seed

### App Store Connect / Play Console
- [ ] Apple Developer Program ($99/yıl)
- [ ] Google Play Developer ($25 one-time)
- [ ] Bundle ID: com.nuveli.app
- [ ] App oluştur (her iki platform)
- [ ] Tüm form'ları doldur (bu pakete göre)
- [ ] IAP products oluştur
- [ ] Screenshot/asset upload
- [ ] Submit

### Marketing
- [ ] Twitter @nuveli_app aktif
- [ ] Landing page waitlist toplama
- [ ] Press kit (logo, screenshots, about)
- [ ] Product Hunt launch (Salı sabahı önerilen)
- [ ] Sosyal medya post template'leri

---

## 💰 Tahmini Maliyetler

| Kategori | Tutar |
|---|---|
| Apple Developer Program | $99/yıl |
| Google Play Developer | $25 (tek seferlik) |
| Domain (nuveli.app) | ~$15/yıl |
| Web hosting (Vercel free / Netlify free) | $0 |
| Render.com backend | $7-25/ay (starter) |
| Supabase | $25/ay (Pro tier önerilen) |
| OpenAI API | $50-500/ay (kullanıma bağlı) |
| RevenueCat | $0 (free tier 10K MTR'a kadar) |
| Sentry | $0 (free tier 5K events/ay) |
| Firebase | $0 (Spark plan) |
| Avukat (legal review) | $500-2000 (opsiyonel ama önerilen) |
| Designer (Figma asset üretimi) | $200-1500 (kendin yapmıyorsan) |
| **İlk ay toplam (you only):** | **~$200-300** |
| **Aylık operasyonel:** | **~$100-600** |

---

## 🆘 Sorun Çıkarsa

### Apple Reject
1. Resolution Center'dan Apple ile iletişim
2. `submission/reject_reasons.md`'ye bak
3. Fix → build +1 → resubmit

### Google Play Reject
1. Play Console → Policy → Appeal
2. Justification yaz
3. Resubmit

### Build Hatası
1. `build_commands.md`'deki troubleshooting section
2. `flutter clean && flutter pub get` ile fresh start

### Acil Hotfix Gerekirse
1. Fix yap
2. Version: `1.0.0+2` (build number +1)
3. iOS: Transporter → upload → review (1-3 saat)
4. Android: Play Console → Production → new release → staged rollout

---

## 📞 Destek Kontakları

- **Apple Developer Support:** developer.apple.com/support
- **Google Play Console Support:** support.google.com/googleplay/android-developer
- **Supabase Support:** supabase.com/dashboard/support
- **RevenueCat Support:** revenuecat.com/support
- **Render Support:** render.com/docs/support

---

## ✨ Final Söz

Bu paketi takip ederek launch'ı 3-4 hafta içinde başarabilirsin. Her dokümanda kendi içinde alt-checklist'ler var. Sıra ile yap, panik yok.

**Önemli:** Submission'dan ÖNCE `submit_checklist.md`'yi mutlaka okumayı unutma. Çoğu reject sebebi orada listeli.

🚀 **Başarılar Ali!** Sonra Twitter'da launch'u görelim. 💙

—

*Bu paket Anthropic Claude tarafından üretildi.*
*Production'a çıkmadan önce her dokümanı kendi context'ine göre gözden geçirmen önerilir.*
