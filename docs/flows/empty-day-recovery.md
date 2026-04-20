# Boş Gün ve Kurtarma Günü Deneyimi

Bu belge, kullanıcının kaçırdığı veya zor geçen günlerde Nuveli'nin davranışını tanımlar. **Bu, uygulamanın en kritik farklılaşma noktasıdır.**

---

## Neden önemli

Kalori takibi uygulamalarının çöktüğü yer tam burasıdır. Kullanıcı:

1. Bir-iki iyi gün yapar.
2. Üçüncü gün kayıt tutamaz veya aşar.
3. Uygulamayı açar, "başarısızım" hisseder.
4. Birkaç gün açmaz.
5. Bir hafta sonra açar, daha kötü hisseder.
6. Siler.

Nuveli'nin işi bu döngüyü kırmak. Kötü günde kullanıcıyı utandırmak değil, karşılamak.

---

## İki farklı durum

### 1. Boş Gün
Dün (ve/veya bugün) hiç kayıt yok. Nedeni bilmiyoruz — meşguldü, unuttu, vazgeçti.

### 2. Kurtarma Günü
Dün bir şey oldu ("bad" veya "rough" check-in, ya da hedefin çok üstü/altı) ve kullanıcı bugün geri geliyor.

Bu iki durum farklı tasarlanır ama ruhu aynı: **yargılamama, karşılama, hafif geri dönüş.**

---

## Boş Gün — Tasarım

### Tetikleyiciler
- Dün hiç `meal_log` yok **VE/VEYA**
- Bugün saat 14:00 ve hala kayıt yok

### Home ekranında ne görür

Daily Summary Card yerine farklı bir kart:

```
┌─────────────────────────────────────┐
│                                     │
│        ☀  Yeni bir gün              │
│                                     │
│   Bugün henüz kayıt yok.            │
│   Başlamak için küçük bir adımla    │
│   başlayalım.                       │
│                                     │
│   [   İlk Öğünü Ekle   ]            │
│                                     │
└─────────────────────────────────────┘
```

### Metin kararları

**Asla yazmayacağımız:**
- ❌ "Dün hiç kayıt yapmadın" (suçlama)
- ❌ "Nerede kaldın?" (pasif agresif)
- ❌ "Hedefini unutma" (baskı)

**Yazdığımız:**
- ✅ "Yeni bir gün" (yüklü değil, taze)
- ✅ "Küçük bir adım" (eşik düşük)
- ✅ "Başlayalım" (biz, beraber)

### Koç kartı farkı

Normal koç kartı yerine:

> "Bugün henüz kayıt yok. Zorluk mu var, yoksa sadece yoğun mu?"

Ya da:

> "Açlık seni çağırıyor mu? Ufak bir şey ekleyelim mi?"

### Neden soru kullanıyoruz

Düz yargı dili kullanıcıyı savunmaya iter. Soru dili ona alan açar. **"Zorluk mu var?"** sorusu hem ilgi gösterir, hem de kullanıcının "evet zor" demesine fırsat tanır — koç orada devreye girer.

### Eylem

Kullanıcı "İlk Öğünü Ekle" derse → normal meal capture akışı. Hiçbir şey değişmez. Sanki ilk kez ekliyor gibi davranır.

**Önemli:** Boş gün kartından meal ekledikten sonra, küçük bir kutlama olmasın. Normal davranış. "Hoş geldin" pastası yok.

---

## Kurtarma Günü — Tasarım

Bu daha ince. Kullanıcı dün bir şey yaşadı, bugün geri döndü. Bu dönüşü değerli kılmak lazım.

### Tetikleyiciler
- Dün `check-in = bad` veya `rough` **VEYA**
- Dün toplam kalori hedefin %130 üstü veya %40 altı **VEYA**
- Dün mesajlarda risk kelimeleri geçmiş (distress/low_intake modu)

### Home ekranında ne görür

Daily Summary Card normal görünür. **Onun üstünde** kurtarma kartı:

```
┌─────────────────────────────────────┐
│  ○ KURTARMA GÜNÜ                    │
│                                     │
│  Dün zor geçmiş olabilir.           │
│  Bugünü birlikte yumuşakça          │
│  başlatmak ister misin?             │
│                                     │
│  [  Başla  ]      [  Şimdi değil  ] │
│                                     │
└─────────────────────────────────────┘
```

### İki buton

**"Başla"** → kurtarma planı ekranı açılır (aşağıda)
**"Şimdi değil"** → kart kaybolur, normal home görünür. Kullanıcıya alan ver.

### Karar — neden "şimdi değil" ikinci seçenek

Alternatif: tek "Başla" butonu, kullanıcı dismissal yok. Ama bu baskı yaratır. Kullanıcı kurtarma istemeyebilir — "kendi yolumda olurum" diyebilir. Ona saygı.

---

## Kurtarma Planı Ekranı

"Başla" tıklanınca açılan ayrı ekran.

### Yapı

```
┌─────────────────────────────────────┐
│  ← Geri                             │
│                                     │
│  ○ KURTARMA                         │
│                                     │
│  Mini reset                         │
│  3 küçük adım, üzerinden            │
│  atlayabilirsin.                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  1. Bir bardak su iç        │   │
│  │  [  Tamam  ]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  2. Bugün nasıl hissediyorsun?│ │
│  │  [  Söyle  ]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  3. Hafif bir öğün planla   │   │
│  │  [  Ekle  ]                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  Geçelim [alt link]                 │
│                                     │
└─────────────────────────────────────┘
```

### Üç adım

