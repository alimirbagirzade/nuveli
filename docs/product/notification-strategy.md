# Bildirim Stratejisi

Bu belge, Nuveli'nin push notification, uygulama içi kart ve zamanlama stratejisini tanımlar.

---

## Temel İlke

**Bildirim bir rahatsızlıktır — ta ki değer katana kadar.** Her bildirim kullanıcının dikkatini çalıyor. O dikkati hak ediyor muyuz? Her bildirim için bu soruyu sormazsak, kullanıcı izni kaldırır ve bir daha geri veremeyiz.

**Kural:** Bir bildirim, kullanıcının hayatında somut bir şey değiştirmediyse, gönderilmemeli.

---

## Bildirim Türleri

### 1. Alışkanlık hatırlatıcıları
Öğün ekleme, check-in, haftalık özet.

### 2. Koç mesajları
Proaktif destek, kurtarma davetleri.

### 3. Sistem bildirimleri
Trial sona ermek üzere, abonelik sorunu, güvenlik.

### 4. Motivasyonel
Streak kutlamaları, milestone'lar.

---

## Günlük Bildirim Takvimi (varsayılan)

| Saat | Bildirim | Koşul |
|------|----------|-------|
| 08:30 | Günaydın nudge | Opsiyonel, ilk hafta göstermez |
| 12:30 | Öğle yemeği hatırlatıcısı | Bugün henüz kayıt yoksa |
| 19:00 | Akşam yemeği hatırlatıcısı | Bugün akşam kaydı yoksa |
| 21:00 | Günlük check-in daveti | Bugün check-in yapılmamışsa |
| Pazartesi 10:00 | Haftalık özet hazır | Premium için |

**Maksimum günlük:** 3 bildirim (normal kullanıcı), 4 (premium + haftalık özet günü).

**Sessiz saatler:** 22:00 - 08:00 (kullanıcı ayarlayabilir). Bu aralıkta hiçbir bildirim gönderilmez.

---

## Bildirim Kuralları

### Genel yazım kuralları

**Uzunluk:** Maksimum 60 karakter (iOS kilit ekranı preview limiti). Uzatmayı zorlamaz.

**Dil:**
- Türkçe, samimi
- Soru veya davet
- Emir kipi yok ("ye" değil "yemek ekleyelim")

**Kullanıcı adı:** Kullanma. Gereksiz ve bazen rahatsız edici.
- ❌ "Ali, öğle yemeği zamanı"
- ✅ "Öğle yemeğini eklesek mi?"

**Emoji:** Çok sınırlı. Zorunlu değil. Kötü kullanım olursa hiç kullanma.

### Kategori kopyaları

#### Öğün hatırlatıcısı

**12:30 — öğle:**
- "Öğle yemeğini eklesek mi?"
- "Bugün öğlen ne yedin?"
- "Kısa bir fotoğraf — hepsi bu."

**19:00 — akşam:**
- "Akşam yemeğin nasıldı? Ekleyelim."
- "Bir öğün daha, bir gün daha."
- "Günü özetleyelim mi?"

**Kurallar:**
- Aynı bildirim üst üste gönderilmez (son 3 mesaj hafızada)
- Kullanıcı zaten öğle kaydetmişse 12:30 bildirimi gelmez
- Context-aware: hafta sonu mesajları biraz daha rahat

#### Check-in daveti

**21:00:**
- "Bugünü nasıl geçirdin?"
- "Bugün nasıldı — bir saniye ayırır mısın?"
- "Gün bitmeden bir check-in?"

**Kural:**
- Haftada en fazla 4 gün bu bildirim (her gün sıkıcı)
- Cumartesi ve pazar akşamları opsiyonel (tatil günü pozitif algı)

#### Haftalık özet

**Pazartesi 10:00:**
- "Geçen haftan hazır."
- "Bir haftalık örüntü — bir bakar mısın?"

**Kural:**
- Sadece premium kullanıcıya gönderilir
- En az 3 günlük veri varsa (az veri = kötü özet)

#### Streak kutlama

- "7 gün üst üste. Süreklilik oldu." (7. gün)
- "30 gün. Bu bir alışkanlık artık." (30. gün)
- "3 ay oldu. Büyük iş." (90. gün)

**Kural:**
- Sadece 7, 14, 30, 60, 90, 180, 365. günlerde
- Her gün değil, her milestone'da bir kere
- Gönderim zamanı: akşam 20:00

#### Kurtarma daveti

- "Dün kayıt yoktu. Bugün küçük bir başlangıç?"
- "Geri dönmek istersen buradayım."

