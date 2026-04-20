# Yemek Analizi AI Protokolü

## Temel İlke

Nuveli yemek analizi **yaklaşık tahmin** sunar. Kesin ölçüm iddiasında bulunmaz.  
Kullanıcıya her analizde bu bağlam iletilir.

---

## Analiz Akışı

```
Kullanıcı input (fotoğraf ve/veya metin açıklama)
    ↓
OpenAI Vision API çağrısı
    ↓
Sonuç parse + confidence skoru
    ↓
High confidence  → Direkt sonuç ekranı
Low confidence   → "Emin değilim" uyarısı + manuel düzenleme daveti
Tanımlanamayan   → Manuel giriş fallback
    ↓
Kullanıcı onaylar veya düzenler
    ↓
Confirmed meal_log kayıt
```

---

## Confidence Seviyeleri

| Seviye | Kriter | UI Davranışı |
|--------|--------|--------------|
| `high` | Yemek net tanımlandı | Sonucu göster, onayla |
| `medium` | Kısmi tanımlama | "Bu doğru mu?" uyarısı |
| `low` | Belirsiz görsel/metin | "Emin olamadım" + düzenleme alanı |
| `failed` | Tanımlama yapılamadı | Manuel giriş fallback |

---

## AI Prompt Kuralları

- Yaklaşık kalori ve makro (protein, karbonhidrat, yağ) tahmin et.
- Porsiyon belirsizse orta porsiyon varsay ve bunu kullanıcıya bildir.
- Tıbbi veya klinik yorum yapma.
- Yemeği değerlendirme ("bu sağlıksız" gibi ifade üretme).
- Sadece besin tahmini döndür.

---

## Veri Saklama

- `meal_analysis_results` → AI ham tahmini (değişmez)
- `meal_logs` → Kullanıcının onayladığı/düzenlediği final kayıt

AI tahmini asla üzerine yazılmaz; audit trail korunur.

---

## Hata Senaryoları

| Hata | Davranış |
|------|---------|
| API timeout | "Şu an analiz yapamıyorum, manuel giriş yapar mısın?" |
| Görsel net değil | Low confidence akışı |
| İçerik uygunsuz | Neutral mesaj, manuel giriş yönlendirme |
| Rate limit | Kullanıcıya limit bilgisi + manual fallback |
