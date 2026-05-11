# Nuveli — Yarın Yapılacaklar

**Son güncelleme:** 12 Mayıs 2026, 00:21
**Durum:** Bugün muazzam ilerleme. Aşağıdakiler yarın taze kafayla.

---

## 🔴 P0 — Critical: Account state leak (TEŞHİS HAZIR, FIX KOLAY)

**Bug:** Kullanıcı logout/login yapınca eski hesabın verisi yeni hesapta görünüyor.

**Kök sebep:** İki provider sadece `bootstrapProvider`'ı invalidate ediyor, ama onlarca kullanıcıya özel provider cache'te kalıyor:

- `app/lib/features/auth/providers/auth_providers.dart:122` (`signOutActionProvider`)
- `app/lib/features/settings/providers/settings_providers.dart:88` (`deleteAccountActionProvider`)

**Fix planı:**

1. `auth_providers.dart`'a yeni helper ekle:

```dart
/// Tüm kullanıcıya özel state'i temizle.
/// signOut ve deleteAccount tarafından kullanılır.
final _clearAllUserStateProvider = Provider((ref) => () {
  // Bootstrap
  ref.invalidate(bootstrapProvider);
  // Home & meals
  ref.invalidate(homePayloadProvider);
  ref.invalidate(todayMealsProvider);
  ref.invalidate(streakProvider);
  // Progress
  ref.invalidate(weeklyChartProvider);
  ref.invalidate(monthlyInsightProvider);
  // Profile
  ref.invalidate(profileProvider);
  // Coach
  ref.invalidate(coachConversationProvider);
  // Onboarding form state (reset notifier)
  ref.read(onboardingControllerProvider.notifier).reset();
});
```

2. `signOutActionProvider`'ı güncelle:

```dart
final signOutActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(_clearAllUserStateProvider)();
  };
});
```

3. `deleteAccountActionProvider`'ı da güncelle (aynı helper kullansın).

**Tahmini süre:** 20 dakika

**Test:** Settings → Çıkış → Yeni hesapla giriş → home'da eski veri görünmemeli.

---

## 🟡 P1 — Eksik özellik: Manuel meal kalori auto-fill

Kullanıcı "pilav" yazınca otomatik kalori dolması beklenir. Şu an manuel ekran tamamen elle giriş.

**Seçenekler:**
- Backend'e `/meal/lookup-text` endpoint ekle (GPT-4 ile text→nutrition)
- Open Food Facts API entegrasyonu
- USDA food database

**Tahmini süre:** 1-2 saat

---

## 🟢 P2 — Diğer açık konular

- Bootstrap re-routing bug: onboarding tamamlanmış kullanıcı acceptance'a düşüyor
- MealAnalysisResult codec uyarısı (Riverpod state'e taşı, extra kullanma)
- GoError "There is nothing to pop" (acceptance back button)
- Real cold start test (cron-job.org keepalive pause + 16dk bekle)
- Apple Sign In + Google Sign In (App Store gereği)
- Android deep link real device test
- App Store Connect: screenshots, descriptions (7 dil)

---

## ✅ Bugün tamamlandı (12 Mayıs 2026)

- Email verification (PKCE → implicit + verify_email_screen)
- Deep link (iOS + Android, nuveli://)
- OpenAI key rotation
- Render keepalive (cron-job.org)
- Cold start UX (ColdStartError, ColdStartView, retry logic)
- Onboarding repository AppError sarması (4 metod)
- Splash logo tam ekran (scaleAspectFill + siyah arka plan)
- Meal capture crash fix (failed durumda /meal/result'ı atla)
- Manuel button post-frame callback
- `reset-nuveli` developer alias (.zshrc)
- Tüm değişiklikler 2 commit ile push (74411b5, eb2c8f6)