**Kural:**
- Sadece 2+ gün boşluk olduğunda
- Haftada max 1 kez
- Saat 14:00 (sabah çok erken, akşam çok geç)

#### Koç proaktif mesaj

- "Bugün bir şey söylemek istiyorum — açar mısın?"

**Kural:**
- Haftada max 1 kez
- Sadece context gerçekten anlamlıysa (son check-in + son kayıt örüntüsü)

---

## Koşullu Bildirimler (Smart Logic)

### "Bugün hiç kayıt yok" kontrolü

Öğün bildirimi gönderilmeden önce:
1. O gün için `meal_logs` sayısı kontrol edilir
2. 0 ise → bildirim gönderilir
3. 1+ ise → bildirim gönderilmez (aynı kategori için)

### "Aktif kullanıcı" kontrolü

Kullanıcı son 48 saatte uygulamayı açmış mı?
- **Evet** → soft nudge bildirimleri azalt
- **Hayır** → reactivation bildirimi devreye girebilir (haftada 1)

### "Trial aktif" kontrolü

Trial'ın son 2 günü:
- "Trialın 2 gün sonra bitiyor. İstediğin zaman iptal edebilirsin."
- "Trialın bugün sona eriyor. Pro'da kalmak istersen tek dokunuşta."

### "Özel durum" kontrolü

Kullanıcı hamilelik/eating disorder history işaretlediyse:
- Kalori hedefi odaklı bildirimler **gönderilmez**
- "Hedefinin %80'indesin" gibi sayısal bildirimler yok
- Sadece soft, nötr davetler (check-in, koç)

---

## Kullanıcı Ayarları

### Ayarlar > Bildirimler ekranında

```
┌─────────────────────────────────────┐
│  Öğün hatırlatıcıları       [ ● ON ]│
│  Koç nüdgleri               [ ● ON ]│
│  Haftalık özet              [ ● ON ]│
│                                     │
│  ────────────────────────           │
│  Sessiz Saatler                     │
│                                     │
│  Başlangıç         22:00 →          │
│  Bitiş             08:00 →          │
│                                     │
└─────────────────────────────────────┘
```

### Kural

3 kategori bağımsız. "Haftalık özet istemiyorum" dediğinde diğerleri açık kalır. Granüler kontrol.

### İzin akışı

- Onboarding sırasında "ne zaman rahatsız etmeyelim?" ekranı (default ON)
- iOS native permission popup sonra gelir
- Reddederse uygulama çalışmaya devam eder — sadece push yok

### Geri kazanma

İlk seferde reddedilmişse, 2 hafta sonra uygulama içi soft prompt:
> "Bildirim açmak ister misin? Günlük küçük hatırlatıcılarla kolaylaşır."
> [ Ayarlara Git ] [ Şimdi değil ]

İlgiliyse Settings'e yönlendir (iOS'te native permission tekrar gösterilmez, manual Settings şart).

---

## Bildirime Tıklama → Nereye Gider

### Deep link stratejisi

Her bildirim bir ekrana gider:

| Bildirim | Deep link |
|----------|-----------|
| Öğün hatırlatıcısı | `/meal/capture` |
| Check-in daveti | home + check-in sheet auto-açık |
| Haftalık özet | `/progress/weekly` |
| Streak kutlama | home (yeni bir şey yok, normal dönüş) |
| Kurtarma | home + recovery kartı aktif |
| Trial bitiyor | `/paywall` |

### Karar — neden splash'tan geçmiyor

Bildirime tıklayıp splash bekletmek kullanıcıyı kaybettirir. Direkt hedef ekrana gider. Auth token yoksa auth'a, varsa ekrana.

---

## Uygulama İçi Kart vs Push

Push izni verilmemiş kullanıcı için bazı mesajlar **uygulama içi kart** olarak gösterilir.

### Push vs Card karşılığı

| Durum | Push | Card |
|-------|------|------|
| Günlük hatırlatıcı | Gönderilir | Gerek yok (kullanıcı uygulamayı açmadıysa zaten görmez) |
| Haftalık özet | Gönderilir | Pazartesi home'a girince kart |
| Kurtarma daveti | Gönderilir | Home'da büyük kart (gaza basılmaz) |
| Trial bitiyor | Gönderilir | Home'da üst banner |

### Kural

**Uygulama içi kart** kullanıcı uygulamada olduğunda görünür. Push ile paralel gönderilebilir — kullanıcı zaten oradaysa ekstra push göndermek gereksiz.

---

## Bildirim Sıklığı Hesabı

### İdeal haftalık plan (aktif kullanıcı)

