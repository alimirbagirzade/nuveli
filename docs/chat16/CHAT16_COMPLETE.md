# 🎯 Chat 16 — Provider Migration Checklist & Test Plan

Chat 16 tamamlandı. Bu doküman:
1. Üretilen 8 provider dosyasını listeler
2. Her birinde **drop-in replacement** olduğunu doğrulamak için kontrol noktaları
3. UI'da kullanılacak **error handling pattern**ı
4. **Test senaryoları** (network down, token expired, vs.)

---

## 📂 Üretilen Provider Dosyaları

Tümü kendi feature klasörlerine kopyalanacak (mevcut mock provider'ların **üzerine** yazılır — `mock_*.dart` data dosyalarını **silme**):

| # | Dosya | Tip | Mutable? |
|---|---|---|---|
| 1 | `features/dashboard/providers/dashboard_provider.dart` | FutureProvider | ❌ |
| 2 | `features/profile/providers/profile_provider.dart` | 3× FutureProvider + Actions | ✅ |
| 3 | `features/analytics/providers/analytics_provider.dart` | FutureProvider | ❌ |
| 4 | `features/water_tracker/providers/water_tracker_provider.dart` | AsyncNotifier | ✅ (optimistic) |
| 5 | `features/meal_planner/providers/meal_planner_provider.dart` | FutureProvider.family ×3 + Actions | ✅ |
| 6 | `features/habits/providers/habits_provider.dart` | AsyncNotifier | ✅ (optimistic) |
| 7 | `features/ai_coach/providers/ai_coach_provider.dart` | FutureProvider + Actions | ✅ |
| 8 | `features/meal_scan/providers/meal_scan_provider.dart` | AsyncNotifier | ✅ |

---

## 🧠 Tasarım Kararları (Neden böyle)

1. **Modern Dart 3 records** ile parallel fetch (`(a, b, c) = await (f1, f2, f3).wait;`) — daha az boilerplate, type-safe, `Future.wait([...]).cast<...>` jonglörlüğü yok.
2. **Profil için tek monolitik provider yerine 3 ayrı slice** (`profileProvider`, `weightGoalProvider`, `streakProvider`) — streak endpoint'i hata verirse tüm profil ekranı patlamaz.
3. **Optimistic update SADECE Water ve Habits'te** — bu iki ekranda kullanıcı çok hızlı etkileşim yapıyor (saniyede 1-2 tap). Diğerleri (meal log, weight log, vs.) zaten yavaş — basit `await + invalidateSelf()` yeter.
4. **Actions class pattern** (Profile / MealPlanner / AiCoach) — provider'ı mutable yapmak yerine, mutation'ları ayrı bir notifier-ish sınıfta topladım. `ref.read(profileActionsProvider).updateProfile(...)` daha okunabilir.
5. **`FutureProvider.family<MealPlanWeek, DateTime>`** — meal planner haftalar arası kaydırılıyor; her hafta için ayrı cache. Riverpod aynı tarihle ikinci çağrıda re-fetch etmiyor.
6. **`AsyncValue.guard`** kullanımı (water, habits, meal scan) — try/catch boilerplate'ini kısaltır, hatayı AsyncValue.error'a otomatik sarar.
7. **Roll-back pattern**: Optimistic update'lerde `state = AsyncValue.data(previous)` ile geri al ve **`rethrow`** — hata UI'a snackbar olarak yansır ama state hala geçerli veriyle dolu kalır.

---

## ⚠️ Olası State Class Uyumsuzlukları

Provider'lar **mevcut state class'larını import ediyor** (Chat 4-11'de senin oluşturduğun). Eğer aşağıdakilerden biri farklı isimlendirilmişse, **import satırını + field adlarını** noktasal düzelt:

| Provider | Beklenen state class | Beklenen field'lar (subset) |
|---|---|---|
| dashboard | `DashboardData` | `consumedCalories`, `targetCalories`, `macros` (MacrosData), `todaysMeals` |
| dashboard | `MacrosData` | `proteinCurrent/Target`, `carbsCurrent/Target`, `fatCurrent/Target` |
| analytics | `AnalyticsData` | `weeklyCalories`, `macroBreakdown`, `weightTrend`, `achievements` |
| water_tracker | `WaterTrackerState` | `consumedMl`, `targetMl`, `glassesFilled`, `glassesTotal`, `timeline`, `reminders`, `insight`, **+ `copyWith(...)`** |
| habits | `HabitsScreenState` | `todaysHabits`, `streakDays`, `weeklyConsistency`, **+ `copyWith(...)`** |
| habits | `Habit` model | **+ `copyWith({bool? completedToday})`** |

**`copyWith` neden lazım:** Optimistic update için. Eğer `Habit` ve `WaterTrackerState` freezed ile üretildiyse zaten var. Manuel yazıldıysa `copyWith` ekle:

```dart
HabitsScreenState copyWith({
  List<Habit>? todaysHabits,
  int? streakDays,
  List<double>? weeklyConsistency,
}) {
  return HabitsScreenState(
    todaysHabits: todaysHabits ?? this.todaysHabits,
    streakDays: streakDays ?? this.streakDays,
    weeklyConsistency: weeklyConsistency ?? this.weeklyConsistency,
  );
}
```

---

## 🎨 UI'da Error Handling Pattern (UI dosyalarını değiştirmek istersen)

Hazırlık paketindeki pattern'ı koruyoruz — Chat 16'da UI'yi değiştirmiyoruz ama referans olarak:

```dart
import 'package:nuveli/core/network/api_exceptions.dart';

class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return state.when(
      loading: () => const _DashboardSkeleton(),

      error: (err, _) {
        if (err is NetworkException || err is TimeoutException) {
          return _OfflineBanner(
            onRetry: () => ref.invalidate(dashboardProvider),
          );
        }
        if (err is AuthException) {
          // AuthGate (Chat 15) zaten dinliyor; logout otomatik.
          return const SizedBox.shrink();
        }
        if (err is PremiumRequiredException) {
          return const _PaywallTeaser();
        }
        return _GenericError(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        );
      },

      data: (data) => _DashboardContent(data: data),
    );
  }
}
```

**Optimistic update hataları için snackbar:**

```dart
ElevatedButton(
  onPressed: () async {
    try {
      await ref.read(waterTrackerProvider.notifier).addWater(250);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eklenemedi: ${e.message}')),
      );
    }
  },
  child: const Text('+250ml'),
)
```

---

## ✅ Post-Chat Test Senaryoları

`flutter run` sonrası, sırayla:

### 1. Happy path
- [ ] Dashboard açılır → today's summary + meals görünür
- [ ] Water tracker'da `+250ml` → halka anında büyür
- [ ] Habit tile'a tap → tick anında işaretlenir
- [ ] Profile ekranı → name, goal, streak hepsi görünür
- [ ] Analytics → 4 chart paralel yüklenir
- [ ] Meal planner haftalar arası kaydırma
- [ ] AI Coach insight (yoksa empty state)
- [ ] Meal scan: kamera → çek → 2-3 saniye loading → detected foods

### 2. Network failure
- [ ] WiFi kapat → her ekran "Offline" banner gösterir
- [ ] WiFi aç + retry → veri yüklenir

### 3. Cold start (Render free tier)
- [ ] App'i 20 dakika kapat → ilk request 10-30 saniye sürer → timeout 30sn olduğu için başarılı

### 4. Auth refresh
- [ ] Supabase Studio'dan kullanıcının session'ını expire et (manuel)
- [ ] App'te yeni bir request yap → interceptor otomatik refresh → kullanıcı hiç fark etmez

### 5. Optimistic rollback
- [ ] Backend'i Render'da durdur
- [ ] Water tracker'da `+250ml` → halka büyür (optimistic)
- [ ] ~5 saniye sonra hata → halka geri eski değere → snackbar "Eklenemedi"

### 6. Premium gating
- [ ] AI Coach "Force refresh" tap (free user) → 402 → paywall görünür
- [ ] Meal planner "Generate AI plan" (free user) → 402 → paywall

---

## 🚀 Git Workflow

```bash
cd ~/Development/nuveli
git checkout -b feature/chat-16-repository-integration

# Chat 16 değişiklikleri:
git add lib/core/network/
git add lib/core/data/
git add lib/features/*/providers/
git add pubspec.yaml   # dio eklediysen

git commit -m "feat: Chat 16 - Connect all providers to real backend

- Add ApiClient with Dio + auth interceptor (JWT auto-refresh)
- Add typed ApiException hierarchy
- Add 10 repositories (profile, meals, water, habits, weight,
  meal plans, AI coach, analytics, achievements, base)
- Migrate 8 providers from mock to real API
- Add optimistic updates for water + habits
- Add ProfileActions / MealPlannerActions / AiCoachActions pattern"

git push -u origin feature/chat-16-repository-integration
```

---

## 📊 Master Plan Update

`nuveli_master_plan.md` dosyasında:

```diff
### Faz 3: Integration
- [x] **Chat 12: Supabase Audit & Cleanup ✅** (2026-05-19)
- [ ] Chat 13: Supabase Schema
- [ ] Chat 14: Backend API
- [ ] Chat 15: Authentication
- [ ] Chat 16: State Management & Repository Integration
+ [x] **Chat 16: State Management & Repository Integration ✅** (2026-05-19)
- [ ] Chat 17: Navigation & Routing
- [ ] Chat 18: Notifications
```

Üretilen dosyalar (master plan'a not olarak):
```
lib/core/network/
├── api_client.dart
├── api_endpoints.dart
├── api_exceptions.dart
└── auth_interceptor.dart

lib/core/data/repositories/
├── base_repository.dart
├── profile_repository.dart
├── meals_repository.dart
├── water_repository.dart
├── habits_repository.dart
├── weight_repository.dart
├── meal_plans_repository.dart
├── ai_coach_repository.dart
├── analytics_repository.dart
└── achievements_repository.dart

lib/features/*/providers/   (8 dosya güncellendi)
```

---

## 🔮 Sıradaki: Chat 17 — Navigation & Routing

- `go_router` paketi ile tüm ekranları birleştir
- Bottom nav state yönetimi
- Deep linking (örn. `nuveli://meal-scan` push notification'dan)
- Apply Tip → Habits screen'e atla flow'u
- AuthGate ile login/onboarding redirect

Görüşürüz Chat 17'de! 🚀
