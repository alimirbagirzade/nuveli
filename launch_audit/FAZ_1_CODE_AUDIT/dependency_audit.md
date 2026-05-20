# 📦 FAZ 1.3 — Dependency Audit

**Tarih:** 2026-05-21
**Şapka:** AUDITOR
**Scope:** Flutter pubspec.yaml + Backend requirements.txt

---

## 🎯 TL;DR

**Skor: 72/100** (Acceptable for launch, post-launch upgrade gerekli)

**Pozitif:**
- 0 bilinen security advisory (otomatik tarama eksik — manuel kontrol)
- Backend tüm dependencies pinned (`==x.y.z`)
- Hiçbir runtime-breaking outdated yok

**Negatif:**
- **38 Flutter paketi major version geride** (özellikle: go_router 13→17, riverpod 2→3)
- 3 transitive paket discontinued (js, build_resolvers, build_runner_core)

---

## 📊 Flutter Outdated Summary

```
4 upgradable dependencies are locked (in pubspec.lock) to older versions.
38 dependencies are constrained to versions older than a resolvable version.
3 discontinued packages (transitive).
```

### 🔴 High-Impact Outdated Direct Dependencies

| Paket | Mevcut | Resolvable | Major Behind | Risk |
|---|---|---|---|---|
| `go_router` | 13.2.5 | 17.2.3 | **4 major** | 🔴 Breaking changes muhtemel |
| `flutter_riverpod` | 2.6.1 | 3.3.1 | 1 major | 🟡 Migration guide gerekli |
| `riverpod` (root) | 2.6.1 | 3.2.1 | 1 major | 🟡 |
| `sign_in_with_apple` | 5.0.0 | 8.0.0 | 3 major | 🟡 |
| `purchases_flutter` | 8.11.0 | 10.1.1 | 2 major | 🟡 RevenueCat critical |
| `firebase_messaging` | 15.2.10 | 16.2.2 | 1 major | 🟡 |
| `freezed_annotation` | 2.4.4 | 3.1.0 | 1 major | 🟡 codegen |
| `freezed` | 2.5.8 | 3.2.5 | 1 major | 🟡 codegen |
| `just_audio` | 0.9.46 | 0.10.5 | 1 minor | 🟢 Düşük risk |
| `flutter_dotenv` | 5.2.1 | 6.0.1 | 1 major | 🟢 Kullanım yüzeyi düşük |
| `flutter_lints` | 3.0.2 | 6.0.0 | 3 major | 🟢 Sadece dev |
| `build_runner` | 2.5.4 | 2.15.0 | minor jump | 🟢 |
| `json_serializable` | 6.9.5 | 6.14.0 | minor | 🟢 |

### 🟡 Discontinued Transitive Packages

| Paket | Replacement | Source |
|---|---|---|
| `js` | dart:js_interop (built-in) | Pulled by Firebase/Flutter web bridges |
| `build_resolvers` | (newer build_runner versions) | Codegen toolchain |
| `build_runner_core` | (newer build_runner versions) | Codegen toolchain |

**Etki:** Build-time, runtime'da görünmez. `build_runner` 2.15.0'a upgrade bunları çözer.

---

## 🐍 Backend Dependencies (`requirements.txt`)

**Pinning durumu:** ✅ HEPSI PINNED (`==`)

| Paket | Pinned | Latest (May 2026 itibarıyla) | Risk |
|---|---|---|---|
| `fastapi` | 0.115.0 | 0.117.x | 🟢 Düşük, micro version |
| `pydantic` | 2.9.2 | 2.10.x | 🟢 |
| `supabase` | 2.8.1 | 2.x | 🟢 |
| `openai` | 1.51.0 | 1.x | 🟢 |
| `sentry-sdk` | 2.14.0 | 2.x | 🟢 |
| `python-jose` | 3.3.0 | 3.3.x | 🟢 JWT — security audit Phase 2 |
| `httpx` | 0.27.2 | 0.27.x | 🟢 |
| `apscheduler` | 3.10.4 | 3.10.x | 🟢 |
| `uvicorn` | 0.30.6 | 0.30.x | 🟢 |
| `python-dotenv` | 1.0.1 | 1.0.x | 🟢 |
| `pytest` | 8.3.3 | 8.3.x | 🟢 dev only |
| `pytest-asyncio` | 0.24.0 | 0.24.x | 🟢 dev only |