- 5 günde öğün hatırlatıcısı (3+ gün atıyorsa azalt)
- 4 günde check-in daveti
- 1 pazartesi haftalık özet (premium)
- 0-1 motivasyonel/milestone

**Toplam: ~10-12 bildirim/hafta.**

### Çok fazla sınırı

Haftada 15+ bildirim gönderiyorsak sistem kendini korur:
- Low-engagement kullanıcı için → azalt
- High-engagement kullanıcı için → zaten açıyor, az yeter

### Sessiz hafta

Kullanıcı hiç engage etmiyor mu?
- 1 hafta uygulama açmadı → reactivation push (haftada 1)
- 2 hafta açmadı → son push (bu kullanıcıyı kaybediyoruz)
- 3 hafta açmadı → push bildirim durdur. Uygulama açarsa yeniden başlat.

---

## Bildirim İçeriğinde Yapılmayacaklar

### Yasaklı kalıplar

- ❌ **Fake urgency** — "Son 2 saat!", "Kaçırıyorsun!"
- ❌ **Guilt trip** — "3 gündür yoksun, seni özledim"
- ❌ **Clickbait** — "Bu sonuç seni şaşırtacak"
- ❌ **Gerçek olmayan bildirim** — "1 yeni mesajın var" (koç zaten yazmıyorsa)
- ❌ **Kişi yerine AI** — "Senin için özel bir hesaplama yaptım" (AI bildirim göndermez, sistem gönderir)
- ❌ **Emoji spam** — "🎉🔥💪✨"

### Yapılabileceği ama yapmadığımız

- **Arkadaş aktivitesi bildirimi** — sosyal özellik yok
- **Başarı karşılaştırması** — "Diğer kullanıcılar şundan iyi" 
- **Kilo değişikliği bildirimi** — "3 kilo verdin!" (hassas konu)

---

## Notification Sound & Haptic

### iOS

- **Default sound** — özel ses eklemiyoruz (iOS tarzı ses)
- **Badge icon** — evet, sayaç yok (kapanmayan sayaç rahatsız eder). Nokta gösterimi.

### Android

- **Default channel** + medium importance
- Vibration: default
- Ayrı ses: hayır

---

## Analytics

Her bildirim için ölç:

- `notification_sent` (category, user_id)
- `notification_delivered` (iOS/Android doğrulaması)
- `notification_opened` (tap oranı)
- `notification_dismissed` (kullanıcı swipe etti)
- `notification_action_taken` (hedef ekrana gittiğinde bir eylem yaptı mı)

### Başarı metrikleri

- **Open rate:** %15+ iyi, %25+ mükemmel
- **Dismiss rate:** %60+ ise o kategori fazla sık gönderilir demek
- **Action rate** (bildirim → bir kayıt): %30+ — gerçek değer katıyor

### Düşük performans sinyali

Eğer:
- Open rate < %8 → yeniden yazmak lazım
- Permission revoke oranı yüksek → çok fazla gönderiyoruz
- Uninstall ile korelasyon → bildirim stratejisi kullanıcıyı kaçırıyor

---

## A/B Test Fikirleri

### Test 1 — Öğün hatırlatıcı saati
- Varyant A: 12:30
- Varyant B: 13:00

Hangisinde kullanıcı yemek eklemiş olur?

### Test 2 — Check-in davetinin dili
- Varyant A: "Bugünü nasıl geçirdin?"
- Varyant B: "Kendini nasıl hissediyorsun?"

İkisi birbirine yakın. Hangisi daha çok eyleme geçiriyor?

### Test 3 — Streak mesajı
- Varyant A: "7 gün üst üste. Süreklilik oldu."
- Varyant B: "7 gün! Harika iş."

Which one gets higher retention next day?

---

## Yapılmayanlar

- **Rich notification** (görsel, buton) — karmaşık, değer belirsiz, v2
- **Scheduled from server** (real-time trigger) — MVP'de client scheduling yeterli
- **In-app chat benzeri "mesaj geldi" bildirimi** — koç gerçek zamanlı değil
- **Kategori + priority ayarları** — MVP'de 3 toggle yeterli
- **Bildirim geçmişi görüntüleme** — v2

---

## Özet

**Nuveli az, ama anlamlı bildirim gönderir. Kullanıcıya hatırlatıcı olmak değil, yanında olmak ister. Her bildirim, "bu gerçekten gerekli mi?" sorusundan geçtikten sonra gönderilir.**

Başardığımızda:
- Kullanıcı push iznini kapamaz
- Açılan bildirim oranı sektör ortalamasının üstünde
- Uygulama "yine ne istiyor" değil, "ah iyi ki hatırlattı" hissi uyandırır
