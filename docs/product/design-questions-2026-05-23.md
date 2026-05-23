# Design Questions — F1 Meal Scan + F2 AI Coach

> The two biggest remaining features from `launch-gaps-2026-05-23.md`.
> Backend is fully built. UI is empty. Before writing the Flutter
> side, Ali needs to answer these so the implementation matches the
> product vision instead of my guesses.
>
> Format: **bold question, then sub-bullets with concrete options.**
> Ali can write his choice next to each `→` or in margin notes.
> Once these are filled in, the implementation is a focused 4-7 day
> sprint per feature.

---

## F1 — AI Meal Scan UI

Backend ready: `POST /meals/scan` accepts `{image_base64, meal_type_hint?}`, returns `{foods[], totals, portion_insight, suggested_meal_type}`. Rate-limited 10/min. Flutter side is a `placeholder_tab_screen` saying "Coming in v1.1".

### 1. Source of the photo
- [ ] **Camera only** — simpler, less code
- [x] **Camera + gallery** — better UX, what most users expect
  → Recommended unless there's a specific reason not to. (gallery requires extra permission strings already declared in Info.plist)
  
**Your answer:** Camera + gallery (default)

### 2. Pre-flight UI before sending to AI
- [ ] **No preview** — snap → directly to loading → result
- [x] **Preview + retake button** — user can cancel a bad shot
- [ ] **Preview + crop tool** — user trims to focus on plate
  → Cropping is significant scope. Most users don't need it. Recommend preview + retake.

**Your answer:** Preview + retake (default)

### 3. Loading state (OpenAI Vision takes 6–15 sec)
- [ ] **Spinner only**
- [x] **Spinner + progress text** ("Analyzing your meal...", "Identifying foods...", "Calculating macros...")
- [ ] **Animated illustration** (eats time visually)
  → Recommend option 2 — copy changes every 3s to signal progress; cheap to ship.

**Your answer:** Spinner + rotating progress text (default)

### 4. Result screen — what does the user see first?
After AI returns, before saving the meal:

- [ ] **Auto-save, show confirmation** ("Saved! 380 kcal — undo / edit")
- [x] **Editable preview** — list of foods with kcal/macros, user can tap to edit values, then "Save"
- [ ] **Confidence-gated** — auto-save if AI's portion_insight.score ≥ 70, else editable

**Your answer:** Editable preview before save (default)

### 5. Editing AI's estimates
If user finds AI's calorie or portion guess wrong:

- [ ] **Per-food row editor** — change calories/macros per detected food
- [ ] **Whole-meal scale** — slider to adjust portion size (0.5x, 1x, 1.5x) that scales all macros
- [x] **Both**
- [ ] **None — user must accept AI's answer or retake**

**Your answer:** Both — per-food row editor + whole-meal scale slider (default)

### 6. What if AI says "not food"?
Backend returns `foods: []` and explains in `portion_insight.main_text`.

- [ ] **Show the explanation + "Try another photo" button**
- [ ] **Auto-redirect to manual entry sheet** (B9, already shipped)
- [x] **Both — explanation card with "Edit manually" link**

**Your answer:** Explanation card + retake + "Edit manually" link (default)

### 7. Errors (OpenAI timeout / rate limit)
- [ ] **Just a snackbar, user retries**
- [x] **Big error screen + "Try again" + "Add manually instead"**

**Your answer:** Error screen + retry + manual fallback (default)

### 8. Meal type hint
Backend accepts `meal_type_hint` (breakfast/lunch/dinner/snack) to bias the AI. Where does it come from?

