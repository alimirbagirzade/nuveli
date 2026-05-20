# 👤 FAZ 4 — User Journey Test Checklist

**Çalıştırma yeri:** iPhone (gerçek cihaz veya simulator)
**Tarih hedef:** Pre-launch
**Beklenen süre:** 4-6 saat (sen yapacaksın)
**Test build:** `flutter run --release`

Her senaryo için: ✅ pass, ❌ fail (+ kısa not), ➖ skip (sebep yaz).

---

## 🟢 Happy Path (20 senaryo) — Sorunsuz çalışmalı

### Auth & Onboarding
- [ ] H1. Yeni signup (email/password) → onboarding step 1-5 → dashboard
- [ ] H2. Apple Sign-In → onboarding → dashboard (iOS only)
- [ ] H3. Login → 4 sekme/tab arası geçiş → settings (avatar tap)
- [ ] H4. Password reset email → link → yeni şifre → login
- [ ] H5. Logout → welcome screen

### Dashboard & Daily
- [ ] H6. Dashboard ilk yükleme < 2s
- [ ] H7. Pull-to-refresh → dashboard yenilenir
- [ ] H8. Water +250ml → günlük toplam artar → ring chart güncel
- [ ] H9. Manuel meal entry (text-only) → save → dashboard'a yansır
- [ ] H10. AI meal scan (kamera) → 3 yiyecek tespit → save → dashboard'a yansır
- [ ] H11. Habit tap (5 default) → streak artar → confetti (varsa)

### Profile & Goals
- [ ] H12. Profile → kilo güncelle → trend chart yenilenir
- [ ] H13. Profile → goal değiştir → calorie target yeniden hesaplanır

### Premium
- [ ] H14. Free user → AI insight limit → paywall görür
- [ ] H15. Paywall → "7 gün ücretsiz başla" → RC sandbox satın alma → premium aktif
- [ ] H16. Premium aktifken sınırsız AI scan + coach mesaj

### Settings (YENİ — C-3 verify)
- [ ] H17. Avatar tap → Settings ekranı açılır
- [ ] H18. Settings → "Sign out" → welcome screen
- [ ] H19. Settings → "Delete My Account" → "DELETE" yaz → onayla → backend DELETE /me 200 → logout → welcome
- [ ] H20. Account silindikten sonra aynı email ile signup yapılabilmeli (data temiz başlangıç)

---

## 🟠 Sad Path (30 senaryo) — Graceful handle olmalı

### Network
- [ ] S1. Uçak modu → app açılışı → friendly offline screen
- [ ] S2. Uçak modu → login deneme → "Check internet" error (crash yok)
- [ ] S3. Uçak modu → meal scan → "Need internet" + retry
- [ ] S4. Network mid-request kopuyor → 15s timeout → "Slow connection"

### Auth Errors
- [ ] S5. Login → yanlış password → friendly error
- [ ] S6. Login → yanlış password 5x → cooldown veya CAPTCHA
- [ ] S7. Signup → mevcut email → "Already registered, sign in?"
- [ ] S8. Signup → invalid email → form validation hatası

### AI Failures
- [ ] S9. Meal scan → bulanık fotoğraf → "Couldn't analyze, try clearer photo"
- [ ] S10. Meal scan → yemek değil resim (parking lot) → "Doesn't look like food"
- [ ] S11. Meal scan → OpenAI rate limit (429) → "Busy, try again"
- [ ] S12. Meal scan → backend 500 → "Something went wrong"

### Permissions
- [ ] S13. Camera permission denied → "Open Settings" CTA
- [ ] S14. Photos permission denied → meal scan disable + explainer
- [ ] S15. Notifications denied → settings'te uyarı

### Input Validation
- [ ] S16. Profile name → empty → field error
- [ ] S17. Profile name → 500 karakter → truncate veya reject
- [ ] S18. Profile name → emoji + Arapça → kabul edilir
- [ ] S19. Weight → 0 kg → reject
- [ ] S20. Weight → 999 kg → reject (sanity bound)
- [ ] S21. Calorie target → 500 (wellness boundary altı) → reject
- [ ] S22. Date of birth → 12 yaş → "Must be 13+" (COPPA)
- [ ] S23. Date of birth → 1850 → reject

### State Recovery
- [ ] S24. Login → app force-quit → tekrar aç → hala logged in (persistent session)
- [ ] S25. Login → 1 saat bekle → API call → token auto-refresh
- [ ] S26. Onboarding step 3'te app kill → tekrar aç → step 3'ten devam
- [ ] S27. Meal eklerken app kill → reaç → meal kaybolmamış (optimistic UI veya queue)

### Premium Edge
- [ ] S28. Premium purchase → ortada iptal → state korunur (premium aktif değil)
- [ ] S29. Premium purchase → payment fail → error + retry
- [ ] S30. Premium expire → free'ye düş + notification

---

## 🦹 Unhappy User (15 senaryo) — Kötü niyetli simülasyon

### Spam & Abuse
- [ ] U1. Aynı emailde 5+ signup deneme → reject
- [ ] U2. Çift tıklama Submit → 1 kayıt (debounce)
- [ ] U3. Premium subscribe + instant cancel → premium aktif kalır?
- [ ] U4. Trial cancel before charge → free'ye düş

### Account Lifecycle
- [ ] U5. Delete account → eski email ile signup → temiz başlangıç
- [ ] U6. Delete account → backend `/me` DELETE 200 → tüm meals/water/habits da silinmiş (CASCADE)

### Injection Attempts
- [ ] U7. Profile name → `Robert'); DROP TABLE--` → güvenli escape (Supabase param)
- [ ] U8. Profile name → `<script>alert('x')</script>` → görsel'de plain text
- [ ] U9. Deep link → `nuveli://meals/../../etc` → graceful redirect

### Multi-Device
- [ ] U10. iPhone'da login + meal ekle, iPad'de aynı user → meal görünür
- [ ] U11. iPhone'da logout → iPad hala logged (Supabase JWT bağımsız)
- [ ] U12. Premium subscribe iPhone → iPad "Restore Purchases" → premium aktif

### Edge Inputs
- [ ] U13. Meal name → 10000 karakter → reject veya truncate
- [ ] U14. 100MB photo upload → reject (size limit) — eğer backend limiti varsa
- [ ] U15. Free user 100 paralel AI scan → backend rate limit veya quota error

---

## Premium Full Lifecycle (Bonus)

Gün gün test (1 saat civarı):

```
Day 0:  Signup → free
Day 3:  AI limit hit → paywall
Day 5:  Subscribe Monthly → premium aktif
Day 12: Auto-renew (sandbox accelerated)
Day 20: Switch to Annual (RC product change)
Day 35: Premium expired → free
Day 60: Re-subscribe → premium
Day 65: Account delete → RC + Supabase + backend cleared
```

---

## Results Template

```
Happy: __ / 20 ✅
Sad:   __ / 30 ✅
Unhappy: __ / 15 ✅
Premium lifecycle: ✅ / ❌

Critical fails: <buraya yaz>
High fails: <buraya yaz>
Medium fails: <buraya yaz>
```

**Pre-Launch Bar:**
- Happy: 19+/20 pass (95%+)
- Sad: 25+/30 pass (83%+)
- Unhappy: 12+/15 pass (80%+)

Bunun altına düşersek **DELAY**.
