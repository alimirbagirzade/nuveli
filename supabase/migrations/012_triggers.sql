-- =============================================================================
-- Migration 012: Trigger fonksiyonları ve trigger'lar
-- =============================================================================
-- İçindekiler:
--   1. update_updated_at_column → her UPDATE'te updated_at = NOW()
--   2. recalculate_meal_totals → meal_foods değişince meals.total_* hesapla
--   3. update_user_streak → her meal eklendiğinde streak hesapla
--   4. handle_new_user → auth.users INSERT'inde profile + habits + achievements
--   5. check_achievement_unlock → current_value >= target_value olunca unlock
-- =============================================================================

BEGIN;

-- =============================================================================
-- 1. GENERIC: updated_at otomatik güncelleme
-- =============================================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Her updated_at içeren tabloya trigger ekle
DROP TRIGGER IF EXISTS trg_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_meals_updated_at ON public.meals;
CREATE TRIGGER trg_meals_updated_at
  BEFORE UPDATE ON public.meals
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_water_reminders_updated_at ON public.water_reminders;
CREATE TRIGGER trg_water_reminders_updated_at
  BEFORE UPDATE ON public.water_reminders
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_habits_updated_at ON public.habits;
CREATE TRIGGER trg_habits_updated_at
  BEFORE UPDATE ON public.habits
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_recipes_updated_at ON public.recipes;
CREATE TRIGGER trg_recipes_updated_at
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_meal_plans_updated_at ON public.meal_plans;
CREATE TRIGGER trg_meal_plans_updated_at
  BEFORE UPDATE ON public.meal_plans
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_weight_goals_updated_at ON public.weight_goals;
CREATE TRIGGER trg_weight_goals_updated_at
  BEFORE UPDATE ON public.weight_goals
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trg_user_achievements_updated_at ON public.user_achievements;
CREATE TRIGGER trg_user_achievements_updated_at
  BEFORE UPDATE ON public.user_achievements
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================================================
-- 2. meal_foods değişince meals.total_* alanlarını yeniden hesapla
-- =============================================================================
CREATE OR REPLACE FUNCTION public.recalculate_meal_totals()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  meal_id_to_update UUID;
BEGIN
  meal_id_to_update := COALESCE(NEW.meal_id, OLD.meal_id);

  UPDATE public.meals
  SET
    total_calories  = COALESCE((SELECT SUM(calories)   FROM public.meal_foods WHERE meal_id = meal_id_to_update), 0),
    total_protein_g = COALESCE((SELECT SUM(protein_g)  FROM public.meal_foods WHERE meal_id = meal_id_to_update), 0),
    total_carbs_g   = COALESCE((SELECT SUM(carbs_g)    FROM public.meal_foods WHERE meal_id = meal_id_to_update), 0),
    total_fat_g     = COALESCE((SELECT SUM(fat_g)      FROM public.meal_foods WHERE meal_id = meal_id_to_update), 0),
    updated_at      = NOW()
  WHERE id = meal_id_to_update;

  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_recalc_meal_on_food_change ON public.meal_foods;
CREATE TRIGGER trg_recalc_meal_on_food_change
  AFTER INSERT OR UPDATE OR DELETE ON public.meal_foods
  FOR EACH ROW EXECUTE FUNCTION public.recalculate_meal_totals();

-- =============================================================================
-- 3. Her meal eklendiğinde user streak güncelle
-- =============================================================================
CREATE OR REPLACE FUNCTION public.update_user_streak()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_last_active DATE;
  v_current_streak INT;
BEGIN
  SELECT last_active_date, current_streak_days
    INTO v_last_active, v_current_streak
  FROM public.user_profiles
  WHERE user_id = NEW.user_id;

  -- Profile yoksa (signup trigger ile gelmesi gerekiyor) sessizce çık
  IF NOT FOUND THEN
    RETURN NEW;
  END IF;

  IF v_last_active = CURRENT_DATE THEN
    -- Bugün zaten aktif, değişiklik yok
    RETURN NEW;
  ELSIF v_last_active = CURRENT_DATE - INTERVAL '1 day' THEN
    -- Dün de aktifti → streak +1
    UPDATE public.user_profiles SET
      current_streak_days = v_current_streak + 1,
      longest_streak_days = GREATEST(longest_streak_days, v_current_streak + 1),
      last_active_date = CURRENT_DATE
    WHERE user_id = NEW.user_id;
  ELSE
    -- Streak kırıldı → 1'den başla
    UPDATE public.user_profiles SET
      current_streak_days = 1,
      longest_streak_days = GREATEST(longest_streak_days, 1),
      last_active_date = CURRENT_DATE
    WHERE user_id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_streak_on_meal ON public.meals;
