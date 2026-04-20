# CLAUDE.md — Nuveli Agent Memory

Bu dosya Cursor, Claude Code ve benzeri coding agent'lar için sabit bağlam kaynağıdır.
Her büyük promptun başında bu dosyanın içeriği aktif tutulmalıdır.

---

## Proje Kimliği

- **Uygulama adı:** Nuveli
- **Tagline:** AI Calorie Coach
- **Destek:** support@nuveli.com.tr
- **Platform:** Flutter (iOS + Android, tek kod tabanı)

---

## Sabit Üst Kurallar

1. **Wellness uygulamasıdır.** Tıbbi teşhis, tedavi, klinik diyet planı veya doktor/diyetisyen yerine geçen yönlendirme üretme.
2. **V2/V3 özellik ekleme.** Sadece `docs/product/mvp-scope.md` içindeki özellikler geliştirilebilir.
3. **Wellness sınırı kırılamaz.** `docs/protocols/safety-wellness-boundary.md` her zaman geçerlidir.
4. **Kod sade olacak.** Gereksiz abstraction ekleme. Test edilebilirlik önceliklidir.
5. **Her görev sonunda** şunları yaz: değişen dosyalar, eksikler, test adımları.

---

## Stack Özeti

```
Flutter          → Mobile (iOS + Android)
FastAPI          → Backend
Supabase         → Auth, PostgreSQL DB, Storage
RevenueCat       → Subscription yönetimi
FCM              → Push notification
Firebase Analytics / Crashlytics → Analytics & crash
OpenAI Vision    → Yemek fotoğrafı analizi
OpenAI TTS       → Koç sesli yanıtı (kısa)
```

---

## Klasör Yapısı — Flutter

```
app/lib/
├── core/
│   ├── config/
│   ├── routing/
│   └── theme/
├── features/
│   ├── onboarding/
│   ├── meal/
│   ├── home/
│   ├── coach/
│   ├── premium/
│   └── settings/
└── shared/
    └── widgets/
```

## Klasör Yapısı — Backend

```
backend/app/
├── api/
│   └── routes/
├── core/
├── db/
├── schemas/
└── services/
```

---

## Kritik Protokol Dosyaları

| Dosya | Konu |
|-------|------|
| `docs/protocols/coach-ai-protocol.md` | Koç AI davranış kuralları |
| `docs/protocols/meal-analysis-ai-protocol.md` | Yemek analizi AI kuralları |
| `docs/protocols/nutrition-guidance-protocol.md` | Beslenme rehberliği sınırları |
| `docs/protocols/safety-wellness-boundary.md` | Güvenlik ve wellness sınırı |

---

## Premium Model Özeti

- **Free:** Günlük sınırlı meal analizi, temel koç
- **Trial:** 7 gün tam özellik
- **Premium:** Sınırsız analiz, gelişmiş koç, haftalık/aylık özet

Feature gating detayı: `docs/product/feature-gating.md`

---

## Yasaklı Davranışlar

- `calori deficit` sonuçlarını dramatize etme
- Kullanıcıyı kötü gün için suçlayan dil üretme
- Tıbbi referans verme (doktor, diyetisyen, klinik)
- 800 kcal altı hedef önerme
- Telafi davranışı (purging, aşırı egzersiz) ima etme
