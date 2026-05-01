-- ============================================================
-- Migration 003 — Coach tables
-- Nuveli MVP · Supabase / PostgreSQL
-- ============================================================

-- ─────────────────────────────
-- coach_threads
-- Her kullanıcının koç konuşma thread'i
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS coach_threads (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id)  -- her kullanıcının tek thread'i
);

ALTER TABLE coach_threads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coach_threads_own" ON coach_threads
    FOR ALL USING (auth.uid() = user_id);

CREATE TRIGGER coach_threads_updated_at
    BEFORE UPDATE ON coach_threads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────
-- coach_messages
-- Koç konuşma mesajları
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS coach_messages (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id    UUID NOT NULL REFERENCES coach_threads(id) ON DELETE CASCADE,
    user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role         TEXT NOT NULL CHECK (role IN ('user', 'coach')),
    content      TEXT NOT NULL,
    audio_url    TEXT,   -- TTS audio (coach mesajları için)
    is_fallback  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_coach_messages_thread ON coach_messages (thread_id, created_at DESC);

ALTER TABLE coach_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coach_messages_own" ON coach_messages
    FOR ALL USING (auth.uid() = user_id);


-- ─────────────────────────────
-- safety_acknowledgements
-- Kullanıcının safety mesajını gördüğünü teyit eder
-- ─────────────────────────────
CREATE TABLE IF NOT EXISTS safety_acknowledgements (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    risk_level     TEXT NOT NULL,
    acknowledged_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- NOT: user_id intentionally not unique — her event ayrı satır
);

ALTER TABLE safety_acknowledgements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "safety_ack_own" ON safety_acknowledgements
    FOR ALL USING (auth.uid() = user_id);
