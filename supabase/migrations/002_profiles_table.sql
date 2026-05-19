-- =============================================================================
-- Migration 002: user_profiles tablosu
-- =============================================================================
-- Amaç: Onboarding'de toplanan kullanıcı bilgileri, hedefler, tercihler.
-- İlişki: auth.users (1) ──< user_profiles (1)
-- =============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Kişisel bilgiler
  display_name TEXT NOT NULL,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  height_cm NUMERIC(5,2),
  current_weight_kg NUMERIC(5,2),

  -- Aktivite ve hedefler
  activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  goal_type TEXT CHECK (goal_type IN ('lose_weight', 'maintain', 'gain_weight', 'build_muscle')),
  daily_calorie_target INT NOT NULL DEFAULT 2000 CHECK (daily_calorie_target > 0),
  daily_water_target_ml INT NOT NULL DEFAULT 2500 CHECK (daily_water_target_ml > 0),

  -- Makro hedefleri (yüzde olarak, toplam 100)
  protein_target_pct INT DEFAULT 25 CHECK (protein_target_pct BETWEEN 0 AND 100),
  carbs_target_pct INT DEFAULT 45 CHECK (carbs_target_pct BETWEEN 0 AND 100),
  fat_target_pct INT DEFAULT 30 CHECK (fat_target_pct BETWEEN 0 AND 100),

  -- Streak (cron job ile güncellenir)
  current_streak_days INT DEFAULT 0 CHECK (current_streak_days >= 0),
  longest_streak_days INT DEFAULT 0 CHECK (longest_streak_days >= 0),
  last_active_date DATE,

  -- Onboarding durumu
  onboarding_completed BOOLEAN DEFAULT FALSE,
  onboarding_completed_at TIMESTAMPTZ,

  -- Tercihler
  language TEXT DEFAULT 'tr' CHECK (language IN ('tr', 'en')),
  timezone TEXT DEFAULT 'Europe/Istanbul',
  measurement_system TEXT DEFAULT 'metric' CHECK (measurement_system IN ('metric', 'imperial')),

  -- Notification ayarları
  notifications_enabled BOOLEAN DEFAULT TRUE,
  morning_reminder_time TIME DEFAULT '09:00',
  afternoon_reminder_time TIME DEFAULT '13:00',
  evening_reminder_time TIME DEFAULT '18:30',

  -- Premium
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at TIMESTAMPTZ,

  -- Meta
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Makro yüzdelerinin toplamı 100 olmalı
  CONSTRAINT chk_macro_pct_sum CHECK (protein_target_pct + carbs_target_pct + fat_target_pct = 100)
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_is_premium ON public.user_profiles(is_premium) WHERE is_premium = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_profiles_last_active ON public.user_profiles(last_active_date DESC) WHERE last_active_date IS NOT NULL;

COMMENT ON TABLE public.user_profiles IS 'Onboarding bilgileri, hedefler ve kullanıcı tercihleri. Her auth.users için 1 kayıt (trigger ile otomatik oluşur).';
COMMENT ON COLUMN public.user_profiles.daily_calorie_target IS 'BMR + TDEE hesabıyla onboarding sonunda set edilir.';
COMMENT ON COLUMN public.user_profiles.current_streak_days IS 'Ardışık aktif gün sayısı. Meal eklendikçe trigger ile güncellenir.';

COMMIT;
