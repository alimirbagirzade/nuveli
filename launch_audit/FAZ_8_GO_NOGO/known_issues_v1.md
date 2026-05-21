# 📋 Known Issues v1.0 — Launch'la Birlikte Giden

**Tarih:** 2026-05-21
**Hedef:** v1.0.1 (2-4 hafta sonra) bunları çöz

---

## 🟡 UX / Polish

| ID | Konu | Etki | Effort | Hedef |
|---|---|---|---|---|
| ~~K-1~~ | ~~61 `withOpacity` deprecation~~ | ✅ Migrated to `.withValues(alpha:)` pre-launch | — | DONE |
| ~~K-2~~ | ~~iOS permission strings sadece TR~~ | ✅ 7 lproj/ files shipped in PR #62 | — | DONE |
| K-3 | Light mode yok | Accessibility preference | 1 sprint | v1.1 |
| K-4 | iPad layout suboptimal | Tablet kullanıcı | 1 sprint | v1.1 |

## 🟡 Features

| ID | Konu | Etki | Hedef |
|---|---|---|---|
| ~~K-5~~ | ~~Google Sign-In yok~~ | ✅ Service + UI + Firebase + Supabase wiring all shipped (PR #66 + #69). Smoke test pending on device. | DONE |
| K-6 | Apple Watch app yok | Premium audience | v1.2 |
| K-7 | Web app yok (Flutter web) | Desktop kullanıcı | v1.2 |
| K-8 | Social features yok | Engagement (intentional) | v1.5+ |
| ~~K-9~~ | ~~Export Data feature yok~~ | ✅ shipped pre-launch — `GET /me/export` + Settings tile + share sheet (GDPR Art. 20) | DONE |

## 🟡 Tech Debt

| ID | Konu | Etki | Hedef |
|---|---|---|---|
| K-10 | Riverpod 2 → 3 | Major migration | v1.1 |
| K-11 | go_router 13 → 17 | 4 major jump | v1.1 |
| K-12 | RevenueCat 8 → 10 | Revenue critical (test gerekir) | v1.1 |
| K-13 | Backend rate limiting (slowapi) | Brute force koruma | v1.0.1 |
| K-14 | CLAUDE.md backend folder outdated | Doc sync | v1.0.1 |

## 🟡 AI / Content

| ID | Konu | Etki | Hedef |
|---|---|---|---|
| K-15 | AI yemek tanıma yanlış olabilir | Model limitation | Continuous improvement |
| K-16 | Coach persona sayısı sınırlı | UX | v1.2 |

---

## 📊 Backlog Sprint Plan

### v1.0.1 (Hafta 1-2)
- K-1: withOpacity migration
- K-2: iOS permission i18n
- K-5: Google Sign-In
- K-13: Backend rate limiting
- K-14: Doc sync
- Critical bug fixes (post-launch feedback)

### v1.1.0 (Hafta 3-6)
- K-3: Light mode
- K-4: iPad layout
- K-9: Export Data
- K-10: Riverpod 2→3
- K-11: go_router 13→17
- K-12: RevenueCat 8→10

### v1.2.0 (Hafta 7+)
- K-6: Apple Watch
- K-7: Flutter web
- K-16: More coach personas

---

## ✅ Doğru Tutum

> "Mükemmel olmak iyi olmanın düşmanıdır."
> v1.0 = "good enough to launch"
> v1.0.1, v1.1, v1.2 = ittirimle iyileştirme

Launch sonrası ilk haftadaki kullanıcı feedback'i v1.1 backlog'unu **yeniden önceliklendirir**.
