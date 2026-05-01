-- Migration 008: Loosen goal + activity_level CHECK constraints
--
-- Why:
-- The original migration 001 wrote constraints based on a much earlier
-- version of the onboarding flow:
--   goal IN ('lose', 'maintain', 'gain')
--   activity_level IN ('sedentary', 'light', 'moderate', 'active')
--
-- The Goals screen and Personal Info screen now use richer copy that
-- maps to different code values:
--   goal: lose_weight | maintain | gain_muscle
--   activity_level: sedentary | light | moderate | active | very_active
--
-- Saving from those screens hits the constraint and the API returns
-- a generic "Bir şeyler ters gitti" — which is what the user is seeing.
--
-- Fix:
-- Drop the old CHECK constraints and add wider ones that allow BOTH
-- the legacy short codes (so existing rows don't violate the new
-- constraint after the alter) AND the new long codes used by the app.

-- Goal --------------------------------------------------------------
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_goal_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_goal_check
  CHECK (goal IS NULL OR goal IN (
    -- Legacy values, kept so old rows pass:
    'lose', 'gain',
    -- Current values written by the app:
    'lose_weight', 'maintain', 'gain_muscle'
  ));

-- Optional one-time normalization of legacy rows so new code always
-- sees consistent values. Safe to run repeatedly.
UPDATE profiles SET goal = 'lose_weight'  WHERE goal = 'lose';
UPDATE profiles SET goal = 'gain_muscle'  WHERE goal = 'gain';

-- Activity level ----------------------------------------------------
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_activity_level_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_activity_level_check
  CHECK (activity_level IS NULL OR activity_level IN (
    'sedentary', 'light', 'moderate', 'active', 'very_active'
  ));

-- Gender ------------------------------------------------------------
-- The personal info screen offers Kadın/Erkek/Diğer → female/male/other.
-- Make sure the DB accepts these values. Old constraint may have only
-- allowed 'female'/'male' depending on when the column was added.
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_gender_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_gender_check
  CHECK (gender IS NULL OR gender IN ('female', 'male', 'other'));

COMMENT ON COLUMN profiles.goal IS 'lose_weight | maintain | gain_muscle';
COMMENT ON COLUMN profiles.activity_level IS 'sedentary | light | moderate | active | very_active';
COMMENT ON COLUMN profiles.gender IS 'female | male | other';
