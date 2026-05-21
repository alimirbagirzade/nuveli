# 🛠️ Missing UI Implementation Plan

**Tarih:** 2026-05-21
**Tetikleyici:** Chat 25 smoke test — dashboard üzerinde **Add Food + Scan + Analytics + Profile** bottom nav butonlarının hepsi `_showComingSoon` toast veriyordu. Add Food butonu da `'AI Meal Scan ships in Chat 5'` placeholder'ı.

Bu, Chat 25 audit'inin yakalayamadığı bir scope eksiği. Audit kodu denetledi ama **eksik UI**'yi check etmedi.

---

## 🔍 Reality Check

Smoke testten sonra detaylı recon:

### ✅ Var (tam built)
- `features/auth/` — 7 screen: welcome, login, signup, forgot, reset, email_verify, onboarding
- `features/dashboard/` — read-only dashboard + 6 widget (header, summary, macros, water_quick, meals_section, add_food_button)
- `features/profile/goals_profile_screen.dart` — **352 satır, full ekran**. Includes:
  - ProfileHeader
  - DailyCalorieTargetCard
  - WeightGoalCard + sheet
  - WeightLogSheet
  - GoalsRow
  - ProgressSection
  - RecommendationsSection
- `features/settings/` — Account delete + Export + Sign out + notification prefs
- `features/premium/` — Paywall + Success
- `features/notifications/settings_screen.dart`
- `shared/widgets/charts/` — **8 chart widgets ready:**
  - macro_donut_chart, water_ring_chart, weight_line_chart
  - consistency_bar_chart, weekly_bar_chart, glasses_grid
  - calorie_ring_chart, macro_progress_bar
- All providers + repositories for meal/water/weight/habit

### ❌ Eksik (UI not implemented)
| Feature | Backend endpoint | UI gap |
|---|---|---|
| **Meal Capture** | `POST /meals` ✅ | No screen at all. Add Food button = `_showComingSoon` |
| **AI Scan** | `POST /meals/scan` ✅ | No camera UI, no result review |
| **Coach Chat** | `POST /coach/message` ✅ | No chat screen |
| **Habit Tracking** | `/habits/*` ✅ | No check-off UI |
| **Recipe / Meal Plan** | `/meal-plans/*` ✅ | No browse/generate UI |
| **Bottom Nav Wiring** | n/a | `_BottomNavPlaceholder` returns "coming soon" toast |

---

## 🎯 Minimum Viable Launch Scope

Apple/Play submission için kabul edilebilir bir state. Her şey değil — **kullanılabilir bir calorie tracker**.

### Phase 1 (Critical — 1-2 days)
1. **Bottom nav real wiring**
   - Dashboard / Profile **/ Settings** (3 tab — Settings'i Profile'ın menüsüne koy)
   - Add Food central FAB → opens manual meal entry sheet
   - Replace `_BottomNavPlaceholder` with real `BottomNavigationBar`
2. **Manual meal entry sheet** (no camera yet)
   - Form: name, kcal, protein/carbs/fat (optional), meal_type, time
   - POST /meals with foods array
   - Dashboard refreshes today summary
3. **App Store description rewrite**
   - "AI calorie scanner" → "Calorie + macro tracker with AI-assisted recommendations"
   - Don't promise camera scan in v1.0

### Phase 2 (Should — 2-3 days each, can ship as v1.1)
4. **Camera-based AI scan** — uses existing OpenAI Vision endpoint
5. **Coach chat UI** — basic Send/Receive on `POST /coach/message`
6. **Habit check-off** — list habits, tap to mark done today

### Phase 3 (Nice — defer to v1.2+)
7. Recipe / meal plan browser
8. Apple Watch / Flutter web
9. Advanced analytics charts (most chart widgets exist, just need a screen)

---

## 🗺️ Routing Re-architecture

Currently dashboard is a single screen with placeholder bottom nav. New structure:

```
MainShellScreen (IndexedStack + BottomNavigationBar)
  ├── Tab 0: DashboardScreen (existing)
  ├── Tab 1: AddFood (FAB-style center button → opens MealEntrySheet)
  ├── Tab 2: ProfileScreen → wraps GoalsProfileScreen (existing 352-line)
  └── Tab 3: SettingsScreen (existing)

Modals (push on top of shell):
  ├── MealEntrySheet (new, Phase 1)
  ├── MealScanResultScreen (new, Phase 2)
  ├── PaywallScreen (existing)
  └── SettingsScreen sub-screens
```

The avatar tap on dashboard header that currently opens Settings stays — it's a discoverable shortcut. Settings is also in the bottom nav for the canonical path.

---

## 📊 Effort Estimate (Realistic)

| Phase | Items | Effort | Risk |
|---|---|---|---|
| 1 | Bottom nav + manual meal entry + description | **2 days** | Low |
| 2 | Camera scan + coach + habits | 5-7 days | Medium |
| 3 | Recipe + watch + advanced analytics | 2-3 weeks | High (defer) |

**Recommendation:** Ship Phase 1 as v1.0 with description updated. Ship Phase 2 as v1.1 within 4 weeks of v1.0 launch (when first user feedback is in).

---

## 🚦 Decision (Ali, 2026-05-21)

> "DELAY: Eksik UI'ları implement et, sonra launch (4-8 hafta)"

Bu plan o kararın somutlaşması. **Gerçek effort: 2 gün (Phase 1) + 1 hafta (Phase 2) ≠ 4-8 hafta**, çünkü 80% UI altyapısı zaten var.

---

## 📋 PR Sequence (this chat)

- [ ] **PR #85** Bottom nav wire-up — Dashboard / Profile / Settings + central Add Food FAB → opens MealEntrySheet stub
- [ ] **PR #86** MealEntrySheet — form UI + POST /meals integration
- [ ] **PR #87** Dashboard refresh on meal save
- [ ] **PR #88** App Store description copy refresh (remove "AI scan" v1.0 claim)
- [ ] PR #89 — start camera scan UI (v1.1 candidate)

Then we re-run smoke test. If Phase 1 PRs all pass → submission window opens.

---

## 🔗 Related

- This document: ``launch_audit/MISSING_UI_IMPLEMENTATION_PLAN.md``
- Smoke test that surfaced this: Chat 25 → Render logs from 19:15-19:46 UTC
- Original audit (which missed scope): ``launch_audit/00_audit_overview.md``
- Production launch checklist (now out-of-date until Phase 1 lands): ``launch_audit/PRODUCTION_LAUNCH_CHECKLIST.md``
