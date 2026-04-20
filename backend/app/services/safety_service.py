"""
Safety Service
Risk tarama, kriz tespiti ve sabit güvenlik metinleri.
docs/protocols/safety-wellness-boundary.md ile birebir uyumlu.
"""
from ..core.logging import get_logger

logger = get_logger(__name__)


# Grup A — Crisis: AI yanıt üretme, sadece sabit metin
GROUP_A_CRISIS = [
    "kendime zarar", "kendimi öldür", "kendimi incit",
    "intihar", "ölmek istiyorum", "yaşamak istemiyorum",
    "bitirmek istiyorum",
]

# Grup B — Yeme bozukluğu işaretleri
GROUP_B_EATING_DISORDER = [
    "kusuyorum", "kusarak", "purge", "laksatif",
    "hiç yemiyorum", "yemeden duruyorum", "tıkınıyorum",
    "yedikten sonra kusuyorum",
]

# Grup C — Aşırı kısıtlama
GROUP_C_RESTRICTION = [
    "500 kalori", "600 kalori", "700 kalori", "800 kalori",
    "hiç yemeden", "aç kalmak istiyorum",
]


# SABİT — Değiştirilemez, AI üretemez
CRISIS_MESSAGE_TR = """Seninle ilgili endişeleniyorum. Şu an zor bir yer olabilir.

Yardım almak için:
• ALO 182 — Psikolojik Destek Hattı (7/24)

Buradayım, ama profesyonel destek çok daha fazlasını yapabilir."""


ED_SUPPORT_MESSAGE_TR = """Bunu paylaşman cesurca. Yemeyle ilişkin zorlanıyor gibi görünüyor — tek başına taşımak zor.

Bir uzmanla konuşmayı düşünür müsün? Profesyonel destek gerçek fark yaratabilir.

Ben buradayım, ama uzmanlık başka bir şey."""


RESTRICTION_GENTLE_NUDGE_TR = """Kendine karşı çok sert olma. Aşırı kısıtlama uzun vadede işe yaramaz, bedenin de zorlanır.

Sürdürülebilir küçük adımlar her zaman daha iyi. İstersen birlikte bakalım."""


class RiskLevel:
    NORMAL = "normal"
    LOW_INTAKE = "low_intake"
    DISTRESS = "distress"
    CRISIS = "crisis"


class SafetyService:

    def scan(self, text: str) -> str:
        """
        Kullanıcı input'unu tarar ve risk seviyesi döndürür.
        Dönen değer: normal | low_intake | distress | crisis
        """
        if not text:
            return RiskLevel.NORMAL

        lowered = text.lower()

        # Grup A — en yüksek öncelik
        for keyword in GROUP_A_CRISIS:
            if keyword in lowered:
                logger.warning("safety_crisis_detected", keyword=keyword)
                return RiskLevel.CRISIS

        # Grup B — distress
        for keyword in GROUP_B_EATING_DISORDER:
            if keyword in lowered:
                logger.info("safety_ed_signal", keyword=keyword)
                return RiskLevel.DISTRESS

        # Grup C — low intake
        for keyword in GROUP_C_RESTRICTION:
            if keyword in lowered:
                logger.info("safety_restriction_signal", keyword=keyword)
                return RiskLevel.LOW_INTAKE

        return RiskLevel.NORMAL

    def get_fixed_message(self, risk_level: str) -> str | None:
        """Sabit güvenlik metinlerini döndürür. None ise AI yanıt üretebilir."""
        if risk_level == RiskLevel.CRISIS:
            return CRISIS_MESSAGE_TR
        if risk_level == RiskLevel.DISTRESS:
            return ED_SUPPORT_MESSAGE_TR
        if risk_level == RiskLevel.LOW_INTAKE:
            return RESTRICTION_GENTLE_NUDGE_TR
        return None

    def should_block_ai(self, risk_level: str) -> bool:
        """Crisis durumunda AI tamamen bloke edilir."""
        return risk_level == RiskLevel.CRISIS