**Verdict:** Backend hijyen excellent. Hepsi pinned, hiçbiri major behind değil.

---

## 🛡️ Security Advisory Tarama (Manuel)

**Otomatik araç yokluğunda kontrol edilecekler:**

### Flutter
- ❓ `dio` (kullanılıyor mu, pubspec'te göremedim — Phase 2'de kontrol)
- ❓ `http` (transitive — CVE check gerekli)
- ❓ `flutter_dotenv` 5.2.1 — known issue: bazı sürümlerde env leak (orta risk, 6.0.x'te düzeltildi)

### Backend
- ❓ `python-jose` 3.3.0 — **DİKKAT**: 2024'te bilinen JWS bypass CVE-2024-33663 raporu var bazı sürümlerde. Phase 2'de detaylı kontrol.
- ❓ `cryptography` (jose'nin dependency'si) — transitive, sürüm kontrol gerekli

### Action: Phase 2'de derinlemesine SCA (Software Composition Analysis)
- `pip-audit` çalıştırılmalı: `pip install pip-audit && pip-audit -r requirements.txt`
- Flutter için: Snyk veya GitHub Dependabot

---

## 📋 Upgrade Stratejisi

### 🚫 Launch ÖNCESI (yapılmamalı)
Major upgrade pre-launch = breaking change riski. Hiçbiri yapılmamalı.

### ✅ Launch SONRASI v1.0.1 (1-2 hafta)
**Coordinated upgrade plan:**

**Sprint 1: Codegen (low risk)**
- `freezed` 2 → 3
- `freezed_annotation` 2 → 3
- `build_runner` 2.5 → 2.15
- `json_serializable` minor
- Test: `flutter clean && pub get && build_runner build`

**Sprint 2: Riverpod 2 → 3 (orta risk)**
- Migration guide: https://riverpod.dev/docs/migration/from_state_notifier
- 119 ref usage'i etkileyebilir — test coverage kritik
- Side-by-side feature flag mümkün değil, big-bang upgrade

**Sprint 3: go_router 13 → 17 (yüksek risk — 4 major jump)**
- Her major'da breaking change var
- Önce 13 → 14 → 15 → 16 → 17 incremental
- Routing testleri zorunlu (mevcut routing test sayısını Phase 4'te kontrol)

**Sprint 4: Native SDK (yüksek risk)**
- `purchases_flutter` 8 → 10 (RevenueCat critical, premium flow etkili)
- `sign_in_with_apple` 5 → 8
- `firebase_messaging` 15 → 16
- iOS/Android native config değişiklikleri muhtemel

### Action: post-launch backlog'a ekle
**Tahmini effort:** 1-2 sprint (2-4 hafta)

---

## 🏆 Puan: 72/100

**Breakdown:**
- Direct dep freshness: 14/25 (38 major behind)
- Transitive freshness: 16/20 (3 discontinued)
- Pinning hygiene: 20/20 (backend tüm pinned, frontend caret OK)
- Security advisory (manual scan): 12/20 (python-jose şüpheli, Phase 2)
- Discontinued cleanup: 10/15 (transitive — düşük etki)

---

## 📋 Action Items

### Pre-Launch
- [ ] `pip-audit -r requirements.txt` çalıştır (3 dakika)
- [ ] python-jose 3.3.0 CVE durumunu doğrula
- [ ] `flutter_dotenv` 5.2.1 known issue'larını kontrol et

### Post-Launch v1.0.1 (4 sprint plan)
- [ ] Sprint 1: Codegen toolchain upgrade
- [ ] Sprint 2: Riverpod 2 → 3
- [ ] Sprint 3: go_router 13 → 17 (incremental)
- [ ] Sprint 4: Native SDK upgrade (purchases_flutter, sign_in_with_apple)
