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

Backend ready: `POST /coach/insight` (daily structured insight), `POST /coach/chat` (text chat — verify endpoint exists in routers/ai_coach.py before assuming). TTS `/coach/audio` for short voiced responses. Crisis-detection middleware on coach prompts (per `docs/protocols/coach-ai-protocol.md`).

**This is the biggest gap — Nuveli's brand promise is "AI Calorie Coach". App is incomplete without this.**

### 11. Coach surface — primary entry point
- [ ] **New bottom-nav tab "Coach"** (5 → 6 tabs, but Coach is the core feature)
- [ ] **Floating action button on Dashboard** (less prominent)
- [ ] **Card on Dashboard** ("Today's insight: ...")

**Your answer:** ___________

### 12. Coach behavior — daily insight vs chat
- [ ] **Daily insight only** — once-a-day generated card with tips. No conversation.
- [ ] **Chat only** — open chat surface, user asks anything.
- [ ] **Both** — daily insight at top, "Ask coach a question" below.

**Your answer:** ___________

### 13. Voice (TTS) — when does coach speak?
- [ ] **Manual** — user taps speaker icon on a message to hear it
- [ ] **Auto for daily insight** — coach speaks its daily message once on first view
- [ ] **Never** — text-only

**Your answer:** ___________

### 14. Persona selection
Onboarding offers persona choice. Where does it show up?

- [ ] **Coach screen header** — "Coach: Warm" or "Coach: Direct" badge
- [ ] **System-only** — affects tone but isn't visible
- [ ] **Settings → Change persona**

**Your answer:** ___________

### 15. Crisis banner
Per protocol: if user mentions self-harm / suicidal ideation, app must show a crisis banner with helpline.

- [ ] **Inline in coach chat** — banner appears in the conversation
- [ ] **Full-screen takeover** — modal that blocks the chat until user acknowledges
- [ ] **Persistent header** — sticky banner until user dismisses

**Your answer:** ___________

### 16. Crisis trigger
Backend already has detection logic. When does Flutter show the banner?

- [ ] **Backend tells us** — response includes `crisis: true` flag
- [ ] **Frontend keyword check** — Flutter scans user message before send
- [ ] **Both** — defense in depth

**Your answer:** ___________

### 17. Chat input affordances
- [ ] **Plain text input only**
- [ ] **Text + voice input** (speech-to-text → text → coach)
- [ ] **Text + quick-suggestion chips** ("How am I doing today?", "What should I eat?", etc.)
- [ ] **All three**

**Your answer:** ___________

### 18. Free tier limit
Per `PremiumGateService.aiInsightSecond`: free user gets 1 AI insight per day, premium unlimited. Where does this gating show?

- [ ] **After daily insight: "Want another? Unlock premium"**
- [ ] **In chat: usage counter at top, paywall on limit**
- [ ] **Both**

**Your answer:** ___________

### 19. Conversation history
- [ ] **Persistent** — store every message, user sees their full history
- [ ] **Session-only** — clear on app restart, fresh start every day
- [ ] **Today only** — keep today's conversation, archive nightly

**Your answer:** ___________

### 20. "What can I ask?" empty state
First-time users won't know what coach can do. The first screen they see:

- [ ] **Just the input box**
- [ ] **Empty box + 3-4 sample prompts** ("Why did I gain weight?", "Plan tomorrow's meals", etc.)
- [ ] **Pre-written welcome message from coach** ("Hey Ali! I'm here to help...")

**Your answer:** ___________

### 21. Notifications
- [ ] **Push notification when daily insight is ready** ("Your insight is in 🌱")
- [ ] **No push — user opens app to see it**
- [ ] **Configurable via Settings → Notifications**

**Your answer:** ___________

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
