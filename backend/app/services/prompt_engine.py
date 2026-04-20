"""
Prompt Engine
DecisionEngine kararına göre OpenAI system + user promptlarını oluşturur.
Koç AI protokolüne (docs/protocols/coach-ai-protocol.md) birebir uyar.
"""
from .decision_engine import CoachDecision


BASE_SYSTEM_PROMPT = """Sen Nuveli'nin AI koçusun. Bir wellness arkadaşısın.

KATI KURALLAR (asla ihlal etme):
- Tıbbi teşhis, tedavi veya ilaç tavsiyesi VERME.
- Klinik diyet planı HAZIRLAMA.
- Kullanıcıyı yargılama, suçlama veya küçümseme.
- Aşırı kısıtlama (800 kcal altı, hiç yemeden) ÖNERME.
- Telafi davranışı (purging, aşırı egzersiz) İMA ETME.
- "Doktor", "klinik", "tedavi", "semptom" kelimelerinden KAÇIN.

YANIT FORMATI:
- MAKSIMUM 3 cümle.
- Kısa, samimi, yargısız.
- Sıcak ama bilgili. Arkadaşça ama profesyonel değil.
- Türkçe yaz.
"""

PERSONA_PROMPTS = {
    "supportive": "Nazik ve sakin bir tonda konuş. Empati önce gelir.",
    "motivating": "Enerjik ve hedef odaklı bir tonda konuş. Motive et.",
    "realistic": "Doğrudan ama şefkatli bir tonda konuş. Gerçekçi ol.",
}

TONE_PROMPTS = {
    "gentle": "Kullanıcı zor bir günde. Önce dinle, sonra nazikçe destekle. Çözüm önerme.",
    "celebrate": "Kullanıcı iyi bir gün geçirmiş. İlerlemesini kutla ama abartma.",
    "invite": "Kullanıcı henüz bir şey kaydetmemiş. Küçük bir eyleme davet et.",
    "neutral": "Standart destekleyici ton.",
}


class PromptEngine:

    def build_messages(
        self,
        decision: CoachDecision,
        user_message: str,
        conversation_history: list[dict] | None = None,
    ) -> list[dict]:
        """
        OpenAI chat.completions için messages listesi oluşturur.
        """
        system_prompt = self._build_system_prompt(decision)
        messages = [{"role": "system", "content": system_prompt}]

        # Son 6 mesajı context olarak ekle (token tasarrufu)
        if conversation_history:
            for msg in conversation_history[-6:]:
                role = "assistant" if msg["role"] == "coach" else "user"
                messages.append({"role": role, "content": msg["content"]})

        messages.append({"role": "user", "content": user_message})
        return messages

    def _build_system_prompt(self, decision: CoachDecision) -> str:
        parts = [BASE_SYSTEM_PROMPT]

        persona_hint = PERSONA_PROMPTS.get(decision.persona, PERSONA_PROMPTS["supportive"])
        parts.append(f"\nPERSONA: {persona_hint}")

        tone_hint = TONE_PROMPTS.get(decision.tone, TONE_PROMPTS["neutral"])
        parts.append(f"\nTON: {tone_hint}")

        if decision.context:
            ctx = decision.context
            ctx_parts = []
            if ctx.get("meals_today") is not None:
                ctx_parts.append(f"Bugün {ctx['meals_today']} öğün kaydı var")
            if ctx.get("last_mood"):
                mood_tr = {
                    "great": "harika", "good": "iyi", "neutral": "normal",
                    "bad": "zor", "rough": "çok zor",
                }.get(ctx["last_mood"], ctx["last_mood"])
                ctx_parts.append(f"Son check-in: {mood_tr}")
            if ctx.get("meals_last_7_days") is not None:
                ctx_parts.append(f"Son 7 günde {ctx['meals_last_7_days']} öğün kaydı")

            if ctx_parts:
                parts.append(f"\nBAĞLAM: {'. '.join(ctx_parts)}.")

        return "\n".join(parts)
