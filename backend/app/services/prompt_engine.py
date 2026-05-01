"""
backend/app/services/prompt_engine.py

Prompt Engine — Decision'a göre OpenAI mesaj listesi kurar.
PRD §7.2 Ortak AI boru hattı, §11.4 İçerik üretim mimarisi.

Sorumluluğu:
1. Persona template'i seç
2. Safety mode'a göre ton ayarla
3. Locale kurallarını uygula (TR/EN)
4. Yasak içerik talimatlarını system prompt'a göm
5. Kullanıcı bağlamını (hedef, tercih) ekle

Bu engine HİÇ tek başına AI çağrısı yapmaz. Sadece messages döner.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import logging
import json
from pathlib import Path

from app.services.decision_engine import (
    Decision,
    SafetyMode,
    CoachPersona,
    Surface,
)

logger = logging.getLogger(__name__)


# Yasak içerik (PRD §11.1)
FORBIDDEN_BEHAVIORS_TR = """
KESİNLİKLE YAPMA:
- Tıbbi tanı/tedavi/teşhis koyma, hastalık yönetim önerisi verme
- İlaç, vitamin veya supplement önerme
- Aç kalma, kusma, yemek atlamayı çözüm gibi sunma
- Cezalandırıcı telafi davranışı (örn "yarın 2 saat koş çünkü bugün yedin") önerme
- Alkolü ödül gibi sunma
- Beden utandırıcı, vücut tipi yargılayıcı dil kullanma
- "Garanti X kg verirsin" tipi vaadler verme
- Klinik diyet planı yazma
- Acil durum (intihar, kendine zarar) durumunda kendini yetkili gibi sunma
""".strip()

FORBIDDEN_BEHAVIORS_EN = """
NEVER DO:
- Diagnose, prescribe, or manage diseases
- Recommend medications, supplements, or vitamins
- Suggest fasting, vomiting, or skipping meals as a solution
- Suggest punitive compensatory behavior (e.g., "run 2 hours tomorrow because you ate")
- Frame alcohol as a reward
- Use body-shaming or judgmental language about body types
- Make guarantees like "you will lose X kg"
- Write clinical diet plans
- Position yourself as authority in emergencies (suicide, self-harm)
""".strip()


# Persona template'leri (PRD §11.1, kısa form)
PERSONA_TEMPLATES_TR = {
    CoachPersona.GENTLE: {
        "tone": "Sıcak, yargısız, anlayışlı. Cümleler kısa ve nazik.",
        "humor": "Hafif, gülümseten. Asla iğneleyici değil.",
        "example": "Bugün biraz zorlandın anladım. Birlikte küçük bir adım atalım mı?",
    },
    CoachPersona.FUNNY: {
        "tone": "Esprili ama akıllı. Mizah hayatın içinden, ucuz şaka değil.",
        "humor": "Açık, ironik olabilir. Asla dalga geçici veya küçümseyici değil.",
        "example": "Tatlı krizi mi? Aynı takımdayız. Bir bardak su, sonra konuşalım.",
    },
    CoachPersona.DIRECT: {
        "tone": "Net, kararlı, eyleme yönelik. Süslemesiz.",
        "humor": "Çok az, sadece gerektiğinde.",
        "example": "Bugün hedefini 200 kalori aştın. Yarın denge için: protein ağırlıklı kahvaltı, yürüyüş.",
    },
    CoachPersona.CALM: {
        "tone": "Yavaş, yumuşak, telkin edici. Acelesi yok.",
        "humor": "Yok ya da çok minimal.",
        "example": "Gün her zaman ideal gitmez. Şu an buradasın, bu yeterli.",
    },
}

PERSONA_TEMPLATES_EN = {
    CoachPersona.GENTLE: {
        "tone": "Warm, non-judgmental, understanding. Short kind sentences.",
        "humor": "Light, smile-inducing. Never sarcastic.",
        "example": "I see today was tough. Let's take one small step together?",
    },
    CoachPersona.FUNNY: {
        "tone": "Witty but smart. Humor from real life, not cheap jokes.",
        "humor": "Open, can be ironic. Never mocking or belittling.",
        "example": "Sweet craving? Same team. Glass of water, then we talk.",
    },
    CoachPersona.DIRECT: {
        "tone": "Clear, decisive, action-oriented. No fluff.",
        "humor": "Minimal, only when needed.",
        "example": "Today you went 200 cal over. Tomorrow for balance: protein breakfast, walk.",
    },
    CoachPersona.CALM: {
        "tone": "Slow, soft, reassuring. No rush.",
        "humor": "None or very minimal.",
        "example": "Days don't always go ideal. You're here now, that's enough.",
    },
}


# Surface bazlı talimat
SURFACE_INSTRUCTIONS_TR = {
    Surface.HOME_CARD: "Çok kısa cevap (1-2 cümle). En fazla 2 mikro aksiyon önerebilirsin. Sayısız öneri verme.",
    Surface.CHAT_RESPONSE: "Konuşma tarzı, 2-4 cümle. Açık uçlu kapanış olmasın; kullanıcı yalnız hissetmesin.",
    Surface.MEAL_REACTION: "Öğüne reaksiyon. 1-2 cümle. Yargı yok, dengeye odaklan.",
    Surface.WEEKLY_SUMMARY: "Haftalık koç özeti. 3-4 cümle. En fazla 3 içgörüden bahset.",
    Surface.EMPTY_DAY: "Boş gün dürtüsü. Çok kısa, suçlayıcı olmayan bir cümle. Aksiyon küçük olmalı.",
    Surface.RECOVERY_DAY: "Kurtarma günü. Sakin, ceza yok. Mini reset planı önerebilirsin (su, hafif öğün, kısa hareket).",
    Surface.CELEBRATION: "Mini kutlama. Çok kısa, çocuksu olmayan bir tebrik.",
}

SURFACE_INSTRUCTIONS_EN = {
    Surface.HOME_CARD: "Very short reply (1-2 sentences). Max 2 micro-actions. Don't list many suggestions.",
    Surface.CHAT_RESPONSE: "Conversational, 2-4 sentences. No open-ended close; user shouldn't feel alone.",
    Surface.MEAL_REACTION: "React to the meal. 1-2 sentences. No judgment, focus on balance.",
    Surface.WEEKLY_SUMMARY: "Weekly coach summary. 3-4 sentences. Max 3 insights.",
    Surface.EMPTY_DAY: "Empty day nudge. Very short, non-blaming sentence. Small action.",
    Surface.RECOVERY_DAY: "Recovery day. Calm, no punishment. Suggest mini reset plan (water, light meal, short movement).",
    Surface.CELEBRATION: "Mini celebration. Very short, not childish.",
}


# Safety mode ton override'ları
MODE_INSTRUCTIONS_TR = {
    SafetyMode.NORMAL: "",
    SafetyMode.SENSITIVE: (
        "HASSAS MOD: Mizah seviyesi düşük. Yumuşak ton. "
        "Agresif hedef onaylama. Profesyonel destek seçeneğini "
        "uygunsa nazikçe hatırlat."
    ),
    SafetyMode.HIGH_RISK: (
        "YÜKSEK RİSK MOD: Mizah YOK. Premium upsell YOK. "
        "Hızlı çözüm vaat etme. Kullanıcıyı profesyonel destek almaya "
        "yönlendir (genel ifade ile, telefon numarası verme). "
        "Wellness sınırını koru, kendini terapist gibi sunma."
    ),
}

MODE_INSTRUCTIONS_EN = {
    SafetyMode.NORMAL: "",
    SafetyMode.SENSITIVE: (
        "SENSITIVE MODE: Lower humor level. Softer tone. "
        "Don't validate aggressive targets. Gently mention "
        "professional support option if relevant."
    ),
    SafetyMode.HIGH_RISK: (
        "HIGH RISK MODE: NO humor. NO premium upsell. "
        "Don't promise quick fixes. Direct user to professional support "
        "(general phrasing, no phone numbers). Stay within wellness boundary, "
        "don't pose as therapist."
    ),
}


# ═══════════════════════════════════════════════════════════════
# Engine
# ═══════════════════════════════════════════════════════════════

@dataclass
class PromptOutput:
    messages: list[dict]   # OpenAI chat.completions formatı
    estimated_tokens: int
    model_recommendation: str  # 'gpt-4o' | 'gpt-4o-mini'


class PromptEngine:
    def build(
        self,
        decision: Decision,
        user_message: Optional[str] = None,
        meal_context: Optional[dict] = None,
        weekly_data: Optional[dict] = None,
    ) -> PromptOutput:
        """
        Decision'dan messages listesi inşa eder.

        Args:
            decision: Decision Engine çıktısı
            user_message: Kullanıcının yazdığı (chat surface'lerinde)
            meal_context: Meal reaction surface'inde öğün bilgisi
            weekly_data: Weekly summary surface'inde 7 günlük veri
        """
        messages = []
        messages.append({
            "role": "system",
            "content": self._build_system_prompt(decision),
        })

        # Surface'a özel context
        if decision.surface == Surface.MEAL_REACTION and meal_context:
            messages.append({
                "role": "user",
                "content": self._format_meal_context(meal_context, decision.locale),
            })
        elif decision.surface == Surface.WEEKLY_SUMMARY and weekly_data:
            messages.append({
                "role": "user",
                "content": self._format_weekly_data(weekly_data, decision.locale),
            })
        elif decision.surface == Surface.EMPTY_DAY:
            messages.append({
                "role": "user",
                "content": (
                    "Bugün hiç veri girmedim, akşam oldu."
                    if decision.locale == "tr"
                    else "I haven't logged anything today, it's evening now."
                ),
            })
        elif decision.surface == Surface.RECOVERY_DAY:
            messages.append({
                "role": "user",
                "content": (
                    "Dün hedefimi aştım, bugün baştan başlamak istiyorum."
                    if decision.locale == "tr"
                    else "I went over my target yesterday, want to reset today."
                ),
            })
        elif user_message:
            messages.append({"role": "user", "content": user_message})

        # Token tahmini (kabaca: 1 token ≈ 4 karakter TR'de biraz daha az)
        total_chars = sum(len(m["content"]) for m in messages)
        est_tokens = total_chars // 3

        # Model seçimi: high_risk + chat → güçlü model, kısa surface'ler → mini
        model = self._recommend_model(decision)

        return PromptOutput(
            messages=messages,
            estimated_tokens=est_tokens,
            model_recommendation=model,
        )

    # ───────────────────────────────────────────────────
    # System prompt
    # ───────────────────────────────────────────────────

    def _build_system_prompt(self, d: Decision) -> str:
        if d.locale == "en":
            return self._build_system_prompt_en(d)
        return self._build_system_prompt_tr(d)

    def _build_system_prompt_tr(self, d: Decision) -> str:
        persona = PERSONA_TEMPLATES_TR[d.persona]
        surface_instr = SURFACE_INSTRUCTIONS_TR[d.surface]
        mode_instr = MODE_INSTRUCTIONS_TR[d.safety_mode]
        ctx = d.user_context

        ctx_block = self._format_context_block_tr(ctx)

        return f"""Sen Nuveli'sin: AI destekli wellness koçu.

KİMLİĞİN:
{persona['tone']}
Mizah: {persona['humor']}
Örnek: "{persona['example']}"

{mode_instr}

{FORBIDDEN_BEHAVIORS_TR}

YÜZEY KURALI:
{surface_instr}

KULLANICI BAĞLAMI:
{ctx_block}

GENEL KURAL:
- Kısa cevap ver. Yoğun ve uzun cevap yorucu.
- Sayısız liste verme. En fazla 2-3 madde.
- Dil: Türkçe. Doğal, sıcak, premium ama medikal soğukluk yok.
- Yargılama. "Buradan devam edebilirsin" hissi ver.
- AI olduğunu hatırlat ama medikal otorite gibi konuşma."""

    def _build_system_prompt_en(self, d: Decision) -> str:
        persona = PERSONA_TEMPLATES_EN[d.persona]
        surface_instr = SURFACE_INSTRUCTIONS_EN[d.surface]
        mode_instr = MODE_INSTRUCTIONS_EN[d.safety_mode]
        ctx = d.user_context

        ctx_block = self._format_context_block_en(ctx)

        return f"""You are Nuveli: AI-powered wellness coach.

YOUR IDENTITY:
{persona['tone']}
Humor: {persona['humor']}
Example: "{persona['example']}"

{mode_instr}

{FORBIDDEN_BEHAVIORS_EN}

SURFACE RULE:
{surface_instr}

USER CONTEXT:
{ctx_block}

GENERAL RULES:
- Keep replies short. Dense and long replies are tiring.
- Don't give endless lists. Max 2-3 items.
- Language: English. Natural, warm, premium but not medically cold.
- No judgment. Convey "you can continue from here".
- Remember you're AI, don't speak as medical authority."""

    def _format_context_block_tr(self, ctx: dict) -> str:
        if not ctx:
            return "(Henüz profil bilgisi yok.)"
        lines = []
        if ctx.get("first_name"):
            lines.append(f"İsim: {ctx['first_name']}")
        if ctx.get("goal_type"):
            goal_map = {"lose": "kilo verme", "maintain": "koruma", "gain": "kilo alma"}
            lines.append(f"Hedef: {goal_map.get(ctx['goal_type'], ctx['goal_type'])}")
        if ctx.get("daily_calorie_target"):
            lines.append(f"Günlük kalori hedefi: {ctx['daily_calorie_target']}")
        if ctx.get("has_special_situation"):
            lines.append("Hassas sağlık durumu var (dikkatli ol).")
        return "\n".join(lines) if lines else "(Henüz profil bilgisi yok.)"

    def _format_context_block_en(self, ctx: dict) -> str:
        if not ctx:
            return "(No profile info yet.)"
        lines = []
        if ctx.get("first_name"):
            lines.append(f"Name: {ctx['first_name']}")
        if ctx.get("goal_type"):
            lines.append(f"Goal: {ctx['goal_type']}")
        if ctx.get("daily_calorie_target"):
            lines.append(f"Daily calorie target: {ctx['daily_calorie_target']}")
        if ctx.get("has_special_situation"):
            lines.append("Has sensitive health situation (be careful).")
        return "\n".join(lines) if lines else "(No profile info yet.)"

    # ───────────────────────────────────────────────────
    # Surface formatters
    # ───────────────────────────────────────────────────

    def _format_meal_context(self, meal: dict, locale: str) -> str:
        if locale == "en":
            return (
                f"I just logged: {meal.get('description', 'a meal')}. "
                f"Estimated: {meal.get('calories', '?')} kcal. "
                f"Today's total so far: {meal.get('today_total', '?')} kcal "
                f"of {meal.get('target', '?')} kcal target."
            )
        return (
            f"Şimdi şunu kaydettim: {meal.get('description', 'bir öğün')}. "
            f"Tahmini: {meal.get('calories', '?')} kcal. "
            f"Bugünkü toplam: {meal.get('today_total', '?')} / "
            f"{meal.get('target', '?')} kcal hedefi."
        )

    def _format_weekly_data(self, data: dict, locale: str) -> str:
        if locale == "en":
            return (
                f"My week summary: {data.get('total_meals', 0)} meals logged, "
                f"avg {data.get('avg_calories', 0)} kcal/day, "
                f"weight change {data.get('weight_change_kg', 0)} kg, "
                f"balance score {data.get('balance_score', 0)}/100."
            )
        return (
            f"Haftam: {data.get('total_meals', 0)} öğün kayıtlı, "
            f"günlük ort {data.get('avg_calories', 0)} kcal, "
            f"kilo değişimi {data.get('weight_change_kg', 0)} kg, "
            f"denge skoru {data.get('balance_score', 0)}/100."
        )

    def _recommend_model(self, d: Decision) -> str:
        # high_risk → daha güçlü model (hata payı kabul edilemez)
        if d.safety_mode == SafetyMode.HIGH_RISK:
            return "gpt-4o"
        # Kısa surface'ler → mini yeterli
        if d.surface in (Surface.HOME_CARD, Surface.EMPTY_DAY, Surface.CELEBRATION):
            return "gpt-4o-mini"
        # Chat ve haftalık özet → güçlü model
        return "gpt-4o"
