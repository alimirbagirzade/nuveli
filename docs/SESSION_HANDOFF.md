# Nuveli — Session Handoff (last updated 2026-05-23, late afternoon)

> **Bu doküman**: bir Claude Code oturumundan diğerine geçişi temiz tutar.
> Yeni chat açıldığında okunur, "neredeyiz, sırada ne var" net olur.
>
> **Devamlılık komutu (yeni chat):**
> ```
> Read docs/SESSION_HANDOFF.md and continue from "Sırada ne var" section.
> ```

---

## Şu anda neredeyiz

**Sprint A artık tamam — 3 büyük UI gap'i de PR'da.** Backend + infrastructure zaten %100. UI tarafında F1 (Meal Scan), F2 (AI Coach insight-only), F4 (Meal Planner v0) hepsi stacked PR olarak açık ve merge bekliyor. F3 (Analytics) + F5 (Habits) önceden shipped.

### Bu öğleden sonraki sesyonda (2026-05-23 PM) main'e merge edilen PR'lar

```
PR #129  feat(planner): weekly meal plan view (F4 v0)        squash-merged
PR #128  feat(coach): AI Coach daily-insight UI (F2 v0)      squash-merged
PR #124  feat(meal): AI meal scan UI (F1)                    squash-merged
```

Not: #125 ve #126 başlangıçta stacked PR olarak açılmıştı; base branch'leri squash-merge'de silinince GitHub otomatik kapattı. #128 ve #129 onların main üzerine rebase edilmiş yenileri (aynı diff).

Bu üç merge'de toplam 51 yeni test (410 → 461 host), analyze temiz (pre-existing 4 warning aynı).

### F2 v0 önemli daralma

Design doc'taki `/coach/chat` + `/coach/audio` backend'de **yok** — `backend/routers/ai_coach.py` sadece `GET /coach/today` + `POST /coach/generate` + `POST /coach/apply-tip` ship'liyor. F2 v0 bu yüzden **insight-only**: günlük cached insight + nutrition score arc + tip listesi + recommended action apply. Chat/TTS/persona display deferred. Design questions Q11-Q21 backend gerçeğine göre güncellendi (#128 commit'inde).

Ali talebi: **lokal mood-bubble katmanı** (OpenAI'siz, persona × situation copy bank) → ayrı sesyon. Bu sesyonda dokunulmadı, sadece yol haritasına yazıldı.

### Bu sabah / dün gece shipped olan PR'lar (sesyon başında main'de olanlar)

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

### Test counts (PR'lar merge edilince main'de olacak)

- Flutter: **461 host-side + 5 device-level integration** (410 → +51 bu sesyonda)
- Backend: **139 pytest active + 8 skipped** (değişmedi)
- analyze: clean (4 pre-existing warnings in `lib/main_integration_snippet.dart`)

---

## Sırada ne var

### 1. Cihaz QA — üç feature de
Sırasıyla yürü:
- **F1**: Scan tab → kamera/galeri → preview → analyze → result düzenle → save → dashboard'da görünür mü, "N/5" sayacı düşüyor mu, 6. tıklamada paywall açılıyor mu
- **F2**: Coach tab → günlük insight render mı, "Regenerate (1 free / day)" 1 kez çalışıp upgrade'e dönüyor mu, recommended action butonu (varsa) snackbar veriyor mu
- **F4**: Dashboard "Plan your week" tile → planner ekranı, hafta navigatörü, free user next-week paywall'a düşüyor mu, grocery sheet açılıyor mu

### 2. Mood-bubble v0 (Ali talebi — ayrı sesyon)
Backend `/coach/today` zaten zengin insight üretiyor. Bunun **üstüne** lokal mood-bubble katmanı: persona × durum copy bank, meal log / water düşük / streak milestone anlarında anlık metin. Sıfır OpenAI maliyeti. Bir yarım gün iş.

### 3. F4 v0.1 polish
- Add-meal-to-plan modal (manual entry → `POST /meal-plans`)
- AI generate dietary preferences sheet → repo metodu hazır, sadece UI lazım
- Edit/delete plan entries
- Recipe browser

### 4. S3 — go_router refactor (notif deep link'leri için)
Şu an `notification_service.dart` payload route `/coach` veya `/meals/scan` döndürüyor, ama router yok → tap navigate etmiyor. Push notif tıklayan kullanıcı dashboard'a düşüyor. Refactor büyük (her tab + her ekran), Sprint C için bekliyor.

### 5. Operasyonel
- ✅ Migration 018 (Ali applied 2026-05-22 night)
- ⏳ assetlinks.json cPanel upload — sideload test için, App Store deploy için zorunlu değil
- ⏳ Apple Developer enrollment (paused, $99, sonra)
- ⏳ Yeni APK build + Play Console Internal Testing upload (F1+F2+F4 main'de — versionCode bump et ve build al)

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

**Hazırlandı:** 2026-05-23 (öğleden sonra, F1+F2+F4 PR'ları açıldıktan sonra)
**Bir sonraki güncelleme:** üç PR main'e land edince + cihaz QA tamamlanınca
