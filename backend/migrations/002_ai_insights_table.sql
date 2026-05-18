-- =============================================================================
-- Nuveli — Migration 002: ai_insights tablosu
-- Chat 11b: AI Coach Backend
--
-- Kullanım:
--   1. Supabase Dashboard → SQL Editor
--   2. Bu dosyanın içeriğini yapıştır → Run
--   3. Tablonun oluştuğunu Table Editor'da doğrula
--
-- Veya CLI ile:
--   npx supabase db push
-- =============================================================================

-- Önce eski versiyonu temizle (rollback için gerekirse)
-- DROP TABLE IF EXISTS public.ai_insights CASCADE;

CREATE TABLE IF NOT EXISTS public.ai_insights (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date            DATE        NOT NULL,

    -- Algoritma çıktısı (calculate_nutrition_score sonucu)
    -- { "value": 86, "label": "Great", "breakdown": {...} }
    nutrition_score JSONB       NOT NULL,

    -- GPT-4o çıktısı parçaları
    main_insight    JSONB       NOT NULL,   -- {headline, supporting_text, tone}
    small_insights  JSONB       NOT NULL,   -- [{category, headline, supporting_text}, x4]
    recommendation  JSONB       NOT NULL,   -- {title, description, category}
    daily_recap     JSONB       NOT NULL,   -- {status, message}

    -- Metadata
    model_version   TEXT        DEFAULT 'gpt-4o',
    generated_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),

    -- Aynı kullanıcı için aynı günde sadece tek kayıt
    CONSTRAINT ai_insights_user_date_unique UNIQUE (user_id, date)
);

-- =============================================================================
-- INDEX'LER
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_ai_insights_user_date
    ON public.ai_insights (user_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_ai_insights_generated_at
    ON public.ai_insights (generated_at DESC);

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
ALTER TABLE public.ai_insights ENABLE ROW LEVEL SECURITY;

-- Kullanıcı sadece kendi insights'ını okuyabilir
DROP POLICY IF EXISTS "ai_insights_select_own" ON public.ai_insights;
CREATE POLICY "ai_insights_select_own"
    ON public.ai_insights
    FOR SELECT
    USING (auth.uid() = user_id);

-- Service role her şeyi yapar (backend cron + endpoint için)
-- service_role JWT'si RLS bypass eder ama yine de explicit policy güvenli.
DROP POLICY IF EXISTS "ai_insights_service_role_all" ON public.ai_insights;
CREATE POLICY "ai_insights_service_role_all"
    ON public.ai_insights
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- =============================================================================
-- UPDATED_AT TRIGGER
-- =============================================================================
CREATE OR REPLACE FUNCTION public.set_ai_insights_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ai_insights_updated_at ON public.ai_insights;
CREATE TRIGGER trg_ai_insights_updated_at
    BEFORE UPDATE ON public.ai_insights
    FOR EACH ROW
    EXECUTE FUNCTION public.set_ai_insights_updated_at();

-- =============================================================================
-- COMMENT'LER (Dashboard'da kolonların ne işe yaradığı görünür)
-- =============================================================================
COMMENT ON TABLE public.ai_insights IS
    'Günlük AI Coach insights cache''i — GPT-4o tarafından üretilen kişisel öneriler.';

COMMENT ON COLUMN public.ai_insights.nutrition_score IS
    'calculate_nutrition_score() çıktısı. {value:0-100, label, breakdown:{calorie_adherence, macro_balance, hydration, habits_completion}}';

COMMENT ON COLUMN public.ai_insights.main_insight IS
    'Üst büyük insight kartı. {headline, supporting_text, tone}';

COMMENT ON COLUMN public.ai_insights.small_insights IS
    '2x2 grid için 4 küçük insight. [{category, headline, supporting_text}, ...]';

COMMENT ON COLUMN public.ai_insights.recommendation IS
    'Recommended For You kartı. {title, description, category}';

COMMENT ON COLUMN public.ai_insights.daily_recap IS
    'Daily Recap kartı. {status: onTrack|behind|ahead, message}';

-- =============================================================================
-- DOĞRULAMA SORGULARI (Manuel test için)
-- =============================================================================
-- SELECT * FROM public.ai_insights ORDER BY generated_at DESC LIMIT 5;
-- SELECT user_id, date, nutrition_score->>'value' AS score FROM public.ai_insights;
