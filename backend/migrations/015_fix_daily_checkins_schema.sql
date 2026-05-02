-- 015_fix_daily_checkins_schema.sql
-- Fix: daily_checkins tablosu schema mismatch
-- Backend mood, note, local_day bekliyor ama eski tablo type, value, payload yapısındaydı.

DROP TABLE IF EXISTS daily_checkins CASCADE;

CREATE TABLE daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  local_day DATE NOT NULL,
  mood TEXT CHECK (mood IS NULL OR mood IN (
    'great', 'good', 'okay', 'rough', 'tough',
    'neutral', 'bad', 'terrible', 'amazing',
    'happy', 'sad', 'meh', 'fine', 'low', 'high'
  )),
  note TEXT,
  type TEXT,
  payload JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE(user_id, local_day)
);

CREATE INDEX idx_daily_checkins_user_local_day
  ON daily_checkins(user_id, local_day DESC);

CREATE INDEX idx_daily_checkins_type
  ON daily_checkins(user_id, type) WHERE type IS NOT NULL;

ALTER TABLE daily_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users read own checkins"
  ON daily_checkins FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users insert own checkins"
  ON daily_checkins FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users update own checkins"
  ON daily_checkins FOR UPDATE
  USING (auth.uid() = user_id);