Her adım minik bir eylem:
1. **Su iç** — fiziksel anlık reset
2. **Check-in yap** — duygu havalandırma
3. **Hafif öğün** — hızlı geri dönüş

Her adımın bir butonu var, tıklanınca o eylem yapılır (su ekleme sheet, check-in sheet, meal ekleme). Dönüşte adım "✓" olarak işaretlenir.

### Karar — neden 3 adım, 5 değil

5 adım terapi gibi hisseder. 3 adım yönetilebilir. Üçü de tamamlarsa küçük bir rahatlama.

### Karar — neden "geçelim" seçeneği var

Kullanıcı bazen sadece yalnız kalmak ister. Zorlanırsa etkileşimden kaçabilmeli.

### Tamamlanınca

3 adım ✓ olunca kart yerine küçük bir mesaj:

> "Tamam, başladın. Gününe devam et."

Kutlama yok. Büyük "Tebrikler!" yok. Sadece gerçek bir karşılama.

---

## Dil Farkı — Asla / Her Zaman

### Kurtarma gününde **asla**
- "Dün başarısız oldun"
- "Bugün daha iyisini yap"
- "Telafi et"
- "Daha az yemelisin"
- Emoji 😔 veya benzerleri (duygu manipülasyonu)

### Kurtarma gününde **her zaman**
- "Dün zordu" (kabul)
- "Bugün farklı olabilir" (kapı)
- "Küçük bir adım" (eşik)
- "Birlikte" (yalnız değilsin)

---

## Koç Davranışı

Kurtarma günlerinde koç tonu otomatik "gentle" seçilir — persona ne olursa olsun. Destekleyici zaten nazik, Motive edici enerjisini düşürür, Gerçekçi sertliğini kırar.

### Örnek yanıt — "Dün yine yedim, suçlu hissediyorum"

**Normal gün (gerçekçi persona):**
> "Fazla yedin, tamam. Ama kendini suçlamak bir şey çözmez. Bir sonraki öğüne bakalım."

**Kurtarma günü (gerçekçi persona → gentle mod):**
> "Seni duyuyorum. Dün olanları bırak, bugün bir başlangıç yeter."

Sertlik düşer, empati yükselir.

---

## Tekrar kurtarma günleri

Kullanıcı üst üste 3 kurtarma günü yaşarsa, sistem durumu okur. 4. günde kurtarma kartı gösterilmez — bunun yerine:

```
┌─────────────────────────────────────┐
│  Bir süredir zorlanıyorsun.         │
│  Bir uzmanla konuşmayı düşünür      │
│  müsün?                             │
│                                     │
│  Profesyonel destek gerçek fark     │
│  yaratabilir.                       │
│                                     │
│  [  Kaynaklar  ]     [  Kapat  ]    │
│                                     │
└─────────────────────────────────────┘
```

### Neden

Sürekli kurtarma sistemini rutinleştirmek yanlış. Eğer kullanıcı tekrar tekrar zorlanıyorsa, uygulamanın kapasitesi dışında bir şey var. Onu incitmeden yönlendirmek doğru.

"Kaynaklar" → `privacy-safety-screen` açar. ALO 182, destek kaynakları.

### Tetik
- Son 7 günde 4+ "bad/rough" check-in **VEYA**
- Son 5 günde 3+ risk flag'li mesaj

---

## Hiç Kurtarma Olmayan Kullanıcılar

Bazı kullanıcı hiç kurtarmaya gerek duymaz. Her gün dengeli. Bu da iyi bir senaryo.

Onlar için kurtarma günü kartı hiç görünmez. Sistem sadece bir rahatsızlık değil, bir güvenlik ağıdır.

---

## Metrikler

- `recovery_day_shown` — kart görünen gün sayısı
- `recovery_day_started` — "Başla" tıklandı
- `recovery_day_dismissed` — "Şimdi değil" tıklandı
- `recovery_step_completed` (step: water/checkin/meal)
- `recovery_completed_all_3` — üçü de ✓ yapıldı
- `repeated_recovery_triggered` — 3 üst üste
- `professional_support_shown` — 4. kurtarma

### Başarı kriterleri

- Kurtarma kartı görünen kullanıcılardan %35+ başlatsın
- Başlatanların %50+ en az bir adımı tamamlasın
- Kurtarma günü yaşayan kullanıcıların ertesi gün retention'ı, hiç görmeyen bad-day kullanıcılarından **yüksek** olsun (A/B testi için not)

Bu son madde kritik — kurtarma özelliği gerçekten retention artırıyor mu, veri söylesin.

---

## Yapılmayanlar

- **Telafi egzersizi önerisi** — asla. "Dün fazla yedin, 30 dakika yürü" → bu yeme bozukluğu ima eder.
- **Hızlı diyet önerisi** — 1000 kcal'a düşür gibi. Zararlı.
- **Sosyal kıyaslama** — "Diğer Nuveli kullanıcıları senden %20 daha iyi" gibi. Rekabet wellness'la çelişir.
- **Gamification rozet** — "Kurtarma Ustası 🏆" gibi rozetler. Kötü günleri başarıya çevirmek manipülatif.

---

## Yumuşak bitiş

Kurtarma dönemi sona erdiğinde (kullanıcı 2-3 gün normalleşti), koç bir kere proaktif mesaj atar:

> "Bu birkaç gün daha dengede gördüm seni. Kendine zaman tanıdığın için sağol."

Sadece bir kere. Sonra sessizlik. Çünkü sürekli "harika gidiyorsun" demek onun normalliğini çalar.
