-- =============================================================================
-- Migration 006: recipes + meal_plans tabloları
-- =============================================================================
-- Amaç: Sistem/kullanıcı tarifleri ve haftalık öğün planları.
-- İlişki: recipes (1) ──< meal_plans (kullanılan tarif)
--         meal_plans ──> meals (tamamlandığında bağlı meal log)
-- Özel: recipes hem public (is_public=TRUE) hem private olabilir.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- recipes: tarif kütüphanesi (sistem + kullanıcı)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- user_id NULL ise sistem tarifi (is_public TRUE olmalı)
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_public BOOLEAN NOT NULL DEFAULT FALSE,

  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,

  -- Beslenme bilgileri
  calories INT NOT NULL CHECK (calories >= 0),
  protein_g NUMERIC(6,2) CHECK (protein_g IS NULL OR protein_g >= 0),
  carbs_g NUMERIC(6,2) CHECK (carbs_g IS NULL OR carbs_g >= 0),
  fat_g NUMERIC(6,2) CHECK (fat_g IS NULL OR fat_g >= 0),
  servings INT NOT NULL DEFAULT 1 CHECK (servings > 0),

  -- Tarif detayları (JSONB)
  ingredients JSONB,    -- [{"name":"Oats","amount":50,"unit":"g"}, ...]
  instructions JSONB,   -- ["Step 1...", "Step 2...", ...]
  prep_time_min INT CHECK (prep_time_min IS NULL OR prep_time_min >= 0),
  cook_time_min INT CHECK (cook_time_min IS NULL OR cook_time_min >= 0),

  -- Kategoriler
  meal_types TEXT[] NOT NULL DEFAULT ARRAY['breakfast'],
  tags TEXT[],
  difficulty TEXT CHECK (difficulty IS NULL OR difficulty IN ('easy', 'medium', 'hard')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Sistem tarifi (user_id NULL) zorunlu olarak public olmalı
  CONSTRAINT chk_system_recipe_public CHECK (
    user_id IS NOT NULL OR is_public = TRUE
  ),

  -- meal_types geçerli değerlerden oluşmalı
  CONSTRAINT chk_meal_types_valid CHECK (
    meal_types <@ ARRAY['breakfast', 'lunch', 'dinner', 'snack']
  )
);

CREATE INDEX IF NOT EXISTS idx_recipes_user ON public.recipes(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_recipes_public ON public.recipes(is_public) WHERE is_public = TRUE;
CREATE INDEX IF NOT EXISTS idx_recipes_meal_types ON public.recipes USING GIN(meal_types);
CREATE INDEX IF NOT EXISTS idx_recipes_tags ON public.recipes USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_recipes_name_trgm ON public.recipes USING GIN(name gin_trgm_ops);

COMMENT ON TABLE public.recipes IS 'Tarif kütüphanesi. user_id NULL ise sistem tarifi (herkes görür).';
COMMENT ON COLUMN public.recipes.ingredients IS 'JSONB array: [{"name":"...","amount":...,"unit":"g|ml|piece"}, ...]';

-- -----------------------------------------------------------------------------
-- meal_plans: haftalık planlanmış öğünler
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.meal_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  plan_date DATE NOT NULL,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),

  -- Bir tarif kullan VEYA custom plan
  recipe_id UUID REFERENCES public.recipes(id) ON DELETE SET NULL,
  custom_meal_name TEXT,
  custom_calories INT CHECK (custom_calories IS NULL OR custom_calories >= 0),

  -- Tamamlanma takibi
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_meal_id UUID REFERENCES public.meals(id) ON DELETE SET NULL,

  notes TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Bir gün için her meal_type'tan 1 plan
  UNIQUE(user_id, plan_date, meal_type),

  -- Ya recipe_id ya custom_meal_name olmalı
  CONSTRAINT chk_plan_has_content CHECK (
    recipe_id IS NOT NULL OR custom_meal_name IS NOT NULL
  )
);

CREATE INDEX IF NOT EXISTS idx_meal_plans_user_date ON public.meal_plans(user_id, plan_date);
CREATE INDEX IF NOT EXISTS idx_meal_plans_recipe ON public.meal_plans(recipe_id) WHERE recipe_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_meal_plans_pending ON public.meal_plans(user_id, plan_date) WHERE is_completed = FALSE;

COMMENT ON TABLE public.meal_plans IS 'Haftalık planlanmış öğünler. plan_date + meal_type unique olduğundan aynı gün 4 öğün max.';

COMMIT;
