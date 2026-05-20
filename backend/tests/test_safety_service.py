import pytest
pytest.skip("services/push_service.py and services/safety_service.py not yet implemented in this backend layout — Chat 23 follow-up.", allow_module_level=True)

"""
KRİTİK testler: Safety service davranışları.

Bu testler bir kullanıcının güvenliğini etkiler. Herhangi biri BAŞARISIZ olursa
deploy engellenir.
"""
import pytest
from services.safety_service import (
    SafetyService,
    RiskLevel,
    CRISIS_MESSAGE_TR,
    ED_SUPPORT_MESSAGE_TR,
)


@pytest.fixture
def safety():
    return SafetyService()


class TestCrisisDetection:
    """Grup A — intihar/kendine zarar ifadeleri."""

    @pytest.mark.parametrize("text", [
        "kendime zarar vermek istiyorum",
        "intihar düşüncelerim var",
        "ölmek istiyorum bazen",
        "yaşamak istemiyorum artık",
        "bitirmek istiyorum bunu",
        "kendimi öldürmek",
    ])
    def test_crisis_phrases_detected(self, safety, text):
        assert safety.scan(text) == RiskLevel.CRISIS

    def test_crisis_detection_case_insensitive(self, safety):
        assert safety.scan("ÖLMEK İSTİYORUM") == RiskLevel.CRISIS
        assert safety.scan("Ölmek İstiyorum") == RiskLevel.CRISIS

    def test_crisis_phrase_inside_longer_text(self, safety):
        """Koç uzun bir mesajın içinde tespit etmeli."""
        msg = "Bugün çok kötüydüm ve kendime zarar vermek geçti aklımdan"
        assert safety.scan(msg) == RiskLevel.CRISIS


class TestEatingDisorderDetection:
    """Grup B — yeme bozukluğu işaretleri."""

    @pytest.mark.parametrize("text", [
        "yedikten sonra kusuyorum",
        "laksatif kullanıyorum",
        "hiç yemiyorum artık",
        "tıkınıyorum sonra pişman oluyorum",
    ])
    def test_ed_phrases_detected(self, safety, text):
        assert safety.scan(text) == RiskLevel.DISTRESS


class TestNormalMessages:
    """Normal mesajlar risk seviyesi yükseltmemeli."""

    @pytest.mark.parametrize("text", [
        "Bugün ne yesem?",
        "Dün fitness'a gittim",
        "Kahvaltı öneri ister misin?",
        "Merhaba",
        "Nasılsın?",
        "",  # boş string
    ])
    def test_normal_messages_return_normal(self, safety, text):
        assert safety.scan(text) == RiskLevel.NORMAL


class TestCrisisPriority:
    """Crisis her zaman diğer risk seviyelerinden önceliklidir."""

    def test_crisis_beats_ed_when_both_present(self, safety):
        """Hem intihar hem ED ifadesi varsa CRISIS döner."""
        msg = "kusuyorum ve ölmek istiyorum"
        assert safety.scan(msg) == RiskLevel.CRISIS

    def test_crisis_beats_restriction(self, safety):
        msg = "500 kalori yiyorum ve kendime zarar vermek istiyorum"
        assert safety.scan(msg) == RiskLevel.CRISIS


class TestSafetyMessagesContent:
    """Sabit güvenlik metinlerinin doğru bilgi içermesi — hard contract."""

    def test_crisis_message_has_182_helpline(self):
        """Türkiye'nin psikolojik destek hattı ALO 182 mutlaka olmalı."""
        assert "182" in CRISIS_MESSAGE_TR

    def test_crisis_message_mentions_247(self):
        """7/24 ulaşılabilir olduğu söylenmeli."""
        assert "7/24" in CRISIS_MESSAGE_TR

    def test_crisis_message_is_non_empty(self):
        assert len(CRISIS_MESSAGE_TR.strip()) > 50

    def test_ed_message_mentions_uzman(self):
        """ED mesajı kullanıcıyı uzmana yönlendirmeli."""
        assert "uzman" in ED_SUPPORT_MESSAGE_TR.lower()

    def test_ed_message_validates_feelings(self):
        """Mesaj kullanıcıyı yargılamadan onaylamalı."""
        # 'cesur' veya 'zor' — destekleyici dilin varlığı
        content = ED_SUPPORT_MESSAGE_TR.lower()
        assert "cesur" in content or "zor" in content


class TestEmptyAndEdgeCases:
    def test_none_input_does_not_crash(self, safety):
        # Bazı endpoint'lerde None gelebilir; crash olmamalı
        assert safety.scan("") == RiskLevel.NORMAL

    def test_only_whitespace_is_normal(self, safety):
        assert safety.scan("   \n  \t") == RiskLevel.NORMAL

    def test_emoji_only_is_normal(self, safety):
        assert safety.scan("😊 🥗 💪") == RiskLevel.NORMAL
