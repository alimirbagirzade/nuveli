-- =============================================================================
-- Migration 013: Seed data
-- =============================================================================
-- İçerik:
--   1. Public (sistem) recipe'leri — herkes görebilir
--   2. Backfill fonksiyonu — mevcut kullanıcılara default habit/achievement ekler
--      (trigger sonradan eklendiyse eski kullanıcılar boşta kalmasın diye)
-- Not: create_default_habits_for_user ve create_default_achievements_for_user
--      fonksiyonları 012_triggers.sql'de tanımlandı. Burada tekrar etmiyoruz.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1. Public recipes (sistem tarifleri)
--    user_id NULL → herkes görür (RLS policy: is_public=TRUE OR auth.uid()=user_id)
-- -----------------------------------------------------------------------------
-- Idempotent: aynı name ile zaten varsa atla
INSERT INTO public.recipes
  (user_id, is_public, name, description, calories, protein_g, carbs_g, fat_g, servings, meal_types, tags, difficulty, prep_time_min, cook_time_min, ingredients, instructions)
SELECT * FROM (VALUES
  (
    NULL::UUID, TRUE,
    'Greek Yogurt Bowl',
    'Protein-packed breakfast with berries and honey.',
    350, 18.0::NUMERIC, 42.0::NUMERIC, 12.0::NUMERIC, 1,
    ARRAY['breakfast']::TEXT[],
    ARRAY['high-protein','quick','vegetarian']::TEXT[],
    'easy', 5, 0,
    '[{"name":"Greek yogurt","amount":200,"unit":"g"},{"name":"Mixed berries","amount":80,"unit":"g"},{"name":"Honey","amount":15,"unit":"g"},{"name":"Granola","amount":30,"unit":"g"}]'::JSONB,
    '["Add yogurt to a bowl","Top with berries and granola","Drizzle honey on top"]'::JSONB
  ),
  (
    NULL::UUID, TRUE,
    'Grilled Chicken Salad',
    'Light yet filling lunch with grilled chicken breast.',
    520, 42.0::NUMERIC, 28.0::NUMERIC, 22.0::NUMERIC, 1,
    ARRAY['lunch']::TEXT[],
    ARRAY['high-protein','low-carb']::TEXT[],
    'easy', 10, 12,
    '[{"name":"Chicken breast","amount":150,"unit":"g"},{"name":"Mixed greens","amount":100,"unit":"g"},{"name":"Cherry tomatoes","amount":80,"unit":"g"},{"name":"Olive oil","amount":15,"unit":"ml"},{"name":"Lemon juice","amount":10,"unit":"ml"}]'::JSONB,
    '["Season and grill the chicken until cooked through","Toss greens and tomatoes in a bowl","Slice chicken on top, dress with olive oil and lemon"]'::JSONB
  ),
  (
    NULL::UUID, TRUE,
    'Salmon & Quinoa',
    'Balanced dinner rich in omega-3 and complex carbs.',
    610, 35.0::NUMERIC, 90.0::NUMERIC, 14.0::NUMERIC, 1,
    ARRAY['dinner']::TEXT[],
    ARRAY['balanced','omega-3']::TEXT[],
    'medium', 10, 25,
    '[{"name":"Salmon fillet","amount":150,"unit":"g"},{"name":"Quinoa","amount":80,"unit":"g"},{"name":"Steamed broccoli","amount":100,"unit":"g"},{"name":"Olive oil","amount":10,"unit":"ml"}]'::JSONB,
    '["Cook quinoa per package instructions","Pan-sear or bake salmon 10-12 min","Steam broccoli 5 min","Plate and drizzle with olive oil"]'::JSONB
  ),
  (
    NULL::UUID, TRUE,
    'Overnight Oats',
    'Make-ahead breakfast with oats, milk and fruit.',
    310, 12.0::NUMERIC, 48.0::NUMERIC, 8.0::NUMERIC, 1,
    ARRAY['breakfast']::TEXT[],
    ARRAY['vegetarian','quick','make-ahead']::TEXT[],
    'easy', 5, 0,
    '[{"name":"Rolled oats","amount":50,"unit":"g"},{"name":"Milk","amount":200,"unit":"ml"},{"name":"Banana","amount":1,"unit":"piece"},{"name":"Chia seeds","amount":10,"unit":"g"}]'::JSONB,
    '["Mix oats, milk and chia in a jar","Refrigerate overnight","Top with sliced banana in the morning"]'::JSONB
  ),
  (
    NULL::UUID, TRUE,
    'Mixed Nuts Snack',
    'Quick energy snack between meals.',
    180, 6.0::NUMERIC, 8.0::NUMERIC, 14.0::NUMERIC, 1,
    ARRAY['snack']::TEXT[],
    ARRAY['quick','high-fat','vegan']::TEXT[],
    'easy', 1, 0,
    '[{"name":"Almonds","amount":15,"unit":"g"},{"name":"Cashews","amount":10,"unit":"g"},{"name":"Walnuts","amount":10,"unit":"g"}]'::JSONB,
    '["Combine in a small bowl or bag"]'::JSONB
  )
) AS v(user_id, is_public, name, description, calories, protein_g, carbs_g, fat_g, servings, meal_types, tags, difficulty, prep_time_min, cook_time_min, ingredients, instructions)
WHERE NOT EXISTS (
  SELECT 1 FROM public.recipes r WHERE r.is_public = TRUE AND r.name = v.name
);

-- -----------------------------------------------------------------------------
-- 2. Backfill: mevcut kullanıcılara default habits ve achievements ekle
--    (Trigger sonradan eklendiyse, önceki user'lar için bir kerelik çalıştır)
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_user RECORD;
BEGIN
  FOR v_user IN SELECT id FROM auth.users LOOP
    -- Profile yoksa oluştur (handle_new_user trigger benzeri)
    INSERT INTO public.user_profiles (user_id, display_name, onboarding_completed)
    SELECT v_user.id,
           COALESCE(
             (SELECT raw_user_meta_data->>'name' FROM auth.users WHERE id = v_user.id),
             split_part((SELECT email FROM auth.users WHERE id = v_user.id), '@', 1),
             'Nuveli User'
           ),
           FALSE
    WHERE NOT EXISTS (
      SELECT 1 FROM public.user_profiles WHERE user_id = v_user.id
    );

    -- Default habits (idempotent)
    PERFORM public.create_default_habits_for_user(v_user.id);

    -- Default achievements (idempotent)
    PERFORM public.create_default_achievements_for_user(v_user.id);
  END LOOP;
END;
$$;

COMMIT;

-- =============================================================================
-- Doğrulama:
-- SELECT name, is_public, calories FROM public.recipes WHERE is_public = TRUE;
-- SELECT user_id, COUNT(*) AS habit_count FROM public.habits GROUP BY user_id;
-- SELECT user_id, COUNT(*) AS achievement_count FROM public.user_achievements GROUP BY user_id;
-- =============================================================================
