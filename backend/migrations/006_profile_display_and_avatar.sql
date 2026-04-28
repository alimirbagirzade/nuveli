-- Migration 006: Profile display_name and avatar fields
-- Adds personalization fields so users can set a display name and
-- pick a DiceBear avatar (style + seed combination).

-- Add columns if they don't exist (idempotent)
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS display_name TEXT,
  ADD COLUMN IF NOT EXISTS avatar_style TEXT DEFAULT 'lorelei',
  ADD COLUMN IF NOT EXISTS avatar_seed TEXT;

-- Backfill avatar_seed for existing profiles using their user_id
-- so they get a deterministic random avatar instead of a blank.
UPDATE profiles
SET avatar_seed = id::text
WHERE avatar_seed IS NULL;

-- Constrain avatar_style to known DiceBear styles to prevent typos
ALTER TABLE profiles
  DROP CONSTRAINT IF EXISTS profiles_avatar_style_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_avatar_style_check
  CHECK (avatar_style IN ('lorelei', 'peep', 'bottts', 'adventurer', 'fun-emoji'));

-- Index on display_name for future search/leaderboard features
CREATE INDEX IF NOT EXISTS idx_profiles_display_name ON profiles(display_name);

COMMENT ON COLUMN profiles.display_name IS 'User-facing name shown in app. Defaults to empty until user sets it.';
COMMENT ON COLUMN profiles.avatar_style IS 'DiceBear avatar style. One of: lorelei, peep, bottts, adventurer, fun-emoji.';
COMMENT ON COLUMN profiles.avatar_seed IS 'DiceBear avatar seed string. Combined with style produces a unique illustration.';