CREATE TRIGGER trg_update_streak_on_meal
  AFTER INSERT ON public.meals
  FOR EACH ROW EXECUTE FUNCTION public.update_user_streak();

-- =============================================================================
-- 4. Yeni kullanıcı kayıt olunca profile + default habits + achievements oluştur
-- =============================================================================
-- Önce default habits ve achievements helper fonksiyonları (013_seed_data.sql'de
-- de yer alıyor — burada idempotent yeniden tanımlıyoruz ki sıralama bağımsız olsun)

CREATE OR REPLACE FUNCTION public.create_default_habits_for_user(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.habits
    (user_id, habit_type, title, subtitle, icon, icon_color, target_type, target_value, target_unit, display_order)
  VALUES
    (p_user_id, 'meal',       'Log breakfast',      'Track your first meal',         'rice_bowl',         '#3DDC97', 'check', NULL,  NULL,      1),
    (p_user_id, 'hydration',  'Drink 8 glasses',    'Stay hydrated',                 'water_drop',        '#00D4FF', 'count', 8,     'glasses', 2),
    (p_user_id, 'exercise',   'Walk 6,000 steps',   'Daily movement goal',           'directions_run',    '#3DDC97', 'count', 6000,  'steps',   3),
    (p_user_id, 'protein',    'Protein goal',       'Hit your daily protein target', 'fitness_center',    '#00D4FF', 'check', NULL,  NULL,      4),
    (p_user_id, 'sleep',      'Sleep before 11 PM', 'Get quality rest',              'nightlight_round',  '#B8C5D6', 'check', NULL,  NULL,      5)
  ON CONFLICT DO NOTHING;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_default_achievements_for_user(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_achievements
    (user_id, achievement_type, title, description, icon, color, target_value)
  VALUES
    (p_user_id, 'streak_7d',       '7 Day Streak',  'Keep it up!',                  'local_fire_department', '#FF6B35', 7),
    (p_user_id, 'streak_30d',      '30 Day Streak', 'Amazing consistency!',         'local_fire_department', '#FF6B35', 30),
    (p_user_id, 'first_scan',      'First Scan',    'You scanned your first meal!', 'camera_alt',            '#00D4FF', 1),
    (p_user_id, 'weight_lost_5kg', '5 kg Lost',     'Great progress!',              'scale',                 '#00D4FF', 5)
  ON CONFLICT (user_id, achievement_type) DO NOTHING;
END;
$$;

-- Asıl handle_new_user fonksiyonu
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_display_name TEXT;
BEGIN
  -- Display name'i metadata'dan al, yoksa email'den çıkar
  v_display_name := COALESCE(
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'display_name',
    split_part(NEW.email, '@', 1),
    'Nuveli User'
  );

  -- 1. Profile oluştur
  INSERT INTO public.user_profiles (user_id, display_name, onboarding_completed)
  VALUES (NEW.id, v_display_name, FALSE)
  ON CONFLICT (user_id) DO NOTHING;

  -- 2. Default habits
  PERFORM public.create_default_habits_for_user(NEW.id);

  -- 3. Default achievements (kilitli halde)
  PERFORM public.create_default_achievements_for_user(NEW.id);

  RETURN NEW;
END;
$$;

-- auth.users INSERT trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- 5. Achievement unlock kontrolü
-- =============================================================================
-- current_value >= target_value olunca is_unlocked = TRUE olur
CREATE OR REPLACE FUNCTION public.check_achievement_unlock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.target_value IS NOT NULL
     AND NEW.current_value >= NEW.target_value
     AND NEW.is_unlocked = FALSE THEN
    NEW.is_unlocked := TRUE;
    NEW.unlocked_at := NOW();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_achievement_unlock ON public.user_achievements;
CREATE TRIGGER trg_check_achievement_unlock
  BEFORE UPDATE OF current_value ON public.user_achievements
  FOR EACH ROW EXECUTE FUNCTION public.check_achievement_unlock();

COMMIT;

-- =============================================================================
-- Doğrulama (manuel):
-- SELECT tgname, tgrelid::regclass FROM pg_trigger WHERE tgname LIKE 'trg_%' ORDER BY tgname;
-- SELECT proname FROM pg_proc WHERE pronamespace = 'public'::regnamespace ORDER BY proname;
-- =============================================================================
