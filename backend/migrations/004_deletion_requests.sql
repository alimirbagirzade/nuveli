-- ============================================================
-- Migration 004 — Deletion requests table
-- KVKK m.11 uyumlu hesap silme için
-- ============================================================

CREATE TABLE IF NOT EXISTS deletion_requests (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    requested_at    DATE NOT NULL DEFAULT CURRENT_DATE,
    scheduled_for   DATE NOT NULL,
    status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'cancelled', 'completed')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id)
);

CREATE INDEX idx_deletion_requests_scheduled
    ON deletion_requests (status, scheduled_for)
    WHERE status = 'pending';

-- RLS: Kullanıcı sadece kendi isteğini görür
ALTER TABLE deletion_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "deletion_requests_select_own" ON deletion_requests
    FOR SELECT USING (auth.uid() = user_id);

-- INSERT/UPDATE yalnızca service role (backend)
-- RLS policy yok = bypass service role

CREATE TRIGGER deletion_requests_updated_at
    BEFORE UPDATE ON deletion_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
