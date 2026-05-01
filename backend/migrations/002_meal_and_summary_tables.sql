-- ============================================================
-- Migration 002 — Meal & summary tables
-- Nuveli MVP · Supabase / PostgreSQL
-- ============================================================

-- ─────────────────────────────
-- meal_analysis_results
-- AI ham tahminleri — değiştirilemez audit trail
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS meal_analysis_results (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    raw_response        JSONB,
    confidence          TEXT NOT NULL DEFAULT 'failed'
                        CHECK (confidence IN ('high', 'medium', 'low', 'failed')),
    suggested_name      TEXT,
    suggested_calories  INT,
    suggested_protein_g NUMERIC(6,1),
    suggested_carb_g    NUMERIC(6,1),
    suggested_fat_g     NUMERIC(6,1),
    image_url           TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- NOT: Bu tabloda updated_at yok; kayıt değiştirilemez
);

ALTER TABLE meal_analysis_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "analysis_select_own" ON meal_analysis_results
    FOR SELECT USING (auth.uid() = user_id);

-- INSERT sadece service role (backend)


-- ─────────────────────────────
-- meal_logs
-- Kullanıcının onayladığı / düzenlediği final kayıtlar
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS meal_logs (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    local_day    DATE NOT NULL,
    meal_type    TEXT NOT NULL DEFAULT 'snack'
                 CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    name         TEXT NOT NULL,
    calories     INT NOT NULL CHECK (calories >= 0),
    protein_g    NUMERIC(6,1),
    carb_g       NUMERIC(6,1),
    fat_g        NUMERIC(6,1),
    source       TEXT NOT NULL DEFAULT 'manual'
                 CHECK (source IN ('ai_confirmed', 'ai_edited', 'manual')),
    analysis_id  UUID REFERENCES meal_analysis_results(id) ON DELETE SET NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_meal_logs_user_day ON meal_logs (user_id, local_day);

ALTER TABLE meal_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "meal_logs_select_own" ON meal_logs
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "meal_logs_insert_own" ON meal_logs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "meal_logs_update_own" ON meal_logs
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "meal_logs_delete_own" ON meal_logs
    FOR DELETE USING (auth.uid() = user_id);

CREATE TRIGGER meal_logs_updated_at
    BEFORE UPDATE ON meal_logs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────
-- daily_summaries
-- Günlük özet cache
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS daily_summaries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    local_day       DATE NOT NULL,
    total_calories  INT NOT NULL DEFAULT 0,
    total_protein_g NUMERIC(6,1) NOT NULL DEFAULT 0,
    total_carb_g    NUMERIC(6,1) NOT NULL DEFAULT 0,
    total_fat_g     NUMERIC(6,1) NOT NULL DEFAULT 0,
    water_ml        INT NOT NULL DEFAULT 0,
    weight_kg       NUMERIC(5,1),
    meal_count      INT NOT NULL DEFAULT 0,
    generated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, local_day)
);

ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "daily_summaries_select_own" ON daily_summaries
    FOR SELECT USING (auth.uid() = user_id);


-- ─────────────────────────────
-- water_logs
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS water_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    local_day   DATE NOT NULL,
    amount_ml   INT NOT NULL CHECK (amount_ml > 0),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_water_logs_user_day ON water_logs (user_id, local_day);

ALTER TABLE water_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "water_logs_own" ON water_logs
    FOR ALL USING (auth.uid() = user_id);


-- ─────────────────────────────
-- weight_logs
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS weight_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    local_day   DATE NOT NULL,
    weight_kg   NUMERIC(5,1) NOT NULL CHECK (weight_kg > 0),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, local_day)  -- günde bir kilo kaydı
);

ALTER TABLE weight_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "weight_logs_own" ON weight_logs
    FOR ALL USING (auth.uid() = user_id);


-- ─────────────────────────────
-- daily_checkins
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS daily_checkins (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    local_day   DATE NOT NULL,
    mood        TEXT NOT NULL CHECK (mood IN ('great', 'good', 'neutral', 'bad', 'rough')),
    note        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, local_day)
);

ALTER TABLE daily_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "checkins_own" ON daily_checkins
    FOR ALL USING (auth.uid() = user_id);
