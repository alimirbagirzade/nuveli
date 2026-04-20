"""
Fallback Copy Service
OpenAI yanıt üretemezse hazır metinler devreye girer.
Kullanıcı fark etmez — koç mesajı gibi görünür.
"""
import random


GREETING_FALLBACKS = [
    "Bugün nasıl hissediyorsun? Seni dinliyorum.",
    "Merhaba! Bugün küçük bir adımla başlayalım mı?",
    "Seni görmek güzel. Nasıl gidiyor?",
]

NEUTRAL_FALLBACKS = [
    "Her gün yeni bir başlangıç. Küçük bir adımdan başlayalım.",
    "Mükemmel olmak zorunda değilsin. İlerleme yeter.",
    "Devam ediyorsun — bu bile önemli.",
    "Kendine biraz alan ver, sonra devam ederiz.",
]

ENCOURAGEMENT_FALLBACKS = [
    "İyi gidiyorsun, devam.",
    "Süreklilik her şeyden önemli.",
    "Küçük kararlar büyük farklar yaratır.",
]

TOUGH_DAY_FALLBACKS = [
    "Zor bir gün olabilir. Sadece bugünle ilgilen, yarını yarına bırak.",
    "Biraz zorlanman çok normal. Kendine karşı şefkatli ol.",
    "Tek bir gün her şeyi değiştirmez. Derin nefes al.",
]


def get_fallback(kind: str = "neutral") -> str:
    """Rastgele bir fallback copy döndürür."""
    pool = {
        "greeting": GREETING_FALLBACKS,
        "neutral": NEUTRAL_FALLBACKS,
        "encourage": ENCOURAGEMENT_FALLBACKS,
        "tough": TOUGH_DAY_FALLBACKS,
    }.get(kind, NEUTRAL_FALLBACKS)
    return random.choice(pool)
