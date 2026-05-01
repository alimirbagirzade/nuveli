-- ============================================================
-- Migration 005 — Notification logs
-- Günlük push limit kontrolü için
-- ============================================================

CREATE TABLE IF NOT EXISTS notification_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    category        TEXT NOT NULL,
    title           TEXT NOT NULL,
    body            TEXT NOT NULL,
    data            JSONB DEFAULT '{}',
    device_count    INT NOT NULL DEFAULT 0,
    sent_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notification_logs_user_date
    ON notification_logs (user_id, sent_at DESC);

CREATE INDEX idx_notification_logs_daily_count
    ON notification_logs (user_id, sent_at)
    WHERE sent_at > NOW() - INTERVAL '24 hours';

-- RLS — kullanıcı kendi loglarını okuyabilir
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notification_logs_select_own" ON notification_logs
    FOR SELECT USING (auth.uid() = user_id);
