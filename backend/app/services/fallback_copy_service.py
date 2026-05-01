"""
backend/app/services/fallback_copy_service.py

Fallback Copy Service — AI cevabı üretemediğinde veya safety
filtresinden geçemediğinde devreye giren static metin kütüphanesi.

PRD §10.1: "AI sustuysa fallback metin vardır."
PRD §11.4: "Template Library + AI Rewrite + Locale Rules + Safety Filter"

İlk sürümde versioned JSON. V2'de Supabase'e taşınabilir.
"""

from __future__ import annotations
import json
import logging
import random
from pathlib import Path
from typing import Optional

from app.services.decision_engine import (
    CoachPersona,
    Surface,
    SafetyMode,
)

logger = logging.getLogger(__name__)


# Default content path — services/content/coach_fallbacks.json
DEFAULT_CONTENT_PATH = Path(__file__).parent / "content" / "coach_fallbacks.json"


class FallbackCopyService:
    def __init__(self, content_path: Optional[Path] = None):
        self.content_path = content_path or DEFAULT_CONTENT_PATH
        self._content: dict = {}
        self._load()

    def _load(self) -> None:
        try:
            with open(self.content_path, "r", encoding="utf-8") as f:
                self._content = json.load(f)
            logger.info(
                "Loaded fallback copy: version=%s entries=%d",
                self._content.get("version", "?"),
                len(self._content.get("entries", {})),
            )
        except FileNotFoundError:
            logger.error(
                "Fallback content not found at %s. Using minimal hardcoded.",
                self.content_path,
            )
            self._content = self._minimal_fallback()
        except json.JSONDecodeError as e:
            logger.error("Fallback JSON parse error: %s", e)
            self._content = self._minimal_fallback()

    def get(
        self,
        persona: CoachPersona,
        surface: Surface,
        locale: str = "tr",
        safety_mode: SafetyMode = SafetyMode.NORMAL,
    ) -> str:
        """
        Persona × surface × locale × mode kombinasyonuna göre random
        bir fallback metni döner.

        Lookup sırası (en spesifikten en geneline fallback):
        1. {locale}.{persona}.{surface}.{mode}
        2. {locale}.{persona}.{surface}.normal
        3. {locale}.gentle.{surface}.normal      (gentle = en güvenli persona)
        4. {locale}.gentle.chat_response.normal  (en jenerik)
        5. Hardcoded minimal
        """
        entries = self._content.get("entries", {})

        candidates = self._lookup_candidates(
            entries, locale, persona.value, surface.value, safety_mode.value
        )

        if not candidates:
            return self._hardcoded_safe(locale, surface)

        return random.choice(candidates)

    def _lookup_candidates(
        self,
        entries: dict,
        locale: str,
        persona: str,
        surface: str,
        mode: str,
    ) -> list[str]:
        """JSON ağacında kademeli lookup."""
        # Try most specific
        paths = [
            (locale, persona, surface, mode),
            (locale, persona, surface, "normal"),
            (locale, "gentle", surface, "normal"),
            (locale, "gentle", "chat_response", "normal"),
        ]

        for path in paths:
            node = entries
            for segment in path:
                if isinstance(node, dict) and segment in node:
                    node = node[segment]
                else:
                    node = None
                    break
            if isinstance(node, list) and node:
                return node

        return []

    def _hardcoded_safe(self, locale: str, surface: str) -> str:
        """JSON yoksa veya bozuksa minimum güvenli cevap."""
        if locale == "en":
            return "I'm with you. Let's take a small step together."
        return "Yanındayım. Birlikte küçük bir adım atalım."

    def _minimal_fallback(self) -> dict:
        return {
            "version": "0.1.0-minimal",
            "entries": {
                "tr": {
                    "gentle": {
                        "chat_response": {
                            "normal": [
                                "Yanındayım. Bugün küçük bir adım yeterli.",
                                "Burada olduğun yetiyor. Devam edelim.",
                            ]
                        }
                    }
                },
                "en": {
                    "gentle": {
                        "chat_response": {
                            "normal": [
                                "I'm with you. A small step today is enough.",
                                "You being here is enough. Let's continue.",
                            ]
                        }
                    }
                },
            },
        }

    def reload(self) -> None:
        """Hot reload (admin endpoint için)."""
        self._load()
