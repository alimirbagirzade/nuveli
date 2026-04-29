-- Migration 007: Custom photo avatar + profile sanity columns
-- Lets users replace their DiceBear illustration with a real photo
-- they pick from the device gallery (uploaded to Supabase Storage).

-- 1. Add avatar_photo_url for custom uploads
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS avatar_photo_url TEXT;

-- 2. Allow 'custom' as an avatar_style for users who picked a real photo.
-- Drop the old check constraint and re-add with 'custom' included.
ALTER TABLE profiles
  DROP CONSTRAINT IF EXISTS profiles_avatar_style_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_avatar_style_check
  CHECK (avatar_style IN ('lorelei', 'peep', 'bottts', 'adventurer', 'fun-emoji', 'custom'));

-- 3. Storage bucket for avatar photos.
-- Run this once in the Supabase dashboard if it doesn't already exist:
--   Storage → New bucket → name: 'avatars', public: true
-- We're not creating it via SQL because Supabase storage buckets are
-- managed through their own API. Comment kept here so the next person
-- knows the bucket dependency.

COMMENT ON COLUMN profiles.avatar_photo_url IS
  'Public URL of the user-uploaded avatar photo in Supabase Storage. '
  'When non-null, takes precedence over avatar_style + avatar_seed.';
