# Güvenlik & Wellness Sınırı

Bu dosya Nuveli'nin tüm katmanlarında uygulanması zorunlu güvenlik sınırlarını tanımlar.
**Bu kurallar hiçbir özellik geliştirmesinde ihlal edilemez.**

---

## Temel Sınır

Nuveli bir **wellness uygulamasıdır**, sağlık hizmet sağlayıcısı değildir.

---

## Tetikleyici Kelime Listesi (Risk Tarama)

Backend ve AI yanıtları aşağıdaki kelime gruplarını tarar:

**Grup A — Zarar (Yüksek Risk)**
- "kendime zarar", "kendimi incitmek", "intihar", "ölmek istiyorum"

**Grup B — Yeme Bozukluğu İmgeleri**
- "kusuyorum", "laksatif", "purge", "aç kalıyorum", "hiç yemiyorum"

**Grup C — Aşırı Kısıtlama**
- "500 kalori", "800 kalori", "hiç yemeden"

---

## Risk Moduna Göre Yanıt

| Risk Seviyesi | Tetikleyici | Sistem Davranışı |
|---------------|-------------|-----------------|
| `low` | Hafif negatif check-in | Empatik koç yanıtı |
| `medium` | Grup B veya C kelimeleri | Koç desteği + "bir uzmana danışmayı düşünür müsün?" |
| `high` | Grup A kelimeleri | Sabit güvenlik metni + Türkiye kriz kaynakları |
| `block` | Açık zarar planı | AI yanıt üretmez, sadece sabit kriz metni |

---

## Kriz Metni (Sabit — Değiştirilemez)

```
Seninle ilgili endişeleniyorum. Şu an zor bir yer olabilir.

Yardım almak için:
• ALO 182 — Psikolojik Destek Hattı (7/24)
• 182 numaralı hattı arayabilirsin.

Buradayım, ama profesyonel destek çok daha fazlasını yapabilir.
```

---

## Uygulama Kuralları

- Bu metin uygulama içinde hiçbir zaman kişiselleştirilemez veya dinamik değiştirilemez.
- Kriz ekranında başka UI bileşeni veya CTA bulunmaz.
- Backend bu metni hardcoded olarak tutar; AI üretemez.
- Kod review'da safety kuralı ihlali → PR merge edilmez.

---

## Yaş Kapısı

- Uygulama 18 yaş altına hizmet vermez.
- Welcome ekranında checkbox zorunludur: "18 yaşında veya daha büyüğüm"
- Bu bypass edilemez.

---

## Özel Durum Beyanı

Onboarding sırasında kullanıcı beyan ettiği özel durumlar (hamilelik, yeme bozukluğu geçmişi, kronik hastalık) kalıcı olarak `coach_preferences` tablosunda saklanır ve koç motor kararlarını etkiler.
