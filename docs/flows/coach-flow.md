# Koç Akışı

Bu belge, kullanıcı ile Nuveli koçu arasındaki etkileşimin tüm yüzeylerini tanımlar.

---

## Genel İlke

**Koç bir arkadaştır, terapist değildir, doktor hiç değildir.** Kısa konuşur, yargılamaz, çözüm dayatmaz. Kullanıcı için burada olduğunu hissettirir, sonra yoldan çekilir.

**Temel kural:** Koç her zaman kullanıcının isteği üzerine konuşur. Kendi başına uzun monologlar açmaz.

---

## Koç'un 3 Yüzeyi

Koç uygulamada 3 farklı yerde görünür:

1. **Home koç kartı** (pasif, günlük nabız)
2. **Koç sohbet ekranı** (aktif, istek üzerine)
3. **Durum-bazlı otomatik mesajlar** (kurtarma günü, hedef ulaşımı, vb.)

---

## 1. Home Koç Kartı

Home ekranının ortalarında bir kart. Koç'un sana bugün söylemek istediği kısa bir mesaj.

### Görünüm
- Başlık: "Koçun"
- 1-2 cümle koç mesajı
- Sağda avatar (seçilen persona'ya göre)
- Tap → koç sohbet ekranına git

### İçerik kuralları

**Neden buradayım?** diye 4 farklı sebep var, koç servisi hangisini göstereceğine karar verir:

#### Durum A — Bugün hiç kayıt yok (saat 11:00 sonrası)
> "Merhaba. Bugünü nasıl başladın?"
> "Açlık seni çağırıyor mu? Ufak bir şey ekleyelim mi?"

#### Durum B — Dün kötü bir gündü (check-in = rough/bad)
> "Dün zordu. Bugün nasıl hissediyorsun?"
> "Yeni gün, yeni alan. Seninle buradayım."

#### Durum C — İyi gidiyor (streak 3+ gün)
> "Üst üste 5 gün kayıt. Bu süreklilik iyi."
> "Ritmini yakaladın. Devam."

#### Durum D — Normal gün, bir şey söyleyecek yok
> "Bugün nasıl hissediyorsun? Seni dinliyorum."
> (Fallback copy'den rastgele)

### Karar — neden sabit bir mesaj değil, context'e göre

Aynı "Bugün nasıl hissediyorsun?" mesajını her gün görmek koç ilişkisini yapay yapar. Context-aware mesaj sistem zeka hissi verir (gerçekten öyle).

### Karar — neden kartta iki satırdan fazla yok

3+ satır kart, görsel yük. Üstelik uzun mesajlar için sohbet ekranı var. Home kartı davet olmalı, monolog değil.

---

## 2. Koç Sohbet Ekranı

Kullanıcı koçla uzun konuşmak istediğinde açılan ekran.

### Ekran yapısı
- AppBar: "Koçun" + seçili persona adı
- Mesaj listesi (WhatsApp-tarzı bubble'lar)
- Alt input + gönder butonu
- Hiç konuşma yoksa: empty state "Merhaba! Nasıl hissediyorsun?"

### Mesaj kuralları

**Koç mesajı:**
- Maksimum 3 cümle
- Bold, italic, emoji (çok sınırlı, sadece anlamlıysa)
- Soru ile bitebilir ama her zaman değil
- Fallback copy bir mesajsa, kullanıcıdan saklanır (görsel olarak aynı)

**Kullanıcı mesajı:**
- Uzunluk sınırı yok
- Kopyalanabilir, uzun basınca opsiyonlar açılır

### Tipik sohbet örüntüsü

```
Kullanıcı: Bugün çok yedim
Koç: Çok yemek bazen olur. Kendine baskı yapma. Ne yedin?
Kullanıcı: Akşam arkadaşlarla yedik, pasta, pizza...
Koç: Sosyal yemek farklı bir şey, kutlamanın parçası. Yarın farklı bir gün.
Kullanıcı: Suçlu hissediyorum
Koç: Seni anlıyorum. Ama suçluluk iyi bir yakıt değil. Bugünü nasıl sonlandırmak istersin?
```

### Sesli yanıt (Premium)

Koç mesajının altında küçük bir oynatıcı:
- "▶ Dinle" butonu
- Tıklayınca TTS ile kısa (max 2 cümle) sesli yanıt oynar

### Karar — neden sadece premium

TTS OpenAI API maliyeti var. Free kullanıcıda limit yerine "premium özellik" olarak ayırmak, daha sürdürülebilir.

### Karar — neden tüm mesajlar için değil, sadece talep üzerine

Her yanıtı otomatik oynatmak kullanıcıyı şaşırtır (public yerde ses çıkar). Opsiyonel tap daha doğru.

---

## 3. Durum-Bazlı Otomatik Mesajlar

Koç bazı anlarda proaktif bir mesajla belirir. Bu mesajlar push bildirim olarak veya uygulama içi kart olarak görünür.

### Tetikleyiciler

#### 3.1 Kurtarma Günü
**Tetik:** Dün kaydı yok + bugün de henüz yok + saat 14:00 sonrası
**Mesaj:** "Düne kaydın yoktu. Bugüne yeni başlangıç yapalım mı?"
**CTA:** "Başla" → Home'a geri döner, empty state kart davet eder

#### 3.2 Günlük Check-in Daveti
**Tetik:** Saat 20:00-22:00, bugün check-in yapılmamış
**Mesaj:** "Bugünü nasıl geçirdin?"
**CTA:** Check-in modal'ını açar

#### 3.3 Streak Milestone
**Tetik:** 7 gün üst üste kayıt
**Mesaj:** "7 gün. Süreklilik oldu. Seninle gurur duyuyorum."
**CTA:** Yok, sadece his

#### 3.4 Hedef Yakın
**Tetik:** Günlük kalori hedefi %85-95 arasında
**Mesaj:** "Günü dengeli kapatıyorsun. Son birkaç yüz kalori varsa, hafif bir ara öğün fikri mi?"
**CTA:** Yok

#### 3.5 Bildirim KAPALIYSA
**Kart olarak görünür** (push yerine) — home'da küçük bir banner

### Karar — neden bu kadar sık proaktif değil

Bir uygulamanın en sinir bozucu yanı sürekli bildirim. Koç günde MAX 1 proaktif mesaj atar (kullanıcı uygulamaya gelmemişse). Sessiz saatlere (22:00-08:00) uyar.

### Karar — neden push + kart paralel

Bildirim izni vermemiş kullanıcıyı da uyarmak lazım, ama sinir etmeden. Kart, uygulamaya girince görünür; push girmiyorsa.

---

## 4. Risk Durumlarında Koç

Kullanıcı mesajında risk kelimesi (kriz, yeme bozukluğu, aşırı kısıtlama) varsa, koç farklı davranır. Ayrıntı için `docs/protocols/safety-wellness-boundary.md`.

### Kısa özet

**Crisis (intihar, kendine zarar):** AI tamamen bloke. Sabit güvenlik metni gösterilir. ALO 182 yönlendirmesi. Başka hiçbir UI yok.

**Distress (yeme bozukluğu sinyalleri):** Koç sınırlı ton kullanır, uzman desteği öner.

**Low-intake (aşırı kısıtlama kelimeleri):** Koç nazik nüdge verir, kısıtlamayı körüklemez.

### Karar — neden AI kullanılmaz crisis'te

AI halüsinasyon yapabilir, yanlış şey söyleyebilir. Crisis'te risk çok yüksek. Sabit metin garantili doğru.

---

## 5. Persona Farkları

3 persona: Destekleyici, Motive Edici, Gerçekçi.

Aynı durumda farklı yanıt örnekleri:

**Kullanıcı:** "Bugün sporda zorlandım."

- **Destekleyici:** "Zorlandığını görmek cesaret. Kendine bugün biraz şefkatli ol."
- **Motive edici:** "Zorluk büyüme demek. Yarın daha güçlü dönersin."
- **Gerçekçi:** "Her gün aynı enerji olmaz. Bugünkün bu, tamam."

### Karar — persona seçimi değiştirilebilir olmalı

Ayarlar > Koç > Persona değiştir. Kullanıcı bir hafta sonra "destekleyici çok yumuşak, motive edici dene" diyebilir. Bu tercihe saygı.

---

## 6. Fallback Copy

AI her zaman çalışmaz. Hata durumunda koç yine yanıt vermeli — sanki AI yanıtıymış gibi görünen hazır metinler kullanır.

Kategori bazında:
- **Greeting:** Selamlaşma durumları
- **Neutral:** Genel amaçlı
- **Encouragement:** Başarı anları
- **Tough:** Kullanıcı zor günde

Her kategoride 3-5 varyant. Rastgele seçilir, tekrar engellenir (son 3'ü tekrar gösterme).

### Karar — kullanıcıya "AI şu an çalışmıyor" DEMEYİZ

Kullanıcı teknik hatayı bilmek istemez. Fallback mesaj sessizce devreye girer, görsel olarak AI mesajıyla aynıdır. Backend'de `is_fallback: true` olarak işaretlenir (analytics için).

---

## 7. Limit Aşımı (Free Tier)

Free kullanıcı günde 5 koç mesajı hakkı var. 6. mesajda:

**Yanıt yerine:**
> "Bugün beş mesaj attık — güzel konuştuk. Yarın devam edelim, ya da Pro ile sınırsız sohbet et."
> [Pro'ya Geç] [Yarın Devam]

### Karar — neden "güzel konuştuk" dili

"Limit aşıldı" kötü hissettirir. "Güzel konuştuk" ilişkinin değerine vurgu yapar, "ne kazandık" değil "ne paylaştık" hissi.

### Karar — neden 5 mesaj

3 çok az (kullanıcı değer hissedemez), 10 çok fazla (trial gerekçesi zayıflar). 5 makul orta.

---

## 8. Yapılmayanlar

- **Koç sesi seçimi** (erkek/kadın) — V2, maliyet yüksek, değer belirsiz.
- **Grup koçluk** — hiç yok, tamamen 1-1 ilişki.
- **Koç günlüğü** ("bugün 10 kişi şöyle dedi") — gizlilik ve değer açısından gereksiz.
- **Koç ile video/arama** — asla. Bu wellness app, terapi değil.
- **Koç şikayet/feedback sistemi** — Ayarlar > Destek genel amaçlı, ayrı "koça şikayet" gereksiz.

---

## 9. Metrikler

- `coach_message_sent` (is_fallback, risk_level)
- `coach_voice_played`
- `coach_card_tapped` (trigger_type)
- `coach_limit_reached`
- `coach_persona_changed` (from, to)
- `recovery_day_started`

**Hedef:**
- Home koç kartı tap rate: %15+ (kullanıcı kartı umursuyor)
- Sohbet mesaj uzunluğu ortalama: 2-3 cümle her taraf
- Fallback copy oranı: %5'ten az (AI güvenilir çalışıyor demek)
