"""
Tests for coach insight language localisation.

Verifies that:
1. build_coach_insight_messages includes the correct language instruction
   when a non-English language code is supplied.
2. An unknown or None language code falls back to English silently.
3. The language instruction is absent (or says English) for 'en' input.
4. _resolve_language_name maps codes correctly.
"""
import pytest

from prompts.coach_prompts import (
    _resolve_language_name,
    build_coach_insight_messages,
    build_coach_insight_user_prompt,
)


SAMPLE_DATA: dict = {
    "period_days": 7,
    "meals_logged": 14,
    "avg_daily_calories": 1850.0,
    "target_calories": 2000,
    "avg_daily_water_ml": 2000,
    "target_water_ml": 2500,
    "habits_count": 3,
    "habits_completions": 15,
    "habit_completion_rate": 0.71,
    "weight_logs": [],
}


class TestResolveLanguageName:
    def test_known_codes(self):
        assert _resolve_language_name("tr") == "Turkish"
        assert _resolve_language_name("de") == "German"
        assert _resolve_language_name("es") == "Spanish"
        assert _resolve_language_name("fr") == "French"
        assert _resolve_language_name("it") == "Italian"
        assert _resolve_language_name("ru") == "Russian"
        assert _resolve_language_name("en") == "English"

    def test_none_returns_english(self):
        assert _resolve_language_name(None) == "English"

    def test_empty_string_returns_english(self):
        assert _resolve_language_name("") == "English"

    def test_unknown_code_returns_english(self):
        assert _resolve_language_name("zh") == "English"
        assert _resolve_language_name("xx") == "English"

    def test_case_insensitive(self):
        assert _resolve_language_name("TR") == "Turkish"
        assert _resolve_language_name("De") == "German"


class TestBuildCoachInsightUserPrompt:
    def test_turkish_language_instruction_present(self):
        prompt = build_coach_insight_user_prompt(SAMPLE_DATA, language_code="tr")
        assert "Turkish" in prompt
        assert "Respond entirely in Turkish" in prompt

    def test_german_language_instruction_present(self):
        prompt = build_coach_insight_user_prompt(SAMPLE_DATA, language_code="de")
        assert "German" in prompt
        assert "Respond entirely in German" in prompt

    def test_english_default_when_none(self):
        prompt = build_coach_insight_user_prompt(SAMPLE_DATA, language_code=None)
        assert "English" in prompt

    def test_english_default_when_unknown(self):
        prompt = build_coach_insight_user_prompt(SAMPLE_DATA, language_code="zz")
        assert "English" in prompt

    def test_keys_stay_english_instruction_present(self):
        prompt = build_coach_insight_user_prompt(SAMPLE_DATA, language_code="fr")
        # Must instruct model to keep JSON keys in English
        assert "JSON keys stay in English" in prompt

    def test_user_data_in_prompt(self):
        prompt = build_coach_insight_user_prompt(SAMPLE_DATA, language_code="tr")
        assert "meals_logged" in prompt


class TestBuildCoachInsightMessages:
    def test_returns_system_and_user_messages(self):
        msgs = build_coach_insight_messages(SAMPLE_DATA, language_code="tr")
        assert len(msgs) == 2
        assert msgs[0]["role"] == "system"
        assert msgs[1]["role"] == "user"

    def test_user_message_includes_language_instruction_for_turkish(self):
        msgs = build_coach_insight_messages(SAMPLE_DATA, language_code="tr")
        user_content = msgs[1]["content"]
        assert "Turkish" in user_content
        assert "Respond entirely in Turkish" in user_content

    def test_user_message_falls_back_to_english_for_null(self):
        msgs = build_coach_insight_messages(SAMPLE_DATA, language_code=None)
        user_content = msgs[1]["content"]
        assert "English" in user_content

    def test_system_prompt_unchanged_regardless_of_language(self):
        msgs_tr = build_coach_insight_messages(SAMPLE_DATA, language_code="tr")
        msgs_en = build_coach_insight_messages(SAMPLE_DATA, language_code="en")
        # System prompt must be identical — language only lives in user turn
        assert msgs_tr[0]["content"] == msgs_en[0]["content"]

    def test_default_language_arg_is_none(self):
        """Calling without language_code must not raise."""
        msgs = build_coach_insight_messages(SAMPLE_DATA)
        assert msgs[1]["role"] == "user"
