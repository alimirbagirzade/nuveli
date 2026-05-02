-- 016_widen_usage_feature_enum.sql
-- Backend uses both 'meal_analyses' and the original 'meal_photo_analysis'
-- spelling. Also 'coach_messages' alongside 'coach_text_response'.
-- This widens the CHECK constraint to accept either spelling.

ALTER TABLE usage_counters_daily 
  DROP CONSTRAINT IF EXISTS usage_counters_daily_feature_check;

ALTER TABLE usage_counters_daily 
  ADD CONSTRAINT usage_counters_daily_feature_check 
  CHECK (feature IN (
    'meal_analyses', 'coach_messages',
    'meal_photo_analysis', 'coach_text_response', 'coach_voice_response'
  ));
