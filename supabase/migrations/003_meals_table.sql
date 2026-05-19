-- =============================================================================
-- Migration 003 (DÜZELTILMIŞ): meals + meal_foods tabloları
-- =============================================================================
-- DEĞIŞIKLIK: idx_meals_user_date kaldırıldı çünkü DATE(consumed_at)
--             IMMUTABLE değil (timezone-dependent). Yerine mevcut
--             (user_id, consumed_at DESC) composite B-tree index'i
--             range query'leri için zaten yeterli.
--             Query pattern: WHERE consumed_at >= date_start
--                              AND consumed_at < date_end
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- meals: öğün başlığı (kalori toplamları otomatik hesaplanır)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  name TEXT,
  total_calories INT NOT NULL DEFAULT 0 CHECK (total_calories >= 0),
  total_protein_g NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (total_protein_g >= 0),
  total_carbs_g NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (total_carbs_g >= 0),
  total_fat_g NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (total_fat_g >= 0),

  image_url TEXT,
  scan_source TEXT CHECK (scan_source IN ('ai_scan', 'manual', 'barcode', 'recipe')),
  portion_score INT CHECK (portion_score BETWEEN 0 AND 100),
  portion_insights JSONB,

  consumed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Composite (user_id, consumed_at DESC) → range query'ler için yeterli
CREATE INDEX IF NOT EXISTS idx_meals_user_consumed ON public.meals(user_id, consumed_at DESC);
CREATE INDEX IF NOT EXISTS idx_meals_user_type ON public.meals(user_id, meal_type);
CREATE INDEX IF NOT EXISTS idx_meals_scan_source ON public.meals(scan_source) WHERE scan_source = 'ai_scan';
-- KALDIRILDI: CREATE INDEX idx_meals_user_date ON meals(user_id, (DATE(consumed_at)));
--             → DATE() IMMUTABLE değil, hata veriyordu.

COMMENT ON TABLE public.meals IS 'Kullanıcının logladığı öğünler. total_* alanları meal_foods trigger ile otomatik hesaplanır.';
COMMENT ON COLUMN public.meals.portion_insights IS 'AI tarafından üretilen porsiyon notları, ör: ["High in protein", "Balanced"].';

-- -----------------------------------------------------------------------------
-- meal_foods: meal içindeki yiyecekler (1 meal = N foods)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.meal_foods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,

  name TEXT NOT NULL,
  portion TEXT,
  grams NUMERIC(6,2) CHECK (grams IS NULL OR grams >= 0),

  calories INT NOT NULL CHECK (calories >= 0),
  protein_g NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (protein_g >= 0),
  carbs_g NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (carbs_g >= 0),
  fat_g NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (fat_g >= 0),

  position INT NOT NULL DEFAULT 0,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_meal_foods_meal_id ON public.meal_foods(meal_id);
CREATE INDEX IF NOT EXISTS idx_meal_foods_meal_position ON public.meal_foods(meal_id, position);

COMMENT ON TABLE public.meal_foods IS 'Bir meal içindeki yiyecekler. Eklenince/silinince meals.total_* otomatik güncellenir (012_triggers).';

COMMIT;
