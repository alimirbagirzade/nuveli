-- ============================================================
-- Chat 19 Migration: subscription_events + user_profiles premium fields
-- ============================================================
-- Dosya: supabase/migrations/019_subscription_events.sql
--
-- Apply:
--   supabase db push
--   veya:
--   psql $DATABASE_URL -f supabase/migrations/019_subscription_events.sql
-- ============================================================

-- ============================================================
-- 1. user_profiles tablosuna premium kolonları ekle
-- ============================================================
-- Chat 13'te user_profiles tablosu zaten oluştu. Sadece premium
-- alanları ekleyelim. Kolon zaten varsa IF NOT EXISTS sayesinde
-- migration idempotent.

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS is_premium boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_expires_at timestamptz,
  ADD COLUMN IF NOT EXISTS premium_product_id text,
  ADD COLUMN IF NOT EXISTS premium_platform text
    CHECK (premium_platform IN ('app_store', 'play_store', 'stripe', NULL)),
  ADD COLUMN IF NOT EXISTS premium_updated_at timestamptz;

COMMENT ON COLUMN public.user_profiles.is_premium IS
  'Cache of current premium status. Source of truth = RevenueCat. Updated via webhook.';
COMMENT ON COLUMN public.user_profiles.premium_expires_at IS
  'When subscription will renew/expire. NULL for lifetime or non-premium.';
COMMENT ON COLUMN public.user_profiles.premium_product_id IS
  'Apple/Google product ID (e.g. com.nuveli.premium.annual).';

-- ============================================================
-- 2. subscription_events — Webhook audit log
-- ============================================================
-- RC her event'i (purchase, renewal, cancel, refund) buraya kaydeder.
-- Hem audit hem de troubleshooting için.

CREATE TABLE IF NOT EXISTS public.subscription_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Webhook bilgileri
  rc_event_id text UNIQUE,        -- RC'nin gönderdiği unique event id (dedup için)
  event_type text NOT NULL,       -- INITIAL_PURCHASE / RENEWAL / CANCELLATION / ...
  rc_app_user_id text NOT NULL,   -- RC'deki user_id (Supabase user_id ile eşleşir)

  -- User referansı (NULL olabilir, anonymous purchase olduysa)
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,

  -- Subscription detayları
  product_id text,                -- com.nuveli.premium.annual
  entitlement_id text,            -- "premium"
  platform text                   -- app_store / play_store
    CHECK (platform IN ('app_store', 'play_store', 'stripe', NULL)),
  store text,                     -- APP_STORE / PLAY_STORE (RC'nin verdiği)

  -- Fiyat / para
  price_in_purchased_currency numeric(10, 2),
  currency text,

  -- Zamanlama
  purchased_at_ms bigint,         -- ms epoch (RC'den)
  expiration_at_ms bigint,        -- ms epoch
  event_timestamp_ms bigint,      -- event'in ne zaman gerçekleştiği
  received_at timestamptz NOT NULL DEFAULT now(),

  -- Raw payload (debug için)
  raw_payload jsonb,

  -- Flag'ler
  is_trial_period boolean DEFAULT false,
  is_sandbox boolean DEFAULT false,
  is_processed boolean DEFAULT false,
  processed_at timestamptz,
  processing_error text
);

CREATE INDEX IF NOT EXISTS idx_subscription_events_user
  ON public.subscription_events (user_id, received_at DESC);
CREATE INDEX IF NOT EXISTS idx_subscription_events_rc_user
  ON public.subscription_events (rc_app_user_id, received_at DESC);
CREATE INDEX IF NOT EXISTS idx_subscription_events_unprocessed
  ON public.subscription_events (is_processed, received_at)
  WHERE is_processed = false;
CREATE INDEX IF NOT EXISTS idx_subscription_events_type
  ON public.subscription_events (event_type, received_at DESC);

COMMENT ON TABLE public.subscription_events IS
  'Audit log of all RevenueCat webhook events. Source of truth = RC; this is for analytics & debugging.';

-- ============================================================
-- 3. RLS — Sadece service_role yazabilir, user kendi event'lerini okuyabilir
-- ============================================================

ALTER TABLE public.subscription_events ENABLE ROW LEVEL SECURITY;

-- Service role her şeyi yapar (webhook handler bunu kullanır)
DROP POLICY IF EXISTS "service_role_full_access" ON public.subscription_events;
CREATE POLICY "service_role_full_access"
  ON public.subscription_events
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Authenticated user sadece kendi event'lerini görür
DROP POLICY IF EXISTS "user_can_read_own_events" ON public.subscription_events;
CREATE POLICY "user_can_read_own_events"
  ON public.subscription_events
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================
-- 4. Helper view — Aktif subscription'lar (analytics için)
-- ============================================================

CREATE OR REPLACE VIEW public.active_subscriptions AS
SELECT
  up.id as user_id,
  up.is_premium,
  up.premium_expires_at,
  up.premium_product_id,
  up.premium_platform,
  CASE
    WHEN up.premium_expires_at IS NULL AND up.is_premium THEN 'lifetime'
    WHEN up.premium_expires_at > now() THEN 'active'
    WHEN up.premium_expires_at <= now() THEN 'expired'
    ELSE 'none'
  END as subscription_status,
  CASE
    WHEN up.premium_expires_at IS NULL THEN NULL
    ELSE (up.premium_expires_at - now())
  END as time_remaining
FROM public.user_profiles up
WHERE up.is_premium = true OR up.premium_expires_at IS NOT NULL;

COMMENT ON VIEW public.active_subscriptions IS
  'Convenience view: current subscription status per user with computed labels.';

-- ============================================================
-- 5. Trigger — premium_updated_at otomatik güncelle
-- ============================================================

CREATE OR REPLACE FUNCTION public.touch_premium_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (
    NEW.is_premium IS DISTINCT FROM OLD.is_premium
    OR NEW.premium_expires_at IS DISTINCT FROM OLD.premium_expires_at
    OR NEW.premium_product_id IS DISTINCT FROM OLD.premium_product_id
  ) THEN
    NEW.premium_updated_at = now();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_touch_premium_updated_at ON public.user_profiles;
CREATE TRIGGER trg_touch_premium_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.touch_premium_updated_at();

-- ============================================================
-- DONE
-- ============================================================
-- Test:
--   SELECT * FROM information_schema.columns
--   WHERE table_name = 'user_profiles' AND column_name LIKE '%premium%';
--
--   SELECT * FROM subscription_events LIMIT 0;
--   SELECT * FROM active_subscriptions LIMIT 0;
-- ============================================================