- [ ] **User picks before taking photo** (extra tap)
- [x] **Auto-pick from time-of-day** (B9's heuristic — already in code)
- [ ] **AI decides; we accept its `suggested_meal_type`**

**Your answer:** Auto from time-of-day, user can override on result screen (default)

### 9. Premium gating
Per `PremiumGateService.mealScanBeyond5Daily`: free user gets 5 scans/day, premium unlimited.

- [x] **Show remaining count** ("3/5 scans left today") at top of scan screen
- [ ] **No counter, just show paywall on 6th attempt**

**Your answer:** Show "N/5 scans left today" (default)

### 10. Post-save UX
- [x] **Pop back to dashboard, meal appears in list**
- [ ] **Show success screen with "View in journal" / "Add another"**

**Your answer:** Pop to dashboard, meal in list (default)

---

## F2 — AI Coach UI

**Backend reality check (2026-05-23):** verified `backend/routers/ai_coach.py`
ships only:

  - `GET /coach/today` → cached daily insight (nutrition_score 0-100, body
    text, tips[], optional `recommended_action`)
  - `POST /coach/generate` → force-regenerate (rate-limited 5/min)
  - `POST /coach/apply-tip` → execute `recommended_action` (add_habit,
    log_water, adjust_reminder, increase_target)

There is **no `/coach/chat` and no `/coach/audio`**. Crisis-detection lives
inside the prompt pipeline — persona auto-shifts to `calm` on `high_risk`,
no `crisis: true` flag on the response. Persona is read from `coach_prefs`
JSON server-side and is not currently exposed via the profile API.

F2 v0 ships an **insight-only Coach tab**. Chat-only questions (Q12 partial,
Q13, Q15, Q16, Q17, Q19, Q20) are **moot** for v0 and deferred to a future
conversational-coach feature.

**This is the biggest gap — Nuveli's brand promise is "AI Calorie Coach". App is incomplete without this.**

### 11. Coach surface — primary entry point
- [x] **New bottom-nav tab "Coach"** (5 → 6 tabs, but Coach is the core feature)
- [ ] **Floating action button on Dashboard** (less prominent)
- [ ] **Card on Dashboard** ("Today's insight: ...")

**Your answer:** Bottom-nav tab "Coach" (default — surfaces the brand promise)

### 12. Coach behavior — daily insight vs chat
- [x] **Daily insight only** — once-a-day generated card with tips. No conversation.
- [ ] **Chat only** — open chat surface, user asks anything.
- [ ] **Both** — daily insight at top, "Ask coach a question" below.

**Your answer:** Daily insight only (forced — backend has no chat endpoint in v0)

### 13. Voice (TTS) — when does coach speak?
- [ ] **Manual** — user taps speaker icon on a message to hear it
- [ ] **Auto for daily insight** — coach speaks its daily message once on first view
- [x] **Never** — text-only

**Your answer:** Never — text-only (forced — no `/coach/audio` endpoint in v0)

### 14. Persona selection
Onboarding offers persona choice. Where does it show up?

- [ ] **Coach screen header** — "Coach: Warm" or "Coach: Direct" badge
- [x] **System-only** — affects tone but isn't visible
- [ ] **Settings → Change persona**

**Your answer:** System-only (default — persona stored in `coach_prefs`, no profile API field surfaced yet)

### 15. Crisis banner
Moot for v0 — no chat surface to host one. Crisis prompt mitigation is
already applied server-side: persona shifts to `calm` for high-risk
content. Will revisit when chat ships.

**Your answer:** Moot for v0 (deferred with chat feature)

### 16. Crisis trigger
Moot for v0 — no chat surface, backend does not emit a `crisis: true` flag
on `/coach/today`.

**Your answer:** Moot for v0 (deferred with chat feature)

### 17. Chat input affordances
Moot for v0 — no chat input.

**Your answer:** Moot for v0 (deferred with chat feature)

### 18. Free tier limit
Per `PremiumGateService.aiInsightSecond`: free user gets 1 AI insight per
day, premium unlimited. F2 v0 reads today's insight via `/coach/today`
(unlimited, since it's cached). The gate triggers on the **regenerate
button** which calls `/coach/generate`.

- [x] **After daily insight: "Want another? Unlock premium"** (the regenerate CTA shows the gate inline)
- [ ] **In chat: usage counter at top, paywall on limit**
- [ ] **Both**

**Your answer:** Show gate on the "Regenerate" CTA inside the insight screen (default)

### 19. Conversation history
Moot for v0 — no conversation.

**Your answer:** Moot for v0 (deferred with chat feature)

### 20. "What can I ask?" empty state
Moot for v0 — no chat input. The insight-only empty state (cron hasn't
run yet for new user) renders a "Generating your first insight…" skeleton
and triggers `/coach/today`, which falls back to on-demand generation.

**Your answer:** Generating-skeleton empty state (default; backend handles first-run gen)

### 21. Notifications
- [x] **Push notification when daily insight is ready** ("Your insight is in 🌱")
- [ ] **No push — user opens app to see it**
- [ ] **Configurable via Settings → Notifications**

**Your answer:** Push when insight is ready (default — handler route `coach` deep-links to the Coach tab; Settings → Notifications toggle controls opt-out via existing infra)

---

## Implementation Sequence (after answers land)

Once Ali fills these in:

1. **F1 Meal Scan** (2-3 days)
   - Camera + image_picker integration
   - Pre-flight preview
   - Loading state + result screen
   - Edit + save
   - Error paths
   - Tests

2. **F2 AI Coach** (4-5 days)
   - Coach tab structure
   - Daily insight card (uses /coach/insight)
   - Chat surface (if chosen) with crisis flow
   - Persona display
   - Premium gating
   - Notifications hook
   - Tests

**Estimated total: 6-8 focused days.** That's the launch.
