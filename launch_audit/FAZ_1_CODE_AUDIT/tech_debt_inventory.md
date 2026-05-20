# 💳 FAZ 1.4 — Tech Debt Inventory (Post-Launch Backlog)

**Tarih:** 2026-05-21
**Şapka:** AUDITOR
**Scope:** Launch-blocker olmayan ama v1.0.1+ için planlanmalı tüm tech debt

---

## 🎯 TL;DR

**Toplam tech debt borcu:** ~3-4 sprint (6-8 hafta)
**Launch blocker count:** 0

Borç dengeli, hızla amortize edilebilir.

---

## 📊 Tech Debt by Category

| Kategori | Item Sayısı | Effort | Priority |
|---|---|---|---|
| Dependency upgrades | 38 paket | 2-4 hafta | 🟡 v1.0.1 |
| Code modernization (withOpacity) | 61 yer | 1-2 saat | 🟡 v1.0.1 |
| Lint auto-fix | 76 issue | 5 dakika | 🟢 Pre-launch |
| Unused imports/elements | 4 | 5 dakika | 🟢 Pre-launch |
| Documentation sync (CLAUDE.md) | 1 | 30 dakika | 🟡 v1.0.1 |
| Dead code (auth_gate.dart TODO) | 1 yer | 5 dakika | 🟢 Pre-launch |
| File hygiene (analyze.txt) | 1 | 5 dakika | 🟢 Pre-launch |
| Backend structure / CLAUDE.md align | 1 | 30 dakika | 🟢 Düşük öncelik |

---

## 📝 Detaylı Liste

### TD-1: Riverpod 2 → 3 Migration
- **Dosya:** Tüm `lib/` (119 ref kullanımı)
- **Effort:** 1 sprint
- **Risk:** Yüksek (state management migration)
- **Bağımlılık:** Test coverage iyi olmalı (Phase 4'te kontrol)
- **Karar:** Post-launch v1.0.1

### TD-2: go_router 13 → 17 (4 major jump)
- **Dosya:** `lib/core/routing/`
- **Effort:** 1 sprint
- **Risk:** Yüksek (her major version breaking)
- **Plan:** Incremental upgrade (13→14→15→16→17)
- **Karar:** Post-launch v1.0.1

### TD-3: RevenueCat SDK 8 → 10
- **Dosya:** `lib/features/premium/services/revenue_cat_service.dart`
- **Effort:** 3-5 gün
- **Risk:** Yüksek (premium flow, gelir kritik)
- **Plan:** Sandbox extensive testing
- **Karar:** Post-launch v1.0.1

### TD-4: Apple Sign-In SDK 5 → 8
- **Dosya:** `lib/features/auth/services/apple_signin_service.dart`
- **Effort:** 1-2 gün
- **Risk:** Orta (auth path)
- **Karar:** Post-launch v1.0.1

### TD-5: Firebase Messaging 15 → 16
- **Dosya:** `lib/core/notifications/notification_service.dart`
- **Effort:** 1 gün
- **Risk:** Düşük
- **Karar:** Post-launch v1.0.1

### TD-6: `withOpacity` → `.withValues()` (61 yer)
- **Dosya:** 14 farklı UI dosyası
- **Effort:** 1-2 saat
- **Risk:** Çok düşük (cosmetic)
- **Karar:** Post-launch v1.0.1 (deprecation, future-proof için)

### TD-7: Freezed 2 → 3 + json_serializable upgrade
- **Dosya:** Model dosyaları (`*.freezed.dart`, `*.g.dart`)
- **Effort:** 1 gün
- **Risk:** Orta (regenerate, breaking syntax)
- **Karar:** Post-launch v1.0.1, codegen sprint'in parçası

### TD-8: CLAUDE.md Backend Folder Update
- **Detay:** `backend/app/api/routes/` → `backend/routers/` (gerçek yapı)
- **Effort:** 30 dakika
- **Karar:** v1.0.1, dokümantasyon sprint

### TD-9: `_premium_gating_examples.py` Cleanup
- **Detay:** Routers'tan örnek dosya, ya silinmeli ya `docs/examples/`'a taşınmalı
- **Effort:** 5 dakika
- **Karar:** v1.0.1

### TD-10: `analyze.txt` Tracking Cleanup
- **Detay:** 1.5MB analyze output repo'da commit'lenmiş
- **Effort:** 2 dakika
- **Karar:** **Pre-launch** (.gitignore'a ekle, `git rm --cached`)

### TD-11: 3 Unused Import Cleanup
- **Detay:** M-1, M-2, M-3 (Phase 1.1 raporu)
- **Effort:** 2 dakika
- **Karar:** **Pre-launch**

### TD-12: auth_gate.dart Dead Code
- **Detay:** TODO yorumuyla işaretli, DashboardScreen kullanıldığından beri ölü
- **Effort:** 5 dakika
- **Karar:** **Pre-launch**

### TD-13: 76 Lint Auto-Fix
- **Detay:** `dart fix --apply` ile çözülecek
- **Effort:** 5 dakika
- **Karar:** **Pre-launch**

### TD-14: Test Coverage Belirlenmemiş
- **Detay:** Mevcut Dart test 98, backend test 29 (CLAUDE.md). Coverage % yüzdesi bilinmiyor.
- **Effort:** Coverage rapor `flutter test --coverage && genhtml`
- **Karar:** Phase 4'te ölç, sonra karar

### TD-15: Backend Test Folder vs Production Code Separation
- **Detay:** Kontrol edilmeli (Phase 2'de)
- **Karar:** Phase 2

---

## 🎯 Pre-Launch Quick Wins (15 dakika)

Bunlar **launch öncesi yapılırsa puan ekler:**

1. ✅ `dart fix --apply` (5 dk) — 76 issue çözer
2. ✅ 3 unused import sil (2 dk) — warnings sıfıra iner
3. ✅ `auth_gate.dart` dead code sil (5 dk) — 1 TODO kapanır
4. ✅ `analyze.txt` untrack (2 dk) — repo temizliği
5. ✅ 1 unused element kontrol (Phase 1.1 M-4) (1 dk)

**Toplam: 15 dakika, Phase 1 puanı 88 → 95.**

---

## 🏆 Borç Yönetim Stratejisi

### v1.0.0 (Launch)
- Pre-launch quick wins (yukarıdaki 5 item)
- Risk: Düşük

### v1.0.1 (2-4 hafta sonra)
- Cosmetic: withOpacity, lint cleanups, doc sync
- Codegen sprint: freezed, build_runner
- Risk: Düşük

### v1.1.0 (1-2 ay sonra)
- Major upgrade sprint:
  - Riverpod 2 → 3
  - go_router 13 → 17
  - RevenueCat 8 → 10
- Risk: Yüksek, test coverage gerekli

### v1.2.0 (3-4 ay sonra)
- Native SDK upgrade:
  - Apple Sign-In 5 → 8
  - Firebase Messaging 15 → 16
- Risk: Orta

---

## 📋 Action Items

Bkz. yukarıdaki TD-1 ila TD-15 listesi. Pre-launch için TD-10, TD-11, TD-12, TD-13 önerilir.
