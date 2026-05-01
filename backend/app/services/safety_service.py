"""
backend/app/services/safety_service.py

Safety Service — AI cevabını son kontrolden geçirir.
PRD §11 AI Protokolleri, §16 Güvenlik.

İki mod:
1. filter() → cevap metnini filtrele/blokla
2. should_show_resources() → high_risk durumunda profesyonel destek göster

Not: Bu servis AI çağrısı YAPMAZ. Sadece text pattern matching yapar.
İleri sürümde (V2) kategorik bir text classification eklenebilir.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
import logging
import re
from typing import Optional

from app.services.decision_engine import SafetyMode

logger = logging.getLogger(__name__)


class BlockReason(str, Enum):
    MEDICAL_CLAIM = "medical_claim"
    HARMFUL_BEHAVIOR = "harmful_behavior"  # aç kalma, kusma, vs
    PUNITIVE_EXERCISE = "punitive_exercise"
    ALCOHOL_REWARD = "alcohol_reward"
    BODY_SHAMING = "body_shaming"
    GUARANTEE_CLAIM = "guarantee_claim"  # "X kg verirsin" tipi
    SUICIDE_OR_SELF_HARM_RESPONSE = "suicide_or_self_harm_response"
    PROHIBITED_TOPIC = "prohibited_topic"


@dataclass
class SafetyResult:
    passed: bool
    filtered_text: str           # bloklanmadıysa orijinal, bloklandıysa boş
    block_reason: Optional[BlockReason] = None
    triggered_patterns: list[str] = None  # debug için
    fallback_recommended: bool = False    # True ise fallback_copy kullan


# ═══════════════════════════════════════════════════════════════
# Pattern listeleri
# Not: Bunlar minimum başlangıç seviyesi. Production'da audit gerekli.
# ═══════════════════════════════════════════════════════════════

# Medikal iddia desenleri
MEDICAL_CLAIM_PATTERNS_TR = [
    r"\bteşhis\s+(et|koy|yap)",
    r"\btanı\s+(koy|yap)",
    r"\bilaç\s+öner",
    r"\bilaç\s+(al|kullan)",
    r"\bdoktor\s+yerine",
    r"\bdiyetisyen\s+yerine",
    r"\b(reçete|prescription)",
    r"\btedavi\s+et",
    r"\biyileş(tir|me\s+garanti)",
    r"\bhasta?lığ.{0,15}\b(geç|tedavi)",
]
MEDICAL_CLAIM_PATTERNS_EN = [
    r"\b(diagnose|diagnosis)\b",
    r"\bprescrib(e|ing)\b",
    r"\b(replace|instead of)\s+(your\s+)?(doctor|dietitian)",
    r"\btreat(s|ing)?\s+(your|the)\s+(illness|condition|disease)",
    r"\bcure\s+(your|the)",
]

# Zararlı davranış desenleri
HARMFUL_BEHAVIOR_PATTERNS_TR = [
    # "aç kalmalısın", "aç kalman lazım", "aç kalmak" — yasak
    # ama kullanıcıya "aç kalma" (negative imperative) DENMEZ → o yakalanmamalı
    r"\baç\s+kalma(?:lı|k\b|n[ıi]\s|n\s+(?:lazım|gerek))",
    r"\baç\s+kal\w*ı\s+öner",
    r"\bkus(?:mak|arak|man)",
    r"\bçıkart\s+(?:yemeği|öğünü)",
    r"\bgün(?:ler)?ce\s+yemek\s+yeme",
    r"\böğün\s+atla",
    r"\b300\s*(?:kalori|kcal)\b",   # çok düşük kalori önerisi
    r"\b(?:500|400|300)\s*kcal\s+(?:yeter|altı|ile|hedef)",
]
HARMFUL_BEHAVIOR_PATTERNS_EN = [
    r"\bstarv(e|ing|ation)\b",
    r"\bfast\s+for\s+\d+\s+days",
    r"\bvomit",
    r"\bpurge\b",
    r"\bskip\s+meals\s+for",
    r"\b(300|400|500)\s*(kcal|cal)\s+(is\s+enough|target|goal)",
]

# Cezalandırıcı egzersiz
PUNITIVE_EXERCISE_PATTERNS_TR = [
    r"\b\d+\s+saat\s+(koş|yürü|kardiyo)\s+çünkü",
    r"\bcezası\s+olarak\s+\d+",
    r"\byediğin\w*\s+(yak|atmak\s+için)\s+\d+\s+(saat|dakika)",
]
PUNITIVE_EXERCISE_PATTERNS_EN = [
    r"\b\d+\s+hours?\s+of\s+(running|cardio)\s+because",
    r"\bas\s+punishment\s+for\s+eating",
    r"\bburn\s+off\s+what\s+you\s+ate",
]

# Alkolü ödül gibi sunma
ALCOHOL_REWARD_PATTERNS_TR = [
    r"\bödül\s+olarak\s+(içki|şarap|bira|alkol)",
    r"\bbaşardın\s*[,.\s]\s*kendine\s+(içki|şarap|bira)",
]
ALCOHOL_REWARD_PATTERNS_EN = [
    r"\b(reward|treat)\s+yourself\s+with\s+(wine|beer|drinks?|alcohol)",
]

# Beden utandırma
BODY_SHAMING_PATTERNS_TR = [
    r"\bçok\s+kilolusun",
    r"\b(şişman|şişko|tombiş)\b",
    r"\bbu\s+haldeyken",
    r"\bçirkin\s+görün",
]
BODY_SHAMING_PATTERNS_EN = [
    r"\byou(\'re|\s+are)\s+too\s+(fat|chubby|heavy)",
    r"\byou\s+look\s+ugly",
]

# Garanti vaadi
GUARANTEE_CLAIM_PATTERNS_TR = [
    r"\bgaranti\s+\d+\s*kg",
    r"\bkesinlikle\s+\d+\s*kg\s+ver",
    r"\b\d+\s+gün(de)?\s+\d+\s*kg",
    r"\bmucizevi\s+(çözüm|sonuç)",
]
GUARANTEE_CLAIM_PATTERNS_EN = [
    r"\bguarantee(d|s)?\s+\d+\s*(kg|lbs?|pounds?)",
    r"\blose\s+\d+\s*(kg|lbs?|pounds?)\s+in\s+\d+\s+days",
    r"\bmiracle\s+(solution|result|cure)",
]


PATTERN_GROUPS_TR = [
    (MEDICAL_CLAIM_PATTERNS_TR, BlockReason.MEDICAL_CLAIM),
    (HARMFUL_BEHAVIOR_PATTERNS_TR, BlockReason.HARMFUL_BEHAVIOR),
    (PUNITIVE_EXERCISE_PATTERNS_TR, BlockReason.PUNITIVE_EXERCISE),
    (ALCOHOL_REWARD_PATTERNS_TR, BlockReason.ALCOHOL_REWARD),
    (BODY_SHAMING_PATTERNS_TR, BlockReason.BODY_SHAMING),
    (GUARANTEE_CLAIM_PATTERNS_TR, BlockReason.GUARANTEE_CLAIM),
]

PATTERN_GROUPS_EN = [
    (MEDICAL_CLAIM_PATTERNS_EN, BlockReason.MEDICAL_CLAIM),
    (HARMFUL_BEHAVIOR_PATTERNS_EN, BlockReason.HARMFUL_BEHAVIOR),
    (PUNITIVE_EXERCISE_PATTERNS_EN, BlockReason.PUNITIVE_EXERCISE),
    (ALCOHOL_REWARD_PATTERNS_EN, BlockReason.ALCOHOL_REWARD),
    (BODY_SHAMING_PATTERNS_EN, BlockReason.BODY_SHAMING),
    (GUARANTEE_CLAIM_PATTERNS_EN, BlockReason.GUARANTEE_CLAIM),
]


# ═══════════════════════════════════════════════════════════════
# Service
# ═══════════════════════════════════════════════════════════════

class SafetyService:
    def __init__(self):
        # Compile her pattern'i bir kere
        self._compiled_tr = [
            (
                [re.compile(p, re.IGNORECASE | re.UNICODE) for p in patterns],
                reason,
            )
            for patterns, reason in PATTERN_GROUPS_TR
        ]
        self._compiled_en = [
            (
                [re.compile(p, re.IGNORECASE) for p in patterns],
                reason,
            )
            for patterns, reason in PATTERN_GROUPS_EN
        ]

    def filter(
        self,
        text: str,
        mode: SafetyMode,
        locale: str = "tr",
    ) -> SafetyResult:
        """
        AI cevabını filtreler.
        mode'a göre sıkılık:
        - normal: yasaklılar bloklanır
        - sensitive: + ek dikkat (örn alkol)
        - high_risk: en sıkı + intihar/self-harm konularına özel
        """
        if not text or not text.strip():
            return SafetyResult(
                passed=False,
                filtered_text="",
                block_reason=BlockReason.PROHIBITED_TOPIC,
                fallback_recommended=True,
            )

        compiled = self._compiled_en if locale == "en" else self._compiled_tr
        triggered = []

        for patterns, reason in compiled:
            for pattern in patterns:
                if pattern.search(text):
                    triggered.append(pattern.pattern)
                    logger.warning(
                        "Safety block: reason=%s pattern=%s mode=%s",
                        reason.value, pattern.pattern, mode.value
                    )
                    return SafetyResult(
                        passed=False,
                        filtered_text="",
                        block_reason=reason,
                        triggered_patterns=triggered,
                        fallback_recommended=True,
                    )

        # Mode-specific ek kontroller
        if mode == SafetyMode.HIGH_RISK:
            # high_risk modda mizah kalıntıları olabilir → ek çıkartma
            # Örn: ünlem işaretleri, emoji yoğunluğu kontrolü (basit)
            if text.count("!") > 2 or self._emoji_count(text) > 2:
                logger.info("HIGH_RISK mode: tone too cheerful, recommending fallback")
                return SafetyResult(
                    passed=False,
                    filtered_text="",
                    block_reason=BlockReason.PROHIBITED_TOPIC,
                    triggered_patterns=["high_risk_tone_check"],
                    fallback_recommended=True,
                )

        return SafetyResult(
            passed=True,
            filtered_text=text,
            triggered_patterns=triggered,
        )

    def _emoji_count(self, text: str) -> int:
        # Basit emoji sayacı (tüm Unicode emoji kapsamlı değil ama yeterli)
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map
            "\U0001F1E0-\U0001F1FF"  # flags
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+",
            flags=re.UNICODE,
        )
        return len(emoji_pattern.findall(text))

    def should_show_resources(
        self,
        mode: SafetyMode,
        user_message: Optional[str] = None,
    ) -> bool:
        """
        High_risk modda profesyonel destek kaynak linkini göster.
        Kullanıcı mesajı intihar/self-harm anahtar kelimeleri içeriyorsa
        ek olarak göster.
        """
        if mode == SafetyMode.HIGH_RISK:
            return True
        if user_message:
            risk_keywords_tr = [
                "intihar", "kendime zarar", "yaşamak istem",
                "ölmek isti", "bitirmek isti",
            ]
            risk_keywords_en = [
                "suicide", "kill myself", "self harm", "self-harm",
                "want to die", "end my life",
            ]
            lowered = user_message.lower()
            if any(k in lowered for k in risk_keywords_tr + risk_keywords_en):
                return True
        return False
