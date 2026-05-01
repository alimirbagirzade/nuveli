-- 011_daily_checkins_and_safety.sql
-- Nuveli MVP — Boş gün, haftalık içgörü, güvenlik tabloları
-- PRD §5.4 Boş gün, §10.3 Analitik, §16 Güvenlik

-- ═══════════════════════════════════════════════════════════════
-- daily_checkins
-- Boş gün, craving, mood gibi mikro check-in'ler.
-- "İyiydim / Yoğundum / Dağıldım / Sonra girerim" akışı buraya yazar.
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  checkin_date DATE NOT NULL,

  type TEXT NOT NULL
    CHECK (type IN ('empty_day', 'mood', 'craving', 'recovery_day_acknowledge')),

  -- empty_day: 'good_day' | 'busy' | 'off_track' | 'later'
  -- mood: 'happy' | 'neutral' | 'tired' | 'stressed' | 'sad'
  -- craving: 'sweet' | 'salty' | 'fatty' | 'sugary_drink'
  -- recovery_day_acknowledge: payload.plan_accepted bool
  value TEXT NOT NULL,

  -- Ek detay (örn craving için "akşam 9, ekran karşısında")
  payload JSONB NOT NULL DEFAULT '{}',

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Aynı kullanıcı, aynı gün, aynı tip için tek kayıt
  UNIQUE(user_id, checkin_date, type)
);

CREATE INDEX IF NOT EXISTS idx_checkins_user_date
  ON daily_checkins(user_id, checkin_date DESC);

CREATE INDEX IF NOT EXISTS idx_checkins_user_type
  ON daily_checkins(user_id, type, checkin_date DESC);

ALTER TABLE daily_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users manage own checkins"
  ON daily_checkins FOR ALL
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- weekly_insights
-- Haftalık özet ekranı için cache (PRD §5.5)
-- Backend job tarafından doldurulur, frontend buradan okur
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS weekly_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Haftanın başlangıcı (Pazartesi)
  week_start_date DATE NOT NULL,

  -- 7 günlük toplamlar
  total_calories INTEGER NOT NULL DEFAULT 0,
  total_meals INTEGER NOT NULL DEFAULT 0,
  total_water_ml INTEGER NOT NULL DEFAULT 0,
  weight_change_kg NUMERIC(4,2),

  -- Denge skoru (0-100)
  balance_score INTEGER CHECK (balance_score BETWEEN 0 AND 100),

  -- En fazla 3 kısa içgörü (PRD §5.5)
  insights JSONB NOT NULL DEFAULT '[]',

  -- Koç özet metni (premium'da daha derin)
  coach_summary TEXT,
  coach_summary_premium TEXT,

  -- Generated_at: son üretildiği zaman (idempotent re-generation için)
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(user_id, week_start_date)
);

CREATE INDEX IF NOT EXISTS idx_weekly_insights_user
  ON weekly_insights(user_id, week_start_date DESC);

ALTER TABLE weekly_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users read own weekly insights"
  ON weekly_insights FOR SELECT
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- safety_flags
-- Kullanıcı bazlı güvenlik durumu (PRD §16.3, §11.3 high_risk mode)
-- Decision Engine bu tabloyu okuyup safety mode kararı verir.
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS safety_flags (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 'normal' | 'sensitive' | 'high_risk'
  current_mode TEXT NOT NULL DEFAULT 'normal'
    CHECK (current_mode IN ('normal', 'sensitive', 'high_risk')),

  -- Trigger kaynağı (debug ve audit için)
  -- 'extreme_target' | 'rapid_weight_loss' | 'restriction_pattern' |
  -- 'flagged_message' | 'manual_admin' | null
  mode_reason TEXT,
  mode_set_at TIMESTAMPTZ,

  -- Otomatik downgrade
  auto_downgrade_at TIMESTAMPTZ,

  -- Manuel bayraklar (PRD §16.2)
  acknowledged_wellness_scope BOOLEAN NOT NULL DEFAULT false,
  acknowledged_ai_approximate BOOLEAN NOT NULL DEFAULT false,
  acknowledged_special_situations BOOLEAN NOT NULL DEFAULT false,

  -- Hassas durumlar (kullanıcı seçimi)
  has_pregnancy BOOLEAN DEFAULT false,
  has_chronic_condition BOOLEAN DEFAULT false,
  has_eating_disorder_history BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE safety_flags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users read own safety flags"
  ON safety_flags FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT/UPDATE sadece backend (service_role) tarafından

-- ═══════════════════════════════════════════════════════════════
-- safety_events
-- Güvenlik olay log'u (audit trail)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS safety_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  event_type TEXT NOT NULL,
  -- 'mode_change' | 'message_blocked' | 'fallback_triggered' |
  -- 'high_risk_resource_shown' | 'professional_help_redirect'

  previous_mode TEXT,
  new_mode TEXT,

  trigger_source TEXT,
  -- 'coach_response' | 'meal_log' | 'profile_update' | 'manual'

  -- Bloklanan metin (PII içerebilir, dikkatli)
  blocked_content_summary TEXT,

  metadata JSONB NOT NULL DEFAULT '{}',

  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_safety_events_user
  ON safety_events(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_safety_events_type
  ON safety_events(event_type, created_at DESC);

ALTER TABLE safety_events ENABLE ROW LEVEL SECURITY;

-- Kullanıcı kendi event'lerini OKUYAMAZ (gizlilik için).
-- Sadece service_role görebilir.

-- ═══════════════════════════════════════════════════════════════
-- Triggers
-- ═══════════════════════════════════════════════════════════════
DROP TRIGGER IF EXISTS trg_weekly_insights_updated ON weekly_insights;
CREATE TRIGGER trg_weekly_insights_updated
  BEFORE UPDATE ON weekly_insights
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_safety_flags_updated ON safety_flags;
CREATE TRIGGER trg_safety_flags_updated
  BEFORE UPDATE ON safety_flags
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
