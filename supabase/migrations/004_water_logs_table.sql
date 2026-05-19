-- =============================================================================
-- Migration 004 (DÜZELTILMIŞ): water_logs + water_reminders tabloları
-- =============================================================================
-- DEĞIŞIKLIK: idx_water_logs_user_date kaldırıldı çünkü DATE(logged_at)
--             IMMUTABLE değil. (user_id, logged_at DESC) yeterli.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- water_logs: her su içme olayı (250ml, 500ml gibi)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.water_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  amount_ml INT NOT NULL CHECK (amount_ml > 0 AND amount_ml <= 5000),
  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  source TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'quick_add', 'reminder')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- (user_id, logged_at DESC) → range query'ler için yeterli
CREATE INDEX IF NOT EXISTS idx_water_logs_user_time ON public.water_logs(user_id, logged_at DESC);
-- KALDIRILDI: CREATE INDEX idx_water_logs_user_date ON water_logs(user_id, (DATE(logged_at)));

COMMENT ON TABLE public.water_logs IS 'Her su içme kaydı. Günlük toplam SUM(amount_ml) ile hesaplanır.';
COMMENT ON COLUMN public.water_logs.source IS 'manual=elle giriş, quick_add=+250/+500/+1000 butonu, reminder=hatırlatıcı sonrası';

-- -----------------------------------------------------------------------------
-- water_reminders: günlük su hatırlatıcı ayarları
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.water_reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  label TEXT NOT NULL,
  reminder_time TIME NOT NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT TRUE,

  days_of_week TEXT[] NOT NULL DEFAULT ARRAY['mon','tue','wed','thu','fri','sat','sun'],

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_days_of_week_valid CHECK (
    days_of_week <@ ARRAY['mon','tue','wed','thu','fri','sat','sun']
  )
);

CREATE INDEX IF NOT EXISTS idx_water_reminders_user ON public.water_reminders(user_id) WHERE is_enabled = TRUE;
CREATE INDEX IF NOT EXISTS idx_water_reminders_time ON public.water_reminders(reminder_time) WHERE is_enabled = TRUE;

COMMENT ON TABLE public.water_reminders IS 'Local notification tarafından okunan saat tabanlı hatırlatıcılar.';

COMMIT;
