-- =============================================================================
-- Migration 005: habits + habit_completions tabloları
-- =============================================================================
-- Amaç: Sağlıklı alışkanlık tanımları ve günlük tamamlama kayıtları.
-- İlişki: user (1) ──< habits (1) ──< habit_completions
-- Önemli: completion günde 1 kez (UNIQUE constraint).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- habits: kullanıcının takip ettiği alışkanlıklar
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Habit bilgileri
  habit_type TEXT NOT NULL CHECK (habit_type IN ('meal', 'hydration', 'exercise', 'protein', 'sleep', 'custom')),
  title TEXT NOT NULL,
  subtitle TEXT,
  icon TEXT,
  icon_color TEXT,

  -- Hedef tipi
  target_type TEXT NOT NULL DEFAULT 'check' CHECK (target_type IN ('check', 'count', 'duration', 'value')),
  target_value INT CHECK (target_value IS NULL OR target_value > 0),
  target_unit TEXT,

  -- Schedule
  schedule_type TEXT NOT NULL DEFAULT 'daily' CHECK (schedule_type IN ('daily', 'weekly', 'custom')),
  days_of_week TEXT[] NOT NULL DEFAULT ARRAY['mon','tue','wed','thu','fri','sat','sun'],

  -- Otomatik tamamlama kuralı (ör: 'water_target_reached')
  auto_complete_rule TEXT,

  -- Sıralama ve durum
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_habit_days_valid CHECK (
    days_of_week <@ ARRAY['mon','tue','wed','thu','fri','sat','sun']
  )
);

CREATE INDEX IF NOT EXISTS idx_habits_user_active ON public.habits(user_id, display_order) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_habits_user_type ON public.habits(user_id, habit_type);

COMMENT ON TABLE public.habits IS 'Kullanıcının takip ettiği alışkanlık tanımları. Default 5 habit signup trigger ile eklenir.';
COMMENT ON COLUMN public.habits.auto_complete_rule IS 'Backend tarafından okunur. Ör: water_target_reached → water_logs SUM hedef >= ise habit otomatik complete.';

-- -----------------------------------------------------------------------------
-- habit_completions: günlük tamamlama kayıtları
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.habit_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  completion_date DATE NOT NULL DEFAULT CURRENT_DATE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  value INT CHECK (value IS NULL OR value >= 0),
  notes TEXT,

  -- Aynı habit aynı gün 1 kez tamamlanabilir
  UNIQUE(habit_id, completion_date)
);

CREATE INDEX IF NOT EXISTS idx_habit_completions_user_date ON public.habit_completions(user_id, completion_date DESC);
CREATE INDEX IF NOT EXISTS idx_habit_completions_habit_date ON public.habit_completions(habit_id, completion_date DESC);

COMMENT ON TABLE public.habit_completions IS 'Günlük habit tamamlama kayıtları. UNIQUE(habit_id, completion_date) ile günde 1 kayıt garantili.';

COMMIT;
