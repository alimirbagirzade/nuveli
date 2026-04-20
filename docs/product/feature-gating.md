# Feature Gating

Feature gating backend'den yönetilir. Client, `/premium/features` endpoint'inden feature state'i alır.

## Katmanlar

| Katman | Tanım |
|--------|-------|
| `free` | Ücretsiz kullanıcı |
| `trial` | 7 günlük deneme (tam premium erişim) |
| `premium` | Ücretli abonelik |

---

## Feature Matrix

| Özellik | Free | Trial | Premium |
|---------|------|-------|---------|
| Günlük meal analizi | 3 adet | Sınırsız | Sınırsız |
| Manuel meal girişi | ✓ | ✓ | ✓ |
| AI koç mesajı | 5/gün | Sınırsız | Sınırsız |
| Sesli koç yanıtı | ✗ | ✓ | ✓ |
| Su & kilo takibi | ✓ | ✓ | ✓ |
| Haftalık özet | ✗ | ✓ | ✓ |
| Aylık içgörü | ✗ | ✗ | ✓ |
| Boş gün & kurtarma | ✓ | ✓ | ✓ |
| İlerleme grafikleri | Temel | Tam | Tam |

---

## Gating Kuralı

- Tüm gate kararları backend'den gelir; client local'de feature açmaz.
- Free sürüm kullanıcıya değersiz hissettirilemez; temel döngü çalışmalıdır.
- Gate mesajları yargısız ve yönlendirici olmalıdır (paywalla zorla sürme yok).

---

## Limit Aşımı Davranışı

- Meal analizi limiti dolduğunda: paywall ekranı, şefkatli mesaj.
- Koç limiti dolduğunda: fallback copy ile destek, trial teklifi.
- Hard block yok; kullanıcı her zaman manuel girişe geçebilir.
