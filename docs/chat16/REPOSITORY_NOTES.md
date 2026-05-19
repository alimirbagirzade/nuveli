# 📦 Chat 16 — Repository Layer Notes

Bu doküman, KISIM B1'de üretilen 10 repository dosyasının **beklediği** model class'ları ve import path'lerini listeler. Provider güncellemesine (KISIM B2) geçmeden önce **kısa bir kontrol** yap: eksik veya farklı isimde olan model varsa söyle, repository'i ona göre düzelteyim.

---

## 🎯 Repository'lerin Beklediği Model Path'leri

Aşağıdaki import yolları senin Chat 4-11'de oluşturduğun yapıyı **varsayar**. Farklıysa repository'lerin üstündeki `import` satırlarını güncelle (sadece path değişir — class isimleri ve fromJson imzaları aynı kalmalı).

| Repository | Beklenen Model'ler | Beklenen Import Path |
|---|---|---|
| `profile_repository.dart` | `UserProfile` | `features/profile/models/user_profile.dart` |
| `meals_repository.dart` | `Meal`, `TodaySummary`, `ScanResult` | `features/dashboard/models/meal.dart`, `features/dashboard/models/today_summary.dart`, `features/meal_scan/models/scan_result.dart` |
| `water_repository.dart` | `WaterLog`, `WaterSummary`, `WaterReminder`, `WaterInsight` | `features/water_tracker/models/*.dart` |
| `habits_repository.dart` | `Habit`, `HabitCompletion` | `features/habits/models/*.dart` |
| `weight_repository.dart` | `WeightLog`, `WeightGoal`, `WeightTrend` | `features/profile/models/*.dart` |
| `meal_plans_repository.dart` | `MealPlanWeek`, `MealPlanEntry`, `Recipe`, `GrocerySummary` | `features/meal_planner/models/*.dart` |
| `ai_coach_repository.dart` | `CoachInsight`, `ApplyTipResult` | `features/ai_coach/models/*.dart` |
| `analytics_repository.dart` | `WeeklyCalorieData`, `MacroBreakdown`, `WeightTrend` | `features/analytics/models/*.dart` (+ `features/profile/models/weight_trend.dart`) |
| `achievements_repository.dart` | `Achievement` | `features/analytics/models/achievement.dart` |

---

## ✅ Her Model Class'ında Olmalı

Repository'ler şu pattern'a güveniyor:

```dart
class Meal {
  // ... fields
  factory Meal.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }   // (opsiyonel, request bodylerde kullanmıyoruz)
}
```

**Eğer freezed + json_serializable ile üretildiyse** otomatik olur, hiç dokunma. **Manuel yazıldıysa** snake_case → camelCase mapping örneği:

```dart
factory Meal.fromJson(Map<String, dynamic> json) {
  return Meal(
    id: json['id'] as String,
    name: json['name'] as String,
    calories: (json['calories'] as num).toDouble(),
    proteinG: (json['protein_g'] as num).toDouble(),   // snake → camel
    carbsG: (json['carbs_g'] as num).toDouble(),
    fatG: (json['fat_g'] as num).toDouble(),
    consumedAt: DateTime.parse(json['consumed_at'] as String).toLocal(),
  );
}
```

**ÖNEMLİ:** Tüm `DateTime` parse'larında `.toLocal()` ekle — backend UTC saklıyor.

---

## 🧱 Backend Endpoint Contract'ı (Repository → API)

Her repository hangi endpoint'i nasıl çağırıyor, hangi HTTP method, hangi body:

### Profile
- `GET  /me` → `UserProfile`
- `PATCH /profile` body `{display_name?, weight_kg?, height_cm?, daily_calorie_target?, protein_target_pct?, carbs_target_pct?, fat_target_pct?, activity_level?, goal_type?}` → `UserProfile`
- `POST /profile/onboarding` body `{display_name, weight_kg, height_cm, age_years, sex, activity_level, goal_type, target_weight_kg?, target_date?}` → `UserProfile`

### Meals
- `GET  /meals?date=YYYY-MM-DD` → `List<Meal>`
- `GET  /meals/today/summary` → `TodaySummary`
- `POST /meals/scan` body `{image_base64}` → `ScanResult`
- `POST /meals` body `{name, calories, protein_g, carbs_g, fat_g, grams?, meal_type?, consumed_at?, photo_url?, notes?}` → `Meal`
- `PATCH /meals/{id}` body (partial fields) → `Meal`
- `DELETE /meals/{id}` → void

