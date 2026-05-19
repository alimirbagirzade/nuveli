-- =============================================================================
-- Migration 008: ai_insights tablosu
-- =============================================================================
-- Amaç: GPT-4o tarafından her sabah üretilen günlük insight'lar.
-- Chat 11'den geliyor — Chat 14'teki cron job bu tabloyu doldurur.
-- Frontend (AI Coach ekranı) günlük 1 kayıt okur, re-fetch yapmaz (cost optim).
-- =============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.ai_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  insight_date DATE NOT NULL DEFAULT CURRENT_DATE,

  -- Nutrition Score
  nutrition_score INT CHECK (nutrition_score IS NULL OR nutrition_score BETWEEN 0 AND 100),
  score_label TEXT,                          -- "Great", "Good", "Needs work"
  score_breakdown JSONB,                     -- {calorie_adherence:35, macro_balance:25, hydration:12, habits:14}

  -- AI üretilen içerikler (NOT NULL — boş insight olmaz)
  main_insight JSONB NOT NULL,               -- {headline, supporting_text, tone}
  small_insights JSONB NOT NULL,             -- [{headline, supporting_text, category}, ...4]
  recommendation JSONB NOT NULL,             -- {title, description, category, applied, apply_tip_data}
  daily_recap JSONB NOT NULL,                -- {status, message}

  -- Meta
  ai_model TEXT NOT NULL DEFAULT 'gpt-4o',
  tokens_used INT CHECK (tokens_used IS NULL OR tokens_used >= 0),
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Bir kullanıcı için günde 1 insight (UPSERT pattern ile yeniden oluşturulabilir)
  UNIQUE(user_id, insight_date)
);

CREATE INDEX IF NOT EXISTS idx_ai_insights_user_date ON public.ai_insights(user_id, insight_date DESC);
CREATE INDEX IF NOT EXISTS idx_ai_insights_date ON public.ai_insights(insight_date DESC);

COMMENT ON TABLE public.ai_insights IS 'Günlük AI insight cache. Cron job (Chat 14) her sabah 06:00 doldurur. Frontend bu tabloyu okur.';
COMMENT ON COLUMN public.ai_insights.main_insight IS 'Ana büyük insight kartı: {headline, supporting_text, tone:"motivational|warning|celebration"}';
COMMENT ON COLUMN public.ai_insights.small_insights IS '4 adet küçük insight kartı array''i.';
COMMENT ON COLUMN public.ai_insights.recommendation IS 'Recommended Action kartı. apply_tip_data alanı "Apply Tip" butonuyla işlenir.';

COMMIT;
