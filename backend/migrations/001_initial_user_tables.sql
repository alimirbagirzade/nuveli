-- ============================================================
-- Migration 001 — Initial user tables
-- Nuveli MVP · Supabase / PostgreSQL
-- ============================================================

-- ─────────────────────────────
-- profiles
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
    id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name          TEXT,
    birth_year            INT CHECK (birth_year BETWEEN 1900 AND 2099),
    gender                TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not')),
    height_cm             NUMERIC(5,1),
    weight_kg             NUMERIC(5,1),
    goal                  TEXT CHECK (goal IN ('lose', 'maintain', 'gain')),
    activity_level        TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active')),
    daily_calorie_target  INT CHECK (daily_calorie_target >= 800),
    onboarding_completed  BOOLEAN NOT NULL DEFAULT FALSE,
    special_conditions    TEXT[] DEFAULT '{}',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_own" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_insert_own" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────
-- coach_preferences
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS coach_preferences (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    coach_persona   TEXT NOT NULL DEFAULT 'supportive'
                    CHECK (coach_persona IN ('supportive', 'motivating', 'realistic')),
    risk_mode       TEXT NOT NULL DEFAULT 'normal'
                    CHECK (risk_mode IN ('normal', 'low_intake', 'distress', 'crisis')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id)
);

ALTER TABLE coach_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coach_prefs_own" ON coach_preferences
    FOR ALL USING (auth.uid() = user_id);

CREATE TRIGGER coach_prefs_updated_at
    BEFORE UPDATE ON coach_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────
-- notification_preferences
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS notification_preferences (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    meal_reminders   BOOLEAN NOT NULL DEFAULT TRUE,
    coach_nudges     BOOLEAN NOT NULL DEFAULT TRUE,
    weekly_summary   BOOLEAN NOT NULL DEFAULT TRUE,
    quiet_start      TIME NOT NULL DEFAULT '22:00',
    quiet_end        TIME NOT NULL DEFAULT '08:00',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id)
);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notif_prefs_own" ON notification_preferences
    FOR ALL USING (auth.uid() = user_id);

CREATE TRIGGER notif_prefs_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────
-- premium_status_cache
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS premium_status_cache (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id               UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    tier                  TEXT NOT NULL DEFAULT 'free'
                          CHECK (tier IN ('free', 'trial', 'premium')),
    trial_ends_at         TIMESTAMPTZ,
    subscription_ends_at  TIMESTAMPTZ,
    rc_customer_id        TEXT,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id)
);

ALTER TABLE premium_status_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "premium_cache_select_own" ON premium_status_cache
    FOR SELECT USING (auth.uid() = user_id);

-- Sadece backend (service role) yazar; kullanıcı yazamaz
-- INSERT/UPDATE policy yok — service role bypass eder


-- ─────────────────────────────
-- usage_counters_daily
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS usage_counters_daily (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    local_day        DATE NOT NULL,
    meal_analyses    INT NOT NULL DEFAULT 0 CHECK (meal_analyses >= 0),
    coach_messages   INT NOT NULL DEFAULT 0 CHECK (coach_messages >= 0),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, local_day)
);

ALTER TABLE usage_counters_daily ENABLE ROW LEVEL SECURITY;

CREATE POLICY "usage_counters_select_own" ON usage_counters_daily
    FOR SELECT USING (auth.uid() = user_id);

-- Yazma sadece service role
CREATE TRIGGER usage_counters_updated_at
    BEFORE UPDATE ON usage_counters_daily
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────
-- device_tokens (push)
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS device_tokens (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    token        TEXT NOT NULL,
    platform     TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (token)
);

ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "device_tokens_own" ON device_tokens
    FOR ALL USING (auth.uid() = user_id);
