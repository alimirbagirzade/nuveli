# Nuveli — Honest Launch Gap Analysis (2026-05-23)

> Bu dokümanı yazma sebebi: Bu oturumun ortasında "proje bitti" diye
> yanlış işaret verdim. Gerçek durum — backend ve infrastructure
> sağlam, ama **kullanıcının ekrandan gördüğü ürünün ciddi parçaları
> eksik**. Bu doküman gerçeği tek bir yerde tutar.

---

## Status Özeti

| Katman | Durum |
|---|---|
| Backend (FastAPI) | ✅ %95 hazır — 12 router, 136 test pass, schema drift'leri patch'lendi |
| Auth flow (Welcome → Signup → Login → Onboarding) | ✅ Çalışıyor (signup için migration 018 uygulanmalı) |
| Dashboard skeleton | ✅ Render oluyor, "Add Food" butonu işlevsel olabilir (doğrulanmalı) |
| Profile (weight goals, history) | ⚠️ Çalışıyor ama eksik UI (su grafiği, vs) |
| Settings | ✅ Var |
| Premium paywall | ✅ Var |
| Notifications config | ✅ Var |
| **Meal Scan UI** | ❌ **"Coming in v1.1" placeholder** |
| **Analytics UI** | ❌ **"Coming in v1.1" placeholder** |
| **AI Coach UI** | ❌ **Bottom nav'da yok bile, tüm feature eksik** |
| **Meal Planner UI** | ❌ Backend var, Flutter yok |
| **Habits UI** | ⚠️ Backend var, Flutter UI doğrulanmadı |
| **Manual meal entry form** | ❓ Add Food butonu ne yapıyor doğrulanmadı |

---

## Bulunan ve Henüz Çözülmemiş Gerçek Bug'lar

### Production Blocker'lar

