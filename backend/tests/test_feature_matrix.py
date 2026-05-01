"""Premium feature matrix davranışları."""
from app.services.premium_service import FEATURE_MATRIX


class TestFeatureMatrix:
    def test_free_tier_has_daily_limits(self):
        f = FEATURE_MATRIX["free"]
        assert f["meal_analyses_per_day"] < 9999
        assert f["coach_messages_per_day"] < 9999
        assert f["voice_reply"] is False
        assert f["weekly_summary"] is False
        assert f["monthly_insight"] is False

    def test_trial_tier_unlocks_everything_except_monthly(self):
        t = FEATURE_MATRIX["trial"]
        assert t["meal_analyses_per_day"] >= 9999
        assert t["coach_messages_per_day"] >= 9999
        assert t["voice_reply"] is True
        assert t["weekly_summary"] is True
        # Aylık insight premium'a özel
        assert t["monthly_insight"] is False

    def test_premium_tier_has_everything(self):
        p = FEATURE_MATRIX["premium"]
        assert p["meal_analyses_per_day"] >= 9999
        assert p["coach_messages_per_day"] >= 9999
        assert p["voice_reply"] is True
        assert p["weekly_summary"] is True
        assert p["monthly_insight"] is True

    def test_all_tiers_present(self):
        """Frontend tier enum ile uyumluluk: free, trial, premium mutlaka olmalı."""
        required_tiers = {"free", "trial", "premium"}
        assert required_tiers <= set(FEATURE_MATRIX.keys())

    def test_all_tiers_have_same_feature_keys(self):
        """Hiçbir tier'da tanımsız feature kalmasın — defensive check."""
        free_keys = set(FEATURE_MATRIX["free"].keys())
        for tier in ("trial", "premium"):
            assert set(FEATURE_MATRIX[tier].keys()) == free_keys, \
                f"{tier} tier'ı free ile aynı feature'lara sahip olmalı"

    def test_progress_charts_values_valid(self):
        """basic/full dışında bir değer olmamalı."""
        valid = {"basic", "full"}
        for tier in FEATURE_MATRIX.values():
            assert tier["progress_charts"] in valid


class TestTierProgression:
    """Free → Trial → Premium yükseldikçe kısıtlar azalmalı."""

    def test_upgrade_only_unlocks_never_restricts(self):
        """Trial'daki her feature free'dekine eşit veya daha iyi olmalı."""
        free = FEATURE_MATRIX["free"]
        trial = FEATURE_MATRIX["trial"]

        # Numeric limits artmalı
        assert trial["meal_analyses_per_day"] >= free["meal_analyses_per_day"]
        assert trial["coach_messages_per_day"] >= free["coach_messages_per_day"]

        # Boolean feature'lar açılmalı (geri kapanmamalı)
        for bool_key in ("voice_reply", "weekly_summary"):
            if free[bool_key] is True:
                assert trial[bool_key] is True

    def test_premium_is_superset_of_trial(self):
        """Premium trial'ın üstüne sadece ekler (monthly_insight)."""
        trial = FEATURE_MATRIX["trial"]
        premium = FEATURE_MATRIX["premium"]

        assert premium["meal_analyses_per_day"] >= trial["meal_analyses_per_day"]
        assert premium["monthly_insight"] is True  # bu trial'da yoktu
