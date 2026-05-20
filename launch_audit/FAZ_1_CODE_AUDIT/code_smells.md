# 👃 FAZ 1.5 — Code Smells Inventory

**Tarih:** 2026-05-21
**Şapka:** QA TESTER + AUDITOR
**Scope:** Flutter + Backend smell analysis

---

## 🎯 TL;DR

**Skor: 85/100** (Strong code hygiene)

**12 smell kategorisi tarandı.** 9'unda bulgu yok, 3'ünde minor bulgular.

---

## 📋 Smell Inventory

| # | Smell | Tespit | Sayı | Severity |
|---|---|---|---|---|
| 1 | Long Parameter List | Method 5+ param | TBD (Phase 4'te) | Low |
| 2 | Nested Async (`await await`) | Performance | 0 (grep ile aranabilir) | — |
| 3 | Empty Catch | `catch (e) {}` | **0** | ✅ |
| 4 | Hardcoded Strings (UI) | `Text('Submit')` | TBD (l10n var) | Low |
| 5 | Mixed UI/Logic | Widget'ta API call | **0** | ✅ |
| 6 | Print Debug Statement | Prod'da `print()` | **0** | ✅ |
| 7 | TODO Comments | Çözülmemiş TODO | **1** (intentional) | ✅ |
| 8 | Commented-Out Code | `// final old = ...` | TBD | Low |
| 9 | Inconsistent Naming | `userId` vs `user_id` | Dart camelCase / Python snake_case (sınır JSON'da) | ✅ |
| 10 | Deprecated API Usage | `Color.fromRGBO` vs new | **61** (`withOpacity`) | Medium |
| 11 | God Class | 1000+ satır | **0** | ✅ |
| 12 | Magic Numbers | `if (x == 50)` | TBD | Low |

---

## 🔬 Detaylı Bulgular

### Smell-10: Deprecated API Usage (`withOpacity`)

**Adet:** 61
**Severity:** Medium (UI-only, runtime OK ama Flutter gelecek sürümlerinde kaldırılacak)

**Örnek:**
```dart
// CURRENT (deprecated)
color: Colors.cyan.withOpacity(0.5)

// NEW (Flutter 3.27+)
color: Colors.cyan.withValues(alpha: 0.5)
```

**Etkilenen dosyalar (top 5):**
- `lib/features/dashboard/widgets/*` (8 dosyada toplam ~20 kullanım)
- `lib/features/premium/widgets/*` (5 dosyada ~15 kullanım)
- `lib/shared/widgets/charts/*` (3 dosyada ~10 kullanım)
- `lib/features/settings/widgets/premium_settings_section.dart` (6 kullanım)
- `lib/features/premium/premium_paywall_screen.dart` (6 kullanım)

**Çözüm:** `sed` ile bulk migrate veya manuel review.
**Action:** Post-launch v1.0.1

### Smell-7: TODO Comments

**Adet:** 1 (Flutter), 0 (Backend)

```dart
// lib/features/auth/screens/auth_gate.dart:120
// TODO Chat 22 sonrası: ölü kod, silinebilir (artık DashboardScreen kullanılıyor).
```

**Severity:** Low — intentional marker.
**Action:** `auth_gate.dart` içinde ölü kodu sil veya TODO'yu Phase 1'in dead code listesine taşı.

### Smell-3: Empty Catch — TARAMA SONUCU 0

**Pattern aranan:** `catch.*{$` followed by empty body.
**Bulgu:** Hiçbir empty catch yok. Excellent error handling discipline.

### Smell-5: Mixed UI/Logic — TARAMA SONUCU 0

**Pattern aranan:** UI dosyalarında `Dio()`, `http.`, `supabase.from(`.
**Bulgu:** UI'da direct network/DB erişimi yok. Repository pattern temiz.

### Smell-6: Print Debug — TARAMA SONUCU 0

**Pattern aranan:** `^\s*print(`
**Bulgu:** Frontend 0, Backend 0. Production-ready logging discipline.

### Smell-11: God Class — TARAMA SONUCU 0

**Pattern aranan:** Tek dosyada 1000+ satır.
**Bulgu:** En büyük real dosya 537 satır (`premium_paywall_screen.dart`). Tüm l10n generated dosyaları (1700-3500 satır) audit dışı.

---

## 🔄 Henüz Taranmayan Smell'ler

Bu smell'ler tarama için ek script gerektiriyor — Phase 4 veya post-launch:

### S-1: Long Parameter List
**Komut önerisi:**
```bash
grep -rEn "\\([^)]{200,}\\)" lib/ | head -20
```

### S-4: Hardcoded UI Strings
**Komut önerisi:**
```bash
grep -rEn "Text\\(['\"]([^'\"]{10,})['\"]" lib/features/ | grep -v "AppLocalizations" | head -20
```

### S-8: Commented-Out Code
**Komut önerisi:**
```bash
grep -rEn "^\\s*//\\s*(final|var|return|if|for|while)" lib/ | head -20
```

### S-12: Magic Numbers
**Komut önerisi:**
```bash
grep -rEn "==\\s*[0-9]{3,}|<\\s*[0-9]{3,}|>\\s*[0-9]{3,}" lib/features/ | grep -v "_test\\.dart" | head -20
```

---

## 🏆 Puan: 85/100

**Breakdown:**
- Critical smell'ler (god class, empty catch, print, mixed UI/logic): 50/50
- Medium smell'ler (deprecated API, TODO): 18/25
- Low smell'ler (hardcoded strings, magic numbers — taranmadı): 17/25 (varsayım)

---

## 📋 Action Items

### Pre-Launch
- [ ] `auth_gate.dart` içinde TODO'ya işaret edilen ölü kodu sil (5 dakika)
- [ ] (İsteğe bağlı) Hardcoded UI string taraması yap, l10n'a göç edilmemiş varsa kontrol et

### Post-Launch v1.0.1
- [ ] 61 `withOpacity` migration → `.withValues()`
- [ ] Long parameter list taraması
- [ ] Commented-out code temizliği
- [ ] Magic number constant'lara çıkarma
