-- 010_premium_and_usage_tables.sql
-- Nuveli MVP — Premium ve Usage tabloları
-- PRD §9.4 Veri Modeli'ne göre eksik tablolar

-- ═══════════════════════════════════════════════════════════════
-- premium_status_cache
-- RevenueCat'ten gelen premium durumu hızlı okuma için cache.
-- Source of truth her zaman RevenueCat/store; bu sadece performans.
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS premium_status_cache (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 'free' | 'trial' | 'premium' | 'expired'
  status TEXT NOT NULL DEFAULT 'free'
    CHECK (status IN ('free', 'trial', 'premium', 'expired')),

  -- RevenueCat customer info
  rc_customer_id TEXT,
  entitlement_id TEXT,
  product_id TEXT,

  -- Trial / subscription periods
  trial_started_at TIMESTAMPTZ,
  trial_ends_at TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,

  -- Day 2 trial gift için (PRD §6.4)
  day2_gift_offered_at TIMESTAMPTZ,
  day2_gift_claimed_at TIMESTAMPTZ,

  -- Cache senkron metadata
  last_synced_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  raw_payload JSONB,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_premium_status_active
  ON premium_status_cache(status)
  WHERE status IN ('trial', 'premium');

ALTER TABLE premium_status_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users read own premium status"
  ON premium_status_cache FOR SELECT
  USING (auth.uid() = user_id);

-- service_role tüm işlemleri yapabilir; user sadece read.

-- ═══════════════════════════════════════════════════════════════
-- usage_counters_daily
-- Feature gating limitleri (PRD §4.3)
-- 1/gün foto, 3/gün koç (free), 10/gün foto + 30/gün koç (premium)
-- Sayaç user timezone'a göre sıfırlanır.
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS usage_counters_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Local date (kullanıcının timezone'unda)
  usage_date DATE NOT NULL,

  -- Feature key
  feature TEXT NOT NULL
    CHECK (feature IN ('meal_photo_analysis', 'coach_text_response', 'coach_voice_response')),

  count INTEGER NOT NULL DEFAULT 0,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(user_id, usage_date, feature)
);

CREATE INDEX IF NOT EXISTS idx_usage_counters_user_date
  ON usage_counters_daily(user_id, usage_date);

ALTER TABLE usage_counters_daily ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users read own usage"
  ON usage_counters_daily FOR SELECT
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- device_push_tokens
-- FCM token kayıt (PRD §9.4)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS device_push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  fcm_token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),

  -- Bildirim opt-in state
  notifications_enabled BOOLEAN NOT NULL DEFAULT true,

  -- Multi-device: kullanıcının birden fazla cihazı olabilir
  device_id TEXT,
  device_model TEXT,
  app_version TEXT,
  os_version TEXT,

  last_active_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Aynı kullanıcı + token kombinasyonu unique
  UNIQUE(user_id, fcm_token)
);

CREATE INDEX IF NOT EXISTS idx_push_tokens_user
  ON device_push_tokens(user_id)
  WHERE notifications_enabled = true;

ALTER TABLE device_push_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users manage own push tokens"
  ON device_push_tokens FOR ALL
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- notification_preferences
-- Kullanıcı bildirim tercihleri (PRD §6.2)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Kategori bazlı opt-in
  meal_reminders BOOLEAN NOT NULL DEFAULT true,
  water_reminders BOOLEAN NOT NULL DEFAULT true,
  weekly_summary BOOLEAN NOT NULL DEFAULT true,
  celebrations BOOLEAN NOT NULL DEFAULT true,
  coach_messages BOOLEAN NOT NULL DEFAULT true,
  empty_day_nudge BOOLEAN NOT NULL DEFAULT true,

  -- Sessiz saatler (PRD §6.2: 22:30-08:00)
  quiet_hours_start TIME NOT NULL DEFAULT '22:30:00',
  quiet_hours_end TIME NOT NULL DEFAULT '08:00:00',

  -- Yoğunluk modu
  intensity TEXT NOT NULL DEFAULT 'light'
    CHECK (intensity IN ('light', 'standard', 'minimal')),

  timezone TEXT NOT NULL DEFAULT 'Europe/Istanbul',

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users manage own notification prefs"
  ON notification_preferences FOR ALL
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- updated_at trigger function (varsa atla)
-- ═══════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_premium_status_updated ON premium_status_cache;
CREATE TRIGGER trg_premium_status_updated
  BEFORE UPDATE ON premium_status_cache
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_usage_counters_updated ON usage_counters_daily;
CREATE TRIGGER trg_usage_counters_updated
  BEFORE UPDATE ON usage_counters_daily
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_push_tokens_updated ON device_push_tokens;
CREATE TRIGGER trg_push_tokens_updated
  BEFORE UPDATE ON device_push_tokens
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_notif_prefs_updated ON notification_preferences;
CREATE TRIGGER trg_notif_prefs_updated
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
