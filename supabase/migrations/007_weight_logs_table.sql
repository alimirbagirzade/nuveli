-- =============================================================================
-- Migration 007: weight_logs + weight_goals tabloları
-- =============================================================================
-- Amaç: Kilo takibi ve aktif kilo hedefleri.
-- İlişki: user (1) ──< weight_logs (günde 1), user (1) ──< weight_goals (1 aktif)
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- weight_logs: kilo ölçüm kayıtları
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  weight_kg NUMERIC(5,2) NOT NULL CHECK (weight_kg > 0 AND weight_kg < 500),
  logged_at DATE NOT NULL DEFAULT CURRENT_DATE,

  notes TEXT,
  source TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'health_app', 'smart_scale')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Aynı gün 1 kayıt
  UNIQUE(user_id, logged_at)
);

CREATE INDEX IF NOT EXISTS idx_weight_logs_user_date ON public.weight_logs(user_id, logged_at DESC);

COMMENT ON TABLE public.weight_logs IS 'Günlük kilo kayıtları. UNIQUE(user_id, logged_at) → aynı gün 1 kayıt. Analytics trend grafiği bu tablodan beslenir.';

-- -----------------------------------------------------------------------------
-- weight_goals: aktif/geçmiş kilo hedefleri
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.weight_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  start_weight_kg NUMERIC(5,2) NOT NULL CHECK (start_weight_kg > 0),
  target_weight_kg NUMERIC(5,2) NOT NULL CHECK (target_weight_kg > 0),
  target_date DATE,

  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  achieved_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_weight_goals_user ON public.weight_goals(user_id);

-- Bir kullanıcının sadece 1 aktif weight goal'u olabilir
CREATE UNIQUE INDEX IF NOT EXISTS idx_weight_goals_one_active
  ON public.weight_goals(user_id)
  WHERE is_active = TRUE;

COMMENT ON TABLE public.weight_goals IS 'Kilo hedefleri. Bir kullanıcının aynı anda yalnızca 1 aktif hedefi olabilir (partial unique index).';

COMMIT;
