-- =============================================================================
-- Migration 009: user_achievements tablosu
-- =============================================================================
-- Amaç: Kullanıcı başarımları (streak, first scan, weight milestone vs).
-- Her kullanıcıya signup'ta default achievements LOCKED olarak verilir.
-- Cron job veya event-based trigger ile current_value güncellenir.
-- =============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  achievement_type TEXT NOT NULL,            -- 'streak_7d', 'first_scan', 'weight_lost_5kg', etc.
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT,

  -- İlerleme (tier'lı achievement'lar için)
  current_value INT NOT NULL DEFAULT 0 CHECK (current_value >= 0),
  target_value INT CHECK (target_value IS NULL OR target_value > 0),

  is_unlocked BOOLEAN NOT NULL DEFAULT FALSE,
  unlocked_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Bir kullanıcının aynı tipteki achievement'tan 1 kaydı olur
  UNIQUE(user_id, achievement_type)
);

CREATE INDEX IF NOT EXISTS idx_achievements_user_unlocked ON public.user_achievements(user_id, unlocked_at DESC) WHERE is_unlocked = TRUE;
CREATE INDEX IF NOT EXISTS idx_achievements_user_type ON public.user_achievements(user_id, achievement_type);

COMMENT ON TABLE public.user_achievements IS 'Kullanıcı başarımları. Default 4 achievement signup trigger ile kilitli halde eklenir, current_value >= target_value olunca trigger ile unlock olur.';

COMMIT;