### Water
- `GET  /water/today/summary` → `WaterSummary`
- `GET  /water/logs?date=YYYY-MM-DD` → `List<WaterLog>`
- `POST /water/logs` body `{amount_ml, logged_at?}` → `WaterLog`
- `DELETE /water/logs/{id}` → void
- `GET  /water/reminders` → `List<WaterReminder>`
- `PATCH /water/reminders/{id}` body `{enabled?}` veya `{time?}` → `WaterReminder`
- `GET  /water/insight` → `WaterInsight`

### Habits
- `GET  /habits/today` → `List<Habit>` (`completedToday` flag dahil)
- `GET  /habits?include_archived=false` → `List<Habit>`
- `POST /habits/{id}/toggle` → `HabitCompletion` veya `{completed: false}`
- `GET  /habits/streak` → `{streak_days: int}`
- `GET  /habits/consistency` → `{days: [0.0..1.0, x7]}`
- `POST /habits` body `{name, icon, target_type, target_value?, schedule?}` → `Habit`
- `PATCH /habits/{id}` body (partial) → `Habit`
- `DELETE /habits/{id}` → void

### Weight
- `GET  /weight/logs?days=56` → `List<WeightLog>`
- `POST /weight/logs` body `{kg, logged_at?, notes?}` → `WeightLog`
- `DELETE /weight/logs/{id}` → void
- `GET  /weight/goal` → `WeightGoal` (veya 404 → null)
- `PUT  /weight/goal` body `{target_kg, target_date, goal_type?}` → `WeightGoal`
- `DELETE /weight/goal` → void
- `GET  /weight/trend?weeks=8` → `WeightTrend`

### Meal Planner
- `GET  /meal-plans?week_of=YYYY-MM-DD` → `MealPlanWeek`
- `POST /meal-plans` body `{plan_date, meal_type, recipe_id, servings?}` → `MealPlanEntry`
- `DELETE /meal-plans/{id}` → void
- `POST /meal-plans/generate` body `{week_start_date, replace_existing, dietary_preferences?}` → `MealPlanWeek` (Premium)
- `GET  /meal-plans/grocery?week_of=YYYY-MM-DD` → `GrocerySummary`
- `GET  /recipes?q=...&limit=30` → `List<Recipe>`
- `GET  /recipes/{id}` → `Recipe`

### AI Coach
- `GET  /coach/today` → `CoachInsight` (veya 404 → null)
- `POST /coach/apply-tip` body `{insight_id, tip_kind, payload?}` → `ApplyTipResult`
- `POST /coach/refresh` → `CoachInsight` (Premium)

### Analytics
- `GET  /analytics/weekly` → `WeeklyCalorieData`
- `GET  /analytics/macros?days=7` → `MacroBreakdown`
- `GET  /analytics/weight?weeks=8` → `WeightTrend`

### Achievements
- `GET  /achievements` → `List<Achievement>` (her birinde `unlocked` flag'i)

---

## ⚠️ Olası Uyumsuzluk Noktaları

Eğer Chat 14'te backend bunlardan biri farklı kuruldu ise söyle:

1. **404 → null normalization:** `WeightGoal` ve `CoachInsight` için "yok" durumunu 404 ile mi gösteriyor, yoksa `200 + null` body ile mi? Repository'de 404 yakalıyorum.
2. **Habit toggle response:** "Toggled off" durumu için backend `{completed: false}` mı dönüyor, yoksa 204 No Content mi? Şu an `{completed: false}` varsayıyorum.
3. **Endpoint isimleri:** `/coach/today` mi yoksa `/ai-coach/today` mi? Hazırlık paketi `/coach/today` diyordu, onu kullandım.
4. **Date filter parametresi:** Her yerde `date=YYYY-MM-DD` kullandım. Bazı endpoint'lerde `from`/`to` kombinasyonu varsa söyle.

---

## 🚀 KISIM B2 — Sonraki Adım

Bu dosyaları indirip `lib/core/data/repositories/` altına kopyala. Eğer:

- ✅ **Hiçbir hata yok** → `flutter analyze` yeşil — devam edelim, provider'lara geçeyim.
- ⚠️ **Import error veya tip uyumsuzluğu** → ekran görüntüsü/hata mesajı yapıştır, ben düzelteyim.

Provider güncellemeleri (8 dosya):
1. `dashboard_provider.dart`
2. `profile_provider.dart`
3. `analytics_provider.dart`
4. `water_tracker_provider.dart`
5. `meal_planner_provider.dart`
6. `habits_provider.dart`
7. `ai_coach_provider.dart`
8. `meal_scan_provider.dart`