- [ ] **B1.** Signup 500 — Supabase trigger `display_name` kolonuna yazıyor, DB'de `full_name`. **Fix shipped** (PR #112 migration 018), uygulanması Ali'nin Supabase Dashboard'da SQL Editor'a yapıştırmasına bağlı.
- [ ] **B2.** assetlinks.json 2. fingerprint deploy edilmedi (PR #110 repo'da, cPanel'e upload pending).

### UI Bug'lar (mevcut ekranlarda)

- [x] **B3.** ~~`/weight/goal` 500~~ — schema drift adapter ile düzeldi (PR #112).
- [x] **B4.** ~~LayoutBuilder crash report~~ — _InlineError MediaQuery'ye geçti (PR #113).
- [x] **B5.** ~~Analytics dashboard `ai_insights.payload` error spam~~ — Direct column query (PR #114).
- [x] **B6.** ~~Insights write column mismatch~~ — Structured columns (PR #115).
- [ ] **B7.** **Water +250 ml fixed amount** — Kullanıcı 100/200/250/330/500/custom seçemiyor. Su ekleme UX'i tek değerle kısıtlı.
- [ ] **B8.** **Dashboard'da günlük su grafiği yok** — Profil tab'da olabilir ama Dashboard'da sadece progress bar var, grafik yok.
- [ ] **B9.** **"Add Food" butonu** — Ne yaptığı doğrulanmadı (dashboard'da tıkladığı screenshot'ta hiçbir şey olmamış gibi). Beklenen: manual entry modal veya scan flow'a giriş.

### Yapılmamış Feature'lar (Frontend Eksik)

- [ ] **F1.** **AI Meal Scan UI** — Kamera, fotoğraf seçimi, AI analysis sonuç ekranı.
  - Backend: `/meals/scan` ✓
  - Prompts: `prompts/meal_scan_prompt.py` ✓
  - Flutter: `placeholder_tab_screen` ("Coming in v1.1")
  - Effort: 2-3 gün (camera permissions, image picker, loading state, result render)

- [ ] **F2.** **AI Coach UI** — Bu Nuveli'nin **adından bile** olduğu için en kritik eksiklik.
  - Backend: `/coach/*` endpoint'leri ✓
  - Prompts: `prompts/coach_prompts.py` (insight + meal plan + water insight) ✓
  - Flutter: **HİÇ YOK** — `lib/features/coach/` klasörü dahi mevcut değil
  - Bottom nav'da Coach tab YOK
  - Effort: 4-5 gün (chat UI, audio playback for TTS, daily insights screen, crisis banner)

- [ ] **F3.** **Analytics UI** — Weekly bars, weight trend, macro breakdown.
  - Backend: `/analytics/*` ✓
  - Flutter: placeholder
  - Effort: 2-3 gün (fl_chart kullanılarak chart screen'ler)

- [ ] **F4.** **Meal Planner UI** — Recipes, weekly plan, AI generate.
  - Backend: `/meal-plans/*` ✓ (cost-guarded)
  - Flutter: Yok
  - Effort: 3-4 gün

- [ ] **F5.** **Habits UI verification** — Backend var, Flutter UI'ı mevcut mu doğrulanmadı.
  - Effort: 1 gün doğrulama + eksik kısımlar

### Operasyonel (Senin Yapacakların)

- [ ] **O1.** Supabase Dashboard'a migration 018'i uygula (5 dk).
- [ ] **O2.** cPanel'e `website/public_html/.well-known/assetlinks.json` yenisini yükle (5 dk).
- [ ] **O3.** Yeni APK build edip Play Console Internal Testing track'ine upload (15 dk; sen az önce yaptın).
- [ ] **O4.** Gerçek Android cihaz USB testi + App Links verify (30 dk, yarın).
- [ ] **O5.** Apple Developer enrollment (paused, $99, sonra).
- [ ] **O6.** apple-app-site-association (Apple sonra).

### Sistemsel/Yapısal

- [ ] **S1.** **Schema drift'i CI'da yakalayan tool yok** — Repo migrations vs prod DB karşılaştırması manuel. Bir script yazılabilir.
- [ ] **S2.** **Flutter widget testleri var ama feature flow testi az** — Onboarding → meal scan → analytics gibi full-flow integration test yok.
- [ ] **S3.** **Chat 17 routing (go_router) wire edilmemiş** — Bottom nav tab'ları doğrudan widget swap mı yapıyor, go_router mı? Belirsiz. Deep links onAllowed null çünkü router yok.

---

## Çözüm Algoritması

```
1. SORT by (impact × urgency, ascending)
   - "App Store launch blockers": B1, B2, O1, O2, O3, O4
   - "Core UX missing": F1, F2, F3
   - "Polish": B7, B8, B9, F4, F5, S2
   - "Long term": S1, S3, O5, O6, Apple

2. TRIAGE per item:
   - Backend ready? → only UI work
   - Backend missing? → API design first
   - Pure UX? → mockup → code

3. SEQUENCE — bir sprint = 1 hafta odaklı
   Sprint A (LAUNCH MVP):
     [B1] migration 018 uygula
     [B2] assetlinks.json cPanel
     [F2] AI Coach UI (Nuveli'nin core'u — bu olmadan ürün yok)
     [F1] Meal Scan UI
     [B9] Add Food modal/flow tamamla
     [B7] Water portion picker
     [B8] Dashboard'a basit su grafiği
   
   Sprint B (POST-LAUNCH polish):
     [F3] Analytics UI
     [F4] Meal Planner UI
     [F5] Habits UI verify + fix
     [S2] E2E flow tests
   
   Sprint C (iOS + scale):
     [O5][O6] Apple enrollment + Universal Links
     [S1] Schema drift CI tool
     [S3] go_router refactor

4. EVERY new feature:
   a. Backend endpoint var mı kontrol
   b. Prompt yazılı mı kontrol
   c. Mockup/wireframe Figma'da çiz
   d. Flutter screen + provider + service yaz
   e. Widget test + integration test
   f. Live device manual test
   g. PR + review + merge
   h. Crashlytics + Sentry takibi başlat

5. NEVER again declare "done" without:
   - Feature inventory ✓
   - UI screen walkthrough on device
   - Both backend AND frontend present
```

---

## Tonight Action

**Hiçbir yeni kod yazmıyorum.** Bu dokümanı `docs/product/` altına repo'ya commit + PR. Sprint A başlangıcı yarın senin uyandığında bekliyor.

Eski "tüm hazır" beyanını geri çekiyorum. Doğru ifade: "Backend + infrastructure + auth + dashboard skeleton hazır, app'in adındaki AI Coach dahil 4 büyük feature yapılması bekliyor."

---

## Memory Note

Bu bilgi `~/.claude/projects/.../memory/project_launch_state_real.md` olarak da kaydedildi. Gelecek oturumda "bitti mi" sorusunun cevabı bu dokümana bakmak.
