# Nuveli — Session Handoff (last updated 2026-05-23)

> **Bu doküman**: bir Claude Code oturumundan diğerine geçişi temiz tutar.
> Yeni chat açıldığında okunur, "neredeyiz, sırada ne var" net olur.
>
> **Devamlılık komutu (yeni chat):**
> ```
> Read docs/SESSION_HANDOFF.md and continue from "Sırada ne var" section.
> ```

---

## Şu anda neredeyiz

**Backend + infrastructure: %100 hazır.** UI tarafı: launch için gerekli iki büyük feature kaldı (AI Coach, AI Meal Scan). Geri kalan her şey shipped + canlıda.

### Bu son oturumda (2026-05-22 → 23) shipped olan PR'lar

```
5aec41a  #122  docs: design questions for F1 Meal Scan + F2 AI Coach
1fe15bb  #121  feat(habits): dashboard'da "Today's habits"
fe36aa6  #120  feat(analytics): gerçek Analytics ekranı
c94b6b9  #119  feat(dashboard): 7 günlük su grafiği
ddc0fe7  #118  feat(dashboard): gerçek Add Food modal
8ff661c  #117  feat(dashboard): su portion picker (100-750ml + custom)
9fbcb9e  #116  docs: honest launch gap analysis
33816d5  #115  fix(insights): structured ai_insights write
e57760d  #114  fix(analytics): direct nutrition_score read
04cf0c7  #113  fix(profile): LayoutBuilder _InlineError
bd91881  #112  fix: signup trigger + weight_goals adapter
e9223d2  #111  test cleanup (Keychain pollution fix)
e17d877  #110  ops: assetlinks.json 2nd fingerprint
5e21b19  #109  fix(android): release build unblock
0e555bd  #108  feat(ios): Universal Links entitlement (paused)
```

### Geçen daha önceki sessions'larda shipped

#96-#107 (security top-5: secure session storage, prompt injection guards, JWKS cache TTL, deep link validator + listener, .env out of build, integration tests, App Links activation, notification route validation, scheduler allowlist audit, more).

### Test counts (canlıda)

- Flutter: **410 host-side + 5 device-level integration**
- Backend: **139 pytest active + 8 skipped**
- analyze: clean (4 pre-existing warnings in `lib/main_integration_snippet.dart`)

---

## Sırada ne var

### 1. F1 — AI Meal Scan UI (2-3 gün)
- Backend ready: `POST /meals/scan` (GPT-4o Vision)
- Flutter: placeholder ekranı var, gerçek UI yok
- **Bloker**: tasarım kararları → cevaplar `docs/product/design-questions-2026-05-23.md` (1-10 numaralı sorular)

### 2. F2 — AI Coach UI (4-5 gün) ⭐ BÜYÜK
- "Nuveli — AI Calorie Coach" — uygulamanın adındaki feature
- Backend ready: `/coach/insight`, `/coach/chat`, TTS audio, crisis detection
- Flutter: `lib/features/coach/` klasörü dahi yok
- **Bloker**: tasarım kararları → cevaplar `docs/product/design-questions-2026-05-23.md` (11-21 numaralı sorular)

### 3. F4 — Meal Planner UI (3-4 gün)
- Backend ready: `/meal-plans/*` (recipes, weekly plan, AI generate, grocery list)
- Flutter yok
- Sprint B sonrasına bırakıldı

### 4. Operasyonel
- ✅ Migration 018 (Ali applied 2026-05-22 night)
- ⏳ assetlinks.json cPanel upload — sideload test için, App Store deploy için zorunlu değil
- ⏳ Apple Developer enrollment (paused, $99, sonra)
- ⏳ Yeni APK build + Play Console Internal Testing upload (sabah)

---

## Yeni chat açıldığında ilk komutlar

### Komut 1 — handoff'u oku
```
Read docs/SESSION_HANDOFF.md and the linked launch-gaps + design-questions docs.
What's the next concrete task you'd recommend?
```

### Komut 2 — F1 veya F2'ye başla (design questions cevapladıktan sonra)
```
docs/product/design-questions-2026-05-23.md tasarım sorularına cevaplarımı yazdım.
F1 Meal Scan UI'ı başlatabilir misin? Yarım gün gibi iş yapalım, durduğun yerde özet bırak.
```

veya:

```
F2 AI Coach UI üzerinde çalışalım — design questions doc'taki cevaplarımı oku, planla,
sonra implement et. Saat geç olursa durup özet bırak.
```

### Komut 3 — sadece bug fix istiyorsan
```
Uygulamayı cihazda test ettim, şu sorun var: [açıkla]. Düzelt.
```

---

## Kritik referans dokümanlar

| Dosya | İçerik |
|---|---|
| `docs/product/launch-gaps-2026-05-23.md` | Tüm UI gap'leri + B/F/O/S numaralı sınıflandırma + Sprint A/B/C |
| `docs/product/design-questions-2026-05-23.md` | F1 + F2 için 21 tasarım sorusu + öneriler |
| `docs/SESSION_HANDOFF.md` | Bu dosya |
| `CLAUDE.md` | Proje kimliği + sabit kurallar |
| `app/CLAUDE.md` | Flutter-specific kurallar |

---

## Açık riskler

1. **Schema drift endemic** — repo migrations vs prod DB sürekli kayıyor. Yeni feature ekleyince ilk önce `mcp__supabase__execute_sql` ile `information_schema.columns` doğrulanmalı. Tekrar yanılma. (Memory `project_schema_drift_endemic.md`)

2. **Local main ara sıra divergent** — Ali manuel commit'ler atınca origin'le ayrışıyor (örn. `chore: require gstack` commit'i bir kez orijinde varken localda ayrı kaldı). `git pull --rebase` ile düzelt; Podfile.lock stash etmek gerek.

3. **iOS paused but staged** — entitlement vs. ekledim, Apple Developer enrollment olunca aktive olur. Yanlışlıkla iOS özelliklerini "yok" sayıp silme.

4. **AI Coach yok = launch blocker** — Uygulamanın adında olan feature shipped olmadan App Store'a göndermek anlamsız. F2 sprintinin tamamlanması launch'ın kritik yolu.

---

## Acil iletişim — Ali sana doğrudan ne demeli

| Senin durumun | Ne yazmalısın |
|---|---|
| Yeni başlıyorum, durum bilmiyorum | `Read docs/SESSION_HANDOFF.md` |
| Design soruları cevapladım | `design-questions doc'u oku, F1/F2 implement et` |
| Cihazda bug buldum | `[ekran adı + ne yaptığım + ne olduğu]` |
| Yarınki sprint plana karar veremedim | `launch-gaps doc'u oku, Sprint A/B/C'den bana öneri yap` |
| Schema problemi yaşıyorum | Reach for `mcp__supabase__execute_sql` + `information_schema.columns` |

---

**Hazırlandı:** 2026-05-23 (gecenin sonu)
**Bir sonraki güncelleme:** F1 veya F2'den ilki shipped olunca
