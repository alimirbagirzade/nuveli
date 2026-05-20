# 📱 FAZ 5 — Device Matrix Test

**Tarih:** Pre-launch
**Beklenen süre:** 3-4 saat (gerçek cihaz veya simulator)

---

## 🎯 Test Matrix (8 cihaz × 5 senaryo)

|  | Login | Meal Scan | Analytics | Premium | Notifications |
|---|---|---|---|---|---|
| iPhone SE (3rd gen) | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| iPhone 12 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| iPhone 14 Pro Max | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| iPad Pro 12.9" | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Pixel 5 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Galaxy S22 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Galaxy Tab S8 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Old Android (API 23) | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |

✅/❌/➖ ile doldur.

**Minimum:** Her cihaz Login + Meal Scan + Premium çalışmalı.
**Ideal:** Hepsi yeşil.

---

## 📐 Screen Size Audit

Test breakpoint'leri (simulator'da yeterli):

| Width | Cihaz | Kontrol |
|---|---|---|
| 320pt | iPhone SE / iPod 7 | Text overflow var mı (özellikle TR uzun kelimeler) |
| 375pt | iPhone 11/12 mini | Button hizalama |
| 414pt | iPhone Pro Max | Layout luxury |
| 768pt | iPad mini | Bottom sheet sığar mı |
| 1024pt | iPad Pro | Tablet layout, max-width gerekli mi |
| 1366pt | iPad Pro 12.9 landscape | Aşırı geniş layout dağılmıyor mu |

**Her ekranda ✓:**
- [ ] Text overflow yok (özellikle TR)
- [ ] Button tıklanabilir (min 44x44pt iOS, 48x48dp Android)
- [ ] Bottom sheet ekrana sığar
- [ ] Modal full-screen mi adaptive mi (iPad'de tablet layout)
- [ ] Keyboard açılınca form scroll çalışır

---

## 🌍 Localization Test (TR + EN minimum + 5 ekstra dil)

7 dil destekleniyor: TR, EN, DE, FR, ES, IT, RU.

Settings → Language → her dile geç, 3 ekran kontrol:
- [ ] Dashboard (greeting, summary)
- [ ] Settings (delete account uyarısı doğru çevrilmiş)
- [ ] Paywall (currency formatting)

**Önemli kontroller:**
- [ ] iOS permission popup → kullanıcının diliyle uyumlu (M-Phase 2 not'u; muhtemelen sadece TR şu an)
- [ ] Tarih formatı locale-aware (TR: 21 Mayıs 2026 vs EN: May 21, 2026)
- [ ] Para birimi: ₺ (TR) vs $ / € (diğer)
- [ ] Number formatting: 1,000 vs 1.000

---

## ♿ Accessibility (VoiceOver / TalkBack)

### iOS — VoiceOver
**Açma:** Settings → Accessibility → VoiceOver → On

5 ekranı swipe ile dolaş, hepsinde:
- [ ] Her butonun semantic label'ı okunuyor
- [ ] Image'lar "Image" değil açıklama veriyor (örn: "User avatar")
- [ ] Focus order mantıklı (üstten alta)
- [ ] Form field'lar label + value okuyor

### Android — TalkBack
**Açma:** Settings → Accessibility → TalkBack → On
Aynı kontroller.

### Color Contrast
**Tool:** Chrome DevTools veya online checker
**Hedef:** WCAG AA = 4.5:1 (text), 3:1 (UI elements)

Spot check:
- [ ] Primary cyan (#00D4FF) on dark (#0B1A3D) → ratio?
- [ ] Secondary text on background → ratio?

### Dynamic Type
Settings → Display & Brightness → Text Size → en büyüğe (iOS)
- [ ] UI bozulmuyor (text wrap, button shrink)

### Reduce Motion
Settings → Accessibility → Motion → Reduce Motion On
- [ ] Animasyonlar kapanıyor veya kısa

---

## iOS Version Compatibility

| iOS | Min Required | Cihaz |
|---|---|---|
| 13.0 | minimumOSVersion | Eski iPhone 6s/7 (eğer destek varsa) |
| 15.x | Common | iPhone 8/X civarı |
| 17.x | Current | iPhone 12+ |
| 18.x | Latest | iPhone 15/16 |

**Test her sürümde:**
- [ ] App açılıyor (no crash on launch)
- [ ] Apple Sign-In çalışıyor (iOS 13+)
- [ ] Push notification permission popup çalışıyor (iOS 16+ farklı)
- [ ] PrivacyInfo.xcprivacy reading working (iOS 17+)

---

## Android Version Compatibility

| API | Android | Cihaz |
|---|---|---|
| 23 | 6.0 Marshmallow | Eski/budget |
| 28 | 9.0 Pie | Common |
| 33 | 13 | Tiramisu |
| 34 | 14 | Latest |

**Test her sürümde:**
- [ ] App açılıyor
- [ ] Camera permission popup çalışıyor (runtime, API 23+)
- [ ] POST_NOTIFICATIONS permission (API 33+ özel)
- [ ] Storage permission scoped storage uyumlu (API 30+)

---

## Results Template

```
Device Matrix: __ / 40 cells ✅
Screen Sizes:  __ / 6 breakpoints ✅
Localization:  __ / 7 languages ✅
A11y:          __ / 5 checks ✅
iOS Versions:  __ / 4 ✅
Android Versions: __ / 4 ✅

CRITICAL FAILS: <buraya>
```

**Pre-Launch Bar:** ≥ 30/40 matrix cells pass.
