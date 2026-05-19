-- =============================================================================
-- Migration 010: Row Level Security (RLS) politikaları
-- =============================================================================
-- Kural: Her kullanıcı SADECE kendi verisini görür/yazar/günceller/siler.
-- İstisna: recipes — public olanlar herkese, private olanlar sahibine.
-- Tüm policy isimleri snake_case, açıklayıcı.
-- =============================================================================

BEGIN;

-- =============================================================================
-- 1. TÜM TABLOLAR İÇİN RLS'İ ETKİNLEŞTİR
-- =============================================================================
ALTER TABLE public.user_profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meals              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_foods         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_reminders    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_plans         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_goals       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_insights        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements  ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 2. user_profiles
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_profile ON public.user_profiles;
CREATE POLICY users_select_own_profile ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_profile ON public.user_profiles;
CREATE POLICY users_insert_own_profile ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_profile ON public.user_profiles;
CREATE POLICY users_update_own_profile ON public.user_profiles
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- user_profiles silinmez (auth.users CASCADE ile silinir)

-- =============================================================================
-- 3. meals
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_meals ON public.meals;
CREATE POLICY users_select_own_meals ON public.meals
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_meals ON public.meals;
CREATE POLICY users_insert_own_meals ON public.meals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_meals ON public.meals;
CREATE POLICY users_update_own_meals ON public.meals
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_meals ON public.meals;
CREATE POLICY users_delete_own_meals ON public.meals
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 4. meal_foods (meal sahibi üzerinden erişim)
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_meal_foods ON public.meal_foods;
CREATE POLICY users_select_own_meal_foods ON public.meal_foods
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.meals
      WHERE meals.id = meal_foods.meal_id AND meals.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS users_insert_own_meal_foods ON public.meal_foods;
CREATE POLICY users_insert_own_meal_foods ON public.meal_foods
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.meals
      WHERE meals.id = meal_foods.meal_id AND meals.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS users_update_own_meal_foods ON public.meal_foods;
CREATE POLICY users_update_own_meal_foods ON public.meal_foods
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.meals
      WHERE meals.id = meal_foods.meal_id AND meals.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS users_delete_own_meal_foods ON public.meal_foods;
CREATE POLICY users_delete_own_meal_foods ON public.meal_foods
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.meals
      WHERE meals.id = meal_foods.meal_id AND meals.user_id = auth.uid()
    )
  );

-- =============================================================================
-- 5. water_logs
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_water_logs ON public.water_logs;
CREATE POLICY users_select_own_water_logs ON public.water_logs
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_water_logs ON public.water_logs;
CREATE POLICY users_insert_own_water_logs ON public.water_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_water_logs ON public.water_logs;
CREATE POLICY users_update_own_water_logs ON public.water_logs
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_water_logs ON public.water_logs;
CREATE POLICY users_delete_own_water_logs ON public.water_logs
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 6. water_reminders
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_water_reminders ON public.water_reminders;
CREATE POLICY users_select_own_water_reminders ON public.water_reminders
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_water_reminders ON public.water_reminders;
CREATE POLICY users_insert_own_water_reminders ON public.water_reminders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_water_reminders ON public.water_reminders;
CREATE POLICY users_update_own_water_reminders ON public.water_reminders
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_water_reminders ON public.water_reminders;
CREATE POLICY users_delete_own_water_reminders ON public.water_reminders
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 7. habits
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_habits ON public.habits;
CREATE POLICY users_select_own_habits ON public.habits
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_habits ON public.habits;
CREATE POLICY users_insert_own_habits ON public.habits
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_habits ON public.habits;
CREATE POLICY users_update_own_habits ON public.habits
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_habits ON public.habits;
CREATE POLICY users_delete_own_habits ON public.habits
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 8. habit_completions
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_habit_completions ON public.habit_completions;
CREATE POLICY users_select_own_habit_completions ON public.habit_completions
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_habit_completions ON public.habit_completions;
CREATE POLICY users_insert_own_habit_completions ON public.habit_completions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_habit_completions ON public.habit_completions;
CREATE POLICY users_update_own_habit_completions ON public.habit_completions
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_habit_completions ON public.habit_completions;
CREATE POLICY users_delete_own_habit_completions ON public.habit_completions
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 9. recipes (ÖZEL: public + own)
-- =============================================================================
DROP POLICY IF EXISTS users_select_visible_recipes ON public.recipes;
CREATE POLICY users_select_visible_recipes ON public.recipes
  FOR SELECT USING (
    is_public = TRUE OR auth.uid() = user_id
  );

DROP POLICY IF EXISTS users_insert_own_recipes ON public.recipes;
CREATE POLICY users_insert_own_recipes ON public.recipes
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND user_id IS NOT NULL
  );

DROP POLICY IF EXISTS users_update_own_recipes ON public.recipes;
CREATE POLICY users_update_own_recipes ON public.recipes
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_recipes ON public.recipes;
CREATE POLICY users_delete_own_recipes ON public.recipes
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 10. meal_plans
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_meal_plans ON public.meal_plans;
CREATE POLICY users_select_own_meal_plans ON public.meal_plans
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_meal_plans ON public.meal_plans;
CREATE POLICY users_insert_own_meal_plans ON public.meal_plans
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_meal_plans ON public.meal_plans;
CREATE POLICY users_update_own_meal_plans ON public.meal_plans
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_meal_plans ON public.meal_plans;
CREATE POLICY users_delete_own_meal_plans ON public.meal_plans
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 11. weight_logs
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_weight_logs ON public.weight_logs;
CREATE POLICY users_select_own_weight_logs ON public.weight_logs
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_weight_logs ON public.weight_logs;
CREATE POLICY users_insert_own_weight_logs ON public.weight_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_weight_logs ON public.weight_logs;
CREATE POLICY users_update_own_weight_logs ON public.weight_logs
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_weight_logs ON public.weight_logs;
CREATE POLICY users_delete_own_weight_logs ON public.weight_logs
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 12. weight_goals
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_weight_goals ON public.weight_goals;
CREATE POLICY users_select_own_weight_goals ON public.weight_goals
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_weight_goals ON public.weight_goals;
CREATE POLICY users_insert_own_weight_goals ON public.weight_goals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_weight_goals ON public.weight_goals;
CREATE POLICY users_update_own_weight_goals ON public.weight_goals
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_weight_goals ON public.weight_goals;
CREATE POLICY users_delete_own_weight_goals ON public.weight_goals
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- 13. ai_insights — SADECE SELECT (insert/update backend service_role ile)
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_ai_insights ON public.ai_insights;
CREATE POLICY users_select_own_ai_insights ON public.ai_insights
  FOR SELECT USING (auth.uid() = user_id);

-- INSERT/UPDATE policy yok → client tarafından yazılamaz, sadece backend service_role
-- (service_role tüm RLS'leri bypass eder)

-- =============================================================================
-- 14. user_achievements
-- =============================================================================
DROP POLICY IF EXISTS users_select_own_achievements ON public.user_achievements;
CREATE POLICY users_select_own_achievements ON public.user_achievements
  FOR SELECT USING (auth.uid() = user_id);

-- INSERT/UPDATE backend tarafından yapılır (service_role)
-- Client direkt achievement unlock edemez

COMMIT;

-- =============================================================================
-- Doğrulama:
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
-- SELECT tablename, policyname, cmd FROM pg_policies WHERE schemaname='public' ORDER BY tablename, policyname;
-- =============================================================================
