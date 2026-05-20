# 👤 Reviewer Test Account Setup

**Hedef:** Apple ve Google reviewer'lar için demo hesabı oluşturmak, Premium aktif etmek, sample data seed etmek.

⚠️ **Bu hesap ÇOK ÖNEMLİ.** Reviewer hesap çalışmazsa anında reject.

---

## 🎯 Reviewer Hesabı Spec

| Alan | Değer |
|---|---|
| **Email** | `reviewer@nuveli.app` |
| **Password** | `ReviewPass2026!` |
| **User ID (Supabase)** | (auto-generated, kayıt al) |
| **Premium Status** | ✅ Active (sandbox / manual) |
| **Sample Data** | 7 days of meals, water, weight, habits |
| **Onboarding** | ✅ Completed |
| **Apple Health Sync** | ❌ Disabled (reviewer'ın izin vermesi için açık) |
| **Notifications** | ✅ Enabled |

---

## 📋 Adım 1: Hesabı Oluştur (Production Supabase'de)

### Yöntem A: App içinden manuel oluştur
1. Production app'i (Internal TestFlight build veya release) cihazda aç
2. **Sign Up** → `reviewer@nuveli.app` / `ReviewPass2026!`
3. Onboarding'i tamamla:
   - Name: "Test Reviewer"
   - Age: 32
   - Sex: Female (variety için)
   - Weight: 65 kg
   - Height: 168 cm
   - Activity level: Moderate
   - Goal: Lose weight (4 kg)
   - Daily calorie target: ~1700 kcal (otomatik hesaplar)

### Yöntem B: Supabase Dashboard'dan direct (önerilen, kontrollü)
1. Supabase Dashboard → Authentication → Users → **Add user**
2. Email: `reviewer@nuveli.app`
3. Password: `ReviewPass2026!`
4. Email confirm: ✅ Auto-confirm (production'da email confirmation'ı bypass et)
5. Create user → user ID'sini kopyala (UUID format)

---

## 📋 Adım 2: User Profile'ı Doldur

Supabase SQL Editor'da:

```sql
-- User profile insert (user_id yukarıda aldığın UUID)
INSERT INTO user_profiles (
  user_id,
  name,
  email,
  age,
  sex,
  weight_kg,
  height_cm,
  activity_level,
  goal,
  daily_calorie_target,
  daily_water_target_ml,
  onboarding_completed,
  created_at,
  is_test_account
) VALUES (
  'REVIEWER_USER_ID_HERE',  -- 1. adımdaki UUID
  'Test Reviewer',
  'reviewer@nuveli.app',
  32,
  'female',
  65,
  168,
  'moderate',
  'lose_weight',
  1700,
  2000,
  true,
  now() - interval '7 days',
  true  -- test hesabı olduğunu işaretle
);
```

---

## 📋 Adım 3: Premium Aktif Et

Reviewer hesabının **Premium subscription** olması gerekiyor (paywall'u test edebilsin).

### Yöntem A: Manual Database Flag (En Kolay)

```sql
-- Mock premium entitlement
INSERT INTO premium_entitlements (
  user_id,
  entitlement_type,
  is_active,
  expires_at,
  source,
  created_at
) VALUES (
  'REVIEWER_USER_ID_HERE',
  'lifetime',  -- veya 'annual' veya 'monthly'
  true,
  null,  -- lifetime için null
  'manual_grant',  -- "App Store" yerine "manual_grant" diye işaretle
  now()
);
```

⚠️ **Önemli:** App içindeki premium check şu logic'i kullanmalı:
```dart
// premium_repository.dart
Future<bool> isPremium() async {
  // 1. RevenueCat'ten kontrol et
  final customerInfo = await Purchases.getCustomerInfo();
  if (customerInfo.entitlements.active.isNotEmpty) return true;
  
  // 2. Backend'deki entitlement tablosunu kontrol et (manuel grant için)
  final user = supabase.auth.currentUser;
  if (user == null) return false;
  
  final response = await supabase
      .from('premium_entitlements')
      .select()
      .eq('user_id', user.id)
      .eq('is_active', true)
      .maybeSingle();
  
  return response != null;
}
```

### Yöntem B: RevenueCat Sandbox

RevenueCat dashboard'da sandbox user için entitlement ata.

⚠️ **Sandbox sadece TestFlight build'de çalışır.** Production'da bunu kullanma.

### Yöntem C: Promo Code (Apple zorunlu)
Apple **promo code** sistemi var (App Store Connect → Promo Codes). Subscription için 1 yıl ücretsiz promo code üretip reviewer notes'a koyabilirsin.

Ama bu daha karmaşık, Yöntem A daha basit.

---

## 📋 Adım 4: Sample Data Seed

Reviewer'ın boş bir app görmemesi için 7 günlük sample data ekle.

### SQL Seed Script

`launch_assets/submission/seed_reviewer_data.sql` dosyası oluştur:

```sql
-- ═══════════════════════════════════════════════════════
-- REVIEWER ACCOUNT — SAMPLE DATA SEED
-- Run after creating reviewer account
-- ═══════════════════════════════════════════════════════

DO $$
DECLARE
  user_uuid uuid := 'REVIEWER_USER_ID_HERE';
BEGIN

-- ─────────────────────────────────────────────────────
-- MEALS (7 gün, günde 3-4 öğün)
-- ─────────────────────────────────────────────────────
INSERT INTO meals (user_id, name, calories, protein_g, carbs_g, fat_g, meal_type, logged_at) VALUES
-- Day -7 (1 hafta önce)
(user_uuid, 'Greek Yogurt with Berries', 220, 18, 25, 5, 'breakfast', now() - interval '7 days' + interval '8 hours'),
(user_uuid, 'Grilled Chicken Salad', 380, 35, 15, 18, 'lunch', now() - interval '7 days' + interval '13 hours'),
(user_uuid, 'Apple with Almond Butter', 200, 6, 22, 12, 'snack', now() - interval '7 days' + interval '16 hours'),
(user_uuid, 'Salmon with Quinoa', 480, 38, 35, 18, 'dinner', now() - interval '7 days' + interval '19 hours'),

-- Day -6
(user_uuid, 'Oatmeal with Banana', 320, 12, 58, 6, 'breakfast', now() - interval '6 days' + interval '8 hours'),
(user_uuid, 'Turkey Sandwich', 420, 28, 42, 15, 'lunch', now() - interval '6 days' + interval '13 hours'),
(user_uuid, 'Vegetable Stir-fry', 350, 18, 38, 14, 'dinner', now() - interval '6 days' + interval '19 hours'),

-- Day -5
(user_uuid, 'Smoothie Bowl', 280, 10, 48, 8, 'breakfast', now() - interval '5 days' + interval '8 hours'),
(user_uuid, 'Caesar Wrap', 460, 22, 38, 22, 'lunch', now() - interval '5 days' + interval '13 hours'),
(user_uuid, 'Greek Salad with Feta', 320, 14, 18, 22, 'dinner', now() - interval '5 days' + interval '19 hours'),

-- Day -4
(user_uuid, 'Eggs with Avocado Toast', 380, 22, 30, 20, 'breakfast', now() - interval '4 days' + interval '8 hours'),
(user_uuid, 'Quinoa Buddha Bowl', 440, 18, 58, 14, 'lunch', now() - interval '4 days' + interval '13 hours'),
(user_uuid, 'Protein Bar', 200, 20, 22, 5, 'snack', now() - interval '4 days' + interval '16 hours'),
(user_uuid, 'Chicken Tikka with Rice', 520, 35, 52, 16, 'dinner', now() - interval '4 days' + interval '19 hours'),

-- Day -3
(user_uuid, 'Protein Pancakes', 360, 25, 40, 10, 'breakfast', now() - interval '3 days' + interval '8 hours'),
(user_uuid, 'Tuna Salad', 320, 30, 12, 18, 'lunch', now() - interval '3 days' + interval '13 hours'),
(user_uuid, 'Beef Stir-fry', 480, 38, 32, 20, 'dinner', now() - interval '3 days' + interval '19 hours'),

-- Day -2
(user_uuid, 'Avocado Toast', 280, 10, 32, 14, 'breakfast', now() - interval '2 days' + interval '8 hours'),
(user_uuid, 'Sushi (8 pcs)', 380, 22, 52, 10, 'lunch', now() - interval '2 days' + interval '13 hours'),
(user_uuid, 'Mixed Nuts', 180, 6, 8, 16, 'snack', now() - interval '2 days' + interval '16 hours'),
(user_uuid, 'Pad Thai', 520, 22, 68, 18, 'dinner', now() - interval '2 days' + interval '19 hours'),

-- Day -1 (dün)
(user_uuid, 'Egg White Omelet', 220, 24, 8, 12, 'breakfast', now() - interval '1 day' + interval '8 hours'),
(user_uuid, 'Chicken Caesar Wrap', 440, 32, 38, 18, 'lunch', now() - interval '1 day' + interval '13 hours'),
(user_uuid, 'Greek Yogurt', 120, 14, 12, 2, 'snack', now() - interval '1 day' + interval '16 hours'),
(user_uuid, 'Grilled Fish with Vegetables', 380, 35, 22, 14, 'dinner', now() - interval '1 day' + interval '19 hours'),

-- Today (bugün, sadece kahvaltı + öğle)
(user_uuid, 'Banana with Peanut Butter', 280, 8, 35, 14, 'breakfast', now() - interval '4 hours'),
(user_uuid, 'Mediterranean Bowl', 460, 22, 52, 18, 'lunch', now() - interval '1 hour');

-- ─────────────────────────────────────────────────────
-- WATER LOGS (her gün 6-8 bardak)
-- ─────────────────────────────────────────────────────
INSERT INTO water_logs (user_id, amount_ml, logged_at)
SELECT
  user_uuid,
  250,  -- 250ml per glass
  now() - (interval '1 day' * day) - (interval '1 hour' * hour)
FROM
  generate_series(0, 7) AS day,
  generate_series(8, 20, 2) AS hour;  -- saat 8, 10, 12, 14, 16, 18, 20

-- ─────────────────────────────────────────────────────
-- WEIGHT LOGS (her 2 günde bir, kilo veriyor)
-- ─────────────────────────────────────────────────────
INSERT INTO weight_logs (user_id, weight_kg, logged_at) VALUES
(user_uuid, 67.5, now() - interval '7 days'),
(user_uuid, 67.2, now() - interval '5 days'),
(user_uuid, 66.8, now() - interval '3 days'),
(user_uuid, 66.5, now() - interval '1 day'),
(user_uuid, 66.3, now());

-- ─────────────────────────────────────────────────────
-- HABITS
-- ─────────────────────────────────────────────────────
INSERT INTO habits (id, user_id, name, icon, target_per_day, created_at) VALUES
(gen_random_uuid(), user_uuid, 'Eat breakfast', '🍳', 1, now() - interval '7 days'),
(gen_random_uuid(), user_uuid, 'Drink 2L water', '💧', 1, now() - interval '7 days'),
(gen_random_uuid(), user_uuid, 'Walk 8000 steps', '🚶‍♀️', 1, now() - interval '7 days'),
(gen_random_uuid(), user_uuid, 'Take vitamins', '💊', 1, now() - interval '7 days'),
(gen_random_uuid(), user_uuid, 'Sleep 7h+', '😴', 1, now() - interval '7 days');

-- Habit completions (son 7 gün, çoğu tamamlanmış)
INSERT INTO habit_completions (user_id, habit_id, completed_at)
SELECT
  user_uuid,
  h.id,
  (now() - (interval '1 day' * day)) + interval '20 hours'
FROM
  habits h,
  generate_series(0, 6) AS day
WHERE h.user_id = user_uuid
  AND (day != 2 OR h.name != 'Take vitamins');  -- 2 gün önce vitamini unutmuş (gerçekçi)

-- ─────────────────────────────────────────────────────
-- AI INSIGHTS (bugünün insight'ı)
-- ─────────────────────────────────────────────────────
INSERT INTO ai_insights (user_id, insight_type, title, content, score, created_at) VALUES
(
  user_uuid,
  'daily_summary',
  '💪 Great protein week!',
  'You averaged 28g of protein per meal this week — that''s 12% above your target. Your consistency with meal timing is also excellent. Tomorrow, try adding more leafy greens to balance the macros.',
  85,
  now() - interval '2 hours'
);

-- ─────────────────────────────────────────────────────
-- MEAL PLAN (örnek haftalık plan, Premium feature)
-- ─────────────────────────────────────────────────────
INSERT INTO meal_plans (id, user_id, week_start, plan_data, created_at) VALUES
(
  gen_random_uuid(),
  user_uuid,
  date_trunc('week', now())::date,
  '{
    "monday": {
      "breakfast": {"name": "Oatmeal with berries", "calories": 320},
      "lunch": {"name": "Chicken salad", "calories": 420},
      "dinner": {"name": "Salmon with quinoa", "calories": 480}
    },
    "tuesday": {
      "breakfast": {"name": "Greek yogurt", "calories": 220},
      "lunch": {"name": "Turkey wrap", "calories": 400},
      "dinner": {"name": "Vegetable stir-fry", "calories": 350}
    }
  }'::jsonb,
  now() - interval '6 days'
);

RAISE NOTICE 'Reviewer account seeded successfully.';

END $$;
```

### Çalıştırma
1. Supabase Dashboard → SQL Editor
2. Yukarıdaki SQL'i yapıştır
3. `REVIEWER_USER_ID_HERE` placeholder'ını gerçek UUID ile değiştir
4. **Run**

---

## 📋 Adım 5: Manual Test

App'i yeni device'da aç:
1. Login: `reviewer@nuveli.app` / `ReviewPass2026!`
2. Dashboard kontrol:
   - ✅ "Hi, Test Reviewer" başlık
   - ✅ Bugün için 2 meal log
   - ✅ Bu hafta için kilo trendi grafiği
   - ✅ AI insight bugün
   - ✅ Habit streak 6/7 gün
3. Analytics tab:
   - ✅ 7-day chart dolu
   - ✅ Macro breakdown
   - ✅ Weight trend (67.5 → 66.3 kg)
4. Premium check:
   - ✅ Settings → "Premium Active"
   - ✅ Tüm Premium feature'lara erişim var
5. Meal Plan tab:
   - ✅ Haftalık plan görünür (Premium feature)
6. Test edilebilir akışlar:
   - ✅ Camera scan → AI işliyor (gerçek OpenAI çağrısı)
   - ✅ Water tap → +250ml
   - ✅ Habit complete → animation

---

## 📋 Adım 6: Apple Reviewer Notes'a Ekle

`launch_assets/submission/app_store_connect_form.md`'de zaten var ama özetle:

```
TEST ACCOUNT:
Email: reviewer@nuveli.app
Password: ReviewPass2026!

This account has:
- Premium subscription enabled (manual grant for testing)
- Onboarding completed (Test Reviewer, 32y female, 65kg, goal: lose weight)
- 7 days of sample data: meals, water, weight, habits
- AI Coach insight available on dashboard
- Sample meal plan for current week

TESTING THE AI MEAL SCAN:
The AI scan uses real OpenAI API calls. You can:
1. Take a photo of any food (real or printed)
2. Wait 3-5 seconds for processing
3. AI returns estimated foods + macros
4. Confirm or edit, then save

TESTING PREMIUM PURCHASE:
The reviewer account already has Premium. To test purchase flow with a fresh account:
1. Sign out
2. Create new account with any email
3. Navigate to Settings → Premium → Try Free
4. Use sandbox tester credentials for purchase
```

---

## 📋 Adım 7: Google Reviewer Setup

Google için de aynı hesap çalışır. Play Console → App access → "Login required" form'da:

```
Username: reviewer@nuveli.app
Password: ReviewPass2026!

Notes:
This is a test account with Premium enabled and 7 days of sample data.
The account has Lifetime Premium granted manually for testing.
All features should be accessible.

If the reviewer needs additional test scenarios (e.g., free account state),
they can create a new account with any email through the app's sign-up flow.

Support contact: support@nuveli.app
```

---

## 🚨 Yaygın Sorunlar

### Reviewer "Cannot log in"
- Çözüm: Şifre kopyalanmadıktan sonra **boşluk veya görünmez karakter** olmadığından emin ol
- Test: kendi cihazında reviewer hesabıyla giriş yap

### Reviewer "Premium not active"
- Çözüm: `premium_entitlements` tablosunda satır var mı?
- App içindeki premium check logic'i veritabanını kontrol ediyor mu?

### Reviewer "App crashes on launch"
- Onboarding bypass problemi olabilir
- `onboarding_completed = true` set edilmemiş
- Yeniden seed scripti çalıştır

### "AI meal scan returns error"
- Backend'de OpenAI API key geçerli mi?
- Rate limit hit'i mi? (production tier al)
- Reviewer notes'a alternatif test ekle: "If AI scan times out, manually log meals"

---

## 🔒 Güvenlik Notu

⚠️ **Reviewer hesabını LIVE ortamda bırakma.** Launch sonrası:
- Şifreyi rotate et
- Veya tamamen sil
- Veya `is_test_account` flag'iyle analytics'ten çıkar

Production analytics'i bozmaması için `is_test_account = true` field'ı:
```sql
-- Analytics query'lerinde test hesabını exclude et
SELECT count(*) FROM user_profiles
WHERE is_test_account = false;
```

---

## ✅ Final Checklist

- [ ] Reviewer hesabı oluşturuldu (Supabase Auth)
- [ ] `user_profiles` table'da profile var
- [ ] `premium_entitlements`'ta lifetime entry var
- [ ] 7 günlük sample data seed edildi (meals, water, weight, habits)
- [ ] AI insight bugün için var
- [ ] Meal plan örnek hafta için var
- [ ] Cihazda manual test edildi: login + dashboard + premium + AI scan
- [ ] App Store Connect reviewer notes'a credentials eklendi
- [ ] Play Console "Login required" form'a credentials eklendi
- [ ] `is_test_account = true` flag analytics'i bozmasın diye set
