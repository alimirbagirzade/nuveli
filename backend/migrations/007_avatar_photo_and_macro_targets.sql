-- Migration 007: Avatar photo URL + macro targets
--
-- avatar_photo_url: alternative to avatar_seed/avatar_style. When set,
-- the app shows the user's uploaded photo (food, selfie, anything they
-- pick from gallery) instead of the generated DiceBear illustration.
-- Resolution priority on the client: photo_url > generated avatar.
--
-- target_protein_g / target_carb_g / target_fat_g: macro split for the
-- daily calorie target. These are derived from target_calories using
-- the user's chosen ratio (defaults to 25/45/30 P/C/F if not set), so
-- they're optional at write-time. We store them denormalized to avoid
-- recomputing on every home payload.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS avatar_photo_url TEXT,
  ADD COLUMN IF NOT EXISTS target_protein_g INTEGER,
  ADD COLUMN IF NOT EXISTS target_carb_g INTEGER,
  ADD COLUMN IF NOT EXISTS target_fat_g INTEGER;

-- Backfill macro targets from existing target_calories using a
-- reasonable default split (25% P, 45% C, 30% F by calories).
-- Protein/carb are 4 kcal/g, fat is 9 kcal/g.
UPDATE profiles
SET
  target_protein_g = ROUND((daily_calorie_target * 0.25) / 4)::int,
  target_carb_g    = ROUND((daily_calorie_target * 0.45) / 4)::int,
  target_fat_g     = ROUND((daily_calorie_target * 0.30) / 9)::int
WHERE
  daily_calorie_target IS NOT NULL
  AND target_protein_g IS NULL;

COMMENT ON COLUMN profiles.avatar_photo_url IS 'Optional uploaded photo. Takes precedence over avatar_seed/avatar_style on the client.';
COMMENT ON COLUMN profiles.target_protein_g IS 'Daily protein target in grams. Derived from target_calories × ratio.';
COMMENT ON COLUMN profiles.target_carb_g IS 'Daily carb target in grams.';
COMMENT ON COLUMN profiles.target_fat_g IS 'Daily fat target in grams.';
