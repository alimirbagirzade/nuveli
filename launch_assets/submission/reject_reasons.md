# 🚫 Reject Reasons — Apple & Google

**Hedef:** Yaygın reject sebepleri, hangisi bizi etkileyebilir, nasıl önlenir veya düzeltilir.

---

## 🍎 Apple App Store — Reject Reasons

### Guideline 2.1 — App Completeness

#### 2.1 Bug / Crash on Launch
**Sebep:** App açılışta çöküyor, kritik feature broken.
**Önleme:**
- Reviewer hesabıyla cihazda manuel test
- Cold start çalışıyor mu?
- Internet bağlantısız nasıl davranıyor?

**Eğer reject olursa:**
- Crash log isteriz reviewer'dan
- Sentry'de aynı dönem crash var mı kontrol
- Hotfix → build +1 → resubmit

#### 2.1 Demo Account Doesn't Work
**Sebep:** Reviewer login yapamıyor.
**Önleme:**
- Reviewer credentials test edilmiş
- Şifrede invisible karakter yok
- Account locked değil, password reset gerekli değil

---

### Guideline 2.3.1 — Accurate Metadata

#### 2.3.1 Misleading Screenshots
**Sebep:** Screenshot'ta gösterilen özellik app'te yok.
**Bizim risk:** Düşük (screenshot'lar gerçek app içeriği)
**Önleme:** Screenshot'larda mockup değil, gerçek UI.

#### 2.3.1 Misleading Description
**Sebep:** Description'da yazılan özellik app'te yok.
**Bizim risk:** Düşük
**Önleme:** Description'da sadece çalışan özellikleri listele.

---

### Guideline 2.3.7 — App Name & Subtitle

#### 2.3.7 Keyword Stuffing in App Name
**Sebep:** "Nuveli - Best AI Calorie Counter Tracker Diet App 2026"
**Bizim risk:** Düşük (sadece "AI Calorie Coach" kullanıyoruz, fonksiyon)
**Önleme:** Marketing claim'i, rakip adı yok.

#### 2.3.7 Trademark Issues
**Sebep:** Marka tescili olmayan kelime, başkasının tescili.
**Bizim risk:** Orta (Nuveli marka kontrolü yapılmış olmalı)
**Önleme:**
- TPMK (Türkiye): turkpatent.gov.tr
- USPTO (US): tmsearch.uspto.gov
- EUIPO (EU): euipo.europa.eu

---

### Guideline 3.1.1 — In-App Purchase

#### 3.1.1 Using External Payment
**Sebep:** App içinde ödeme alıp Apple IAP'ı bypass ediyorsun.
**Bizim risk:** Yok (RevenueCat üzerinden Apple IAP kullanıyoruz)
**Önleme:** Tüm subscription/IAP Apple sistemi üzerinden.

#### 3.1.1 Linking to External Purchase
**Sebep:** "Subscribe on our website" diye external link.
**Bizim risk:** Düşük
**Önleme:** Web subscription mention etmiyoruz.

---

### Guideline 3.1.2 — Subscriptions

#### 3.1.2(a) Inadequate Subscription Disclosure
**Sebep:** Auto-renewal terms eksik.
**Bizim risk:** Düşük (paywall ve description'da tam disclosure var)
**Önleme:**
- Paywall'da: "Cancel anytime", "Auto-renews", price, period açıkça
- Description'da subscription terms var ✅

#### 3.1.2 No Restore Button
**Sebep:** "Restore Purchases" butonu eksik.
**Bizim risk:** Düşük (settings'te var)
**Önleme:** Paywall + Settings → "Restore Purchases" butonu.

---

### Guideline 4.0 — Design

#### 4.0 Poor UX
**Sebep:** App kullanımı zor, akış anlaşılmaz.
**Bizim risk:** Orta (mitigate: onboarding ve clear navigation)
**Önleme:**
- Beta testers'dan feedback al
- 5 saniyede ne yapacak kullanıcı bilmeli (homescreen)

#### 4.0 Spam / Low-Quality
**Sebep:** App basit, tekrar eden, kopya feeling.
**Bizim risk:** Düşük (Liquid Glass design unique)

---

### Guideline 4.2 — Minimum Functionality

#### 4.2 App is Just a Webview
**Sebep:** Native değil, sadece web wrap.
**Bizim risk:** Yok (Flutter native)

---

### Guideline 4.5 — Apple Sites and Services

#### 4.5.5 Using Apple Logos Wrong
**Sebep:** "Sign in with Apple" butonu Apple guideline'a uymuyor.
**Bizim risk:** Düşük (paket otomatik handle ediyor)
**Önleme:** `sign_in_with_apple` paketi standart button kullanıyor.

---

### Guideline 4.8 — Sign in with Apple

#### 4.8 Missing Sign in with Apple
**Sebep:** Google/Facebook login varsa Apple zorunlu.
**Bizim risk:** Yok (Apple Sign-In implement edildi)
**Önleme:** ✅ Sign in with Apple paketi entegre.

---

### Guideline 5.1.1 — Data Collection

#### 5.1.1(i) Permission Strings Missing or Vague
**Sebep:** `NSCameraUsageDescription` "App needs camera" yazıyor.
**Bizim risk:** Düşük (detaylı string'ler kullandık)
**Önleme:** "Nuveli uses the camera to scan your meals with AI for instant calorie tracking."

#### 5.1.1(v) Account Deletion Missing
**Sebep:** App içinden hesap silinemiyor.
**Bizim risk:** Yok ✅ (implement edildi)
**Önleme:** Settings → Account → Delete Account flow.

---

### Guideline 5.1.2 — Data Use

#### 5.1.2 Unauthorized Data Use
**Sebep:** Health data'yı reklam için kullanmak gibi.
**Bizim risk:** Yok (reklam yok, data sadece functionality için)
**Önleme:** Privacy Policy'de net açıklama.

---

### Guideline 5.1.5 — Location Services

#### 5.1.5 Location Not Used
**Sebep:** Location permission istiyorsun ama kullanmıyorsun.
**Bizim risk:** Yok (location permission istemiyoruz)

---

### Guideline 5.2.1 — Intellectual Property

#### 5.2.1 Copyright Infringement
**Sebep:** Başkasının kodu/içeriği var.
**Bizim risk:** Yok (orijinal kod)

---

## 🤖 Google Play — Reject Reasons

### Privacy & Data
#### Privacy policy required
**Sebep:** Hassas permission var ama Privacy Policy yok.
**Bizim risk:** Yok ✅
**Önleme:** Privacy Policy URL girildi.

#### Data safety form incomplete
**Sebep:** Data Safety section doldurulmamış.
**Bizim risk:** Düşük (eksiksiz dolduracağız)
**Önleme:** Her data type için form'u tamamla.

#### Sensitive permissions without justification
**Sebep:** Camera, contacts, vb. izinler kullanım açıklaması yok.
**Bizim risk:** Düşük (justification yazıldı)
**Önleme:** Play Console → App content → Permission declarations.

---

### Health & Fitness
#### Unsubstantiated health claims
**Sebep:** "Lose 10 kg in 30 days" gibi tıbbi claim.
**Bizim risk:** Düşük
**Önleme:** Description'da "Not medical advice" disclaimer var.

#### Targeting health conditions
**Sebep:** "Treats diabetes" gibi spesifik koşul targeti.
**Bizim risk:** Yok (genel health & wellness)

---

### IAP / Billing
#### Google Play Billing required
**Sebep:** Digital good satıyorsun ama Google Billing yerine başka sistem.
**Bizim risk:** Yok (Google Play Billing kullanılıyor)

#### Subscription disclosure inadequate
**Sebep:** Auto-renewal, cancel, price açık değil.
**Bizim risk:** Düşük (paywall'da full disclosure)

---

### Permissions
#### Background location restricted
**Sebep:** Background location izni istiyorsun ama core feature değil.
**Bizim risk:** Yok (location yok)

#### Health Connect permissions misused
**Sebep:** READ_STEPS gibi izinler ama declaration yok.
**Bizim risk:** Düşük (Premium feature olarak declare edildi)
**Önleme:** Play Console → Health Connect permissions declaration.

#### POST_NOTIFICATIONS missing rationale
**Sebep:** Android 13+ notification permission ama açıklama yok.
**Bizim risk:** Düşük (in-app rationale UI var)

---

### Misleading
#### Misleading screenshots
**Sebep:** Screenshot ≠ gerçek app.
**Bizim risk:** Düşük

#### Misleading title or description
**Sebep:** "#1 calorie app" gibi claim.
**Bizim risk:** Yok

---

### Account Deletion (Mart 2024'ten zorunlu)
#### App account requires deletion in-app
**Sebep:** Hesap silme sadece web'de.
**Bizim risk:** Yok ✅

---

### Target API Level
#### Target API too old
**Sebep:** 2024'te targetSdk < 34.
**Bizim risk:** Yok (targetSdk = 34)

---

## 📋 Reject Sonrası Apel Stratejisi

### Apple Resolution Center

Apple reject email gönderir:
```
Subject: Notice of App Review for Nuveli

We reviewed your submission and found issues:

Guideline 5.1.1(v) - Data Collection and Storage
Your app does not provide an in-app method to delete the user's account.

Next Steps:
- Review the guideline information
- Make appropriate changes
- Resubmit or reply via Resolution Center
```

#### Adım 1: Reject sebebini anla
- Hangi guideline?
- Hangi spesifik feature?
- Apple ne istiyor?

#### Adım 2: Cevap ver veya düzelt

**Eğer yanlış anlama varsa:**
```
Hello Apple Review Team,

Thank you for your review. I'd like to clarify the account deletion functionality, which I believe meets Guideline 5.1.1(v):

In-app account deletion is available at:
Settings → Account → Delete Account

To test:
1. Log in with reviewer@nuveli.app / ReviewPass2026!
2. Tap the bottom-right "Profile" tab
3. Tap "Settings" gear icon
4. Tap "Account"
5. Scroll to "Danger Zone"
6. Tap "Delete Account" (red button)
7. Type "DELETE" to confirm
8. Tap "Delete Forever"

Account is marked for deletion and data is permanently removed within 30 days.

I've also included a 30-second screen recording demonstrating this flow.

Please let me know if you need additional information.

Best,
Ali Mirbağırzade
```

**Eğer gerçekten eksiklik varsa:**
- Fix yap
- Build number +1
- Resubmit
- Resolution Center'da yanıt: "Fixed in build X.Y.Z (BN)"

#### Adım 3: Tekrar bekleme
- Resolution Center yanıtı: 24-48 saat
- Yeni build review: 24-72 saat

### Google Play Appeal

Google Play reject mail:
```
Hello,

Your recent submission of Nuveli (com.nuveli.app) was rejected because:
- Policy violation: Permission policy violation (CAMERA without justification)

Please review your submission and address the issues.
```

#### Adım 1: Play Console → Policy → "Appeal"
#### Adım 2: Justification yaz
#### Adım 3: Submit appeal

Google appeal süresi: 1-3 gün.

---

## 🎯 Reject Önleme Strategy (Submit Öncesi)

### Apple için son kontroller
1. ✅ Reviewer notes **çok detaylı** (test instruction)
2. ✅ Test account **çalışıyor** (kendin login ol)
3. ✅ Privacy Policy URL **erişilebilir**
4. ✅ Account delete flow **çalışıyor**
5. ✅ All permission strings **detaylı**
6. ✅ Subscription disclosure **tam**
7. ✅ Sign in with Apple **çalışıyor**

### Google Play için son kontroller
1. ✅ Data Safety form **eksiksiz**
2. ✅ Sensitive permissions **justified**
3. ✅ Health features **declared as not medical**
4. ✅ Account deletion **in-app**
5. ✅ targetSdk = 34
6. ✅ Privacy Policy URL **canlı**

---

## 📊 İstatistikler

### Apple Reject Oranları (2024 ortalama)
- İlk submission: **~30% reject**
- Major reasons (sıralı):
  1. Bugs/Crashes (Guideline 2.1)
  2. Privacy/Data (5.1.x)
  3. UX issues (4.0)
  4. Subscription disclosure (3.1.2)

### Google Play Reject Oranları (2024 ortalama)
- İlk submission: **~15% reject**
- Major reasons:
  1. Data Safety form incomplete
  2. Sensitive permission justification
  3. Misleading content
  4. Policy violations (health claims)

---

## ⚡ Hızlı Hotfix Süreci

Reject sonrası hızlı resubmit:

### iOS
```bash
# 1. Fix yap (kod değişikliği)

# 2. Build number artır (pubspec.yaml)
# version: 1.0.0+2  (önceki +1'di)

# 3. Build
./scripts/build_all.sh 2

# 4. Upload
# Transporter → drag IPA

# 5. Processing bekle (~15 dk)

# 6. App Store Connect:
# - Build seç (yeni build)
# - Submit for Review
```

### Android
```bash
# 1. Fix yap

# 2. Build number artır (pubspec.yaml)
# version: 1.0.0+2

# 3. Build
flutter build appbundle --release \
  --build-name=1.0.0 \
  --build-number=2

# 4. Play Console upload
# - Production → Create new release
# - Upload new AAB
# - Same release notes
# - Resubmit
```

---

## ✅ Reject Recovery Checklist

Reject geldikten sonra:
- [ ] Email/notification'u dikkatle oku
- [ ] Hangi guideline ihlali tam anladım
- [ ] Fix gerekiyor mu yoksa açıklama yeterli mi?
- [ ] Fix yapıyorsam: build number artır
- [ ] Test et (özellikle reject olan feature)
- [ ] Resolution Center'a detaylı cevap yaz
- [ ] Resubmit
- [ ] Bekleme (24-72 saat)
- [ ] Onay geldiğinde marketing planına devam

---

**Hatırlatma:** Reject normaldir. Ortalama 1-2 reject ile sonunda onay alırsın. Her reject'ten ders al, dokümante et, sonraki sürümde tekrarlama.
