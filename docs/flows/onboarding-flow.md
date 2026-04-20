# Onboarding Akışı

Bu belge, kullanıcının uygulamayı ilk açışından ana ekranı görmesine kadar geçen akışı tanımlar.

---

## Genel İlke

**Onboarding bir form değildir, bir tanışmadır.** Her soru bir sebebe hizmet eder. Soru sormadan önce "bu yanıtla uygulamada neyi değiştireceğim?" diye düşünürüz. Değiştirmeyecekse sormayız.

**Toplam adım sayısı:** 11 (5 kabul + 6 onboarding)
**Tahmini süre:** 2-3 dakika
**Terk oranı hedefi:** %75'ten az (endüstri ortalaması %85)

---

## Akış Şeması

```
Splash (1sn)
   ↓
[KABUL EKRANLARI]
1. Yaş kapısı (18+ onay)
2. Wellness scope (tıbbi değil, uyarı)
3. AI tahmini scope (kesin değil, yaklaşık)
4. Özel durumlar (hamilelik, yeme bozukluğu, kronik hastalık)
5. Şartlar ve gizlilik
   ↓
[AUTH]
Email / Apple / Google giriş
   ↓
[ONBOARDING]
6. Hedef seçimi (kilo ver / koru / al)
7. Profil 1 — yaş, cinsiyet, boy, kilo
8. Profil 2 — aktivite seviyesi
9. Koç persona seçimi (destekleyici / motive edici / gerçekçi)
10. Bildirim tercihi
11. Onboarding sonuç — günlük hedef + koç tanışma
   ↓
Home (ana ekran)
```

---

## 1. Kabul Ekranları — Tasarım Kararları

### 1.1 Yaş Kapısı

**Amaç:** 18 yaş altı kullanıcıyı filtreleme. Yasal zorunluluk.

**Ekran:**
- Başlık: "Önce kısa bir onay"
- Metin: "Nuveli 18 yaş ve üzeri için tasarlandı. Devam etmek için yaşını onayla."
- Checkbox: "18 yaşında veya daha büyüğüm"
- Buton: "Devam" (checkbox işaretlenmeden disable)

**Karar — neden tek checkbox, doğum tarihi değil:**
Doğum tarihi istemek daha fazla sürtünme. 18 altı kullanıcı yalan söylerse zaten engellemek imkansız. Onboarding'de doğum yılını profil adımında soracağız, orada 18 altı ise soft-block koyacağız.

**Edge case:** Kullanıcı yaş girişinde 18 altı yazarsa, profil adımında uygulamayı kilitleriz. "Nuveli şu an senin yaş grubun için uygun değil. Anlayışın için teşekkürler" ekranı gösterilir.

---

### 1.2 Wellness Scope

**Amaç:** Uygulamanın tıbbi olmadığını, kullanıcıyı yasal ve etik olarak korumak.

**Ekran:**
- Başlık: "Nuveli bir wellness arkadaşı"
- İçerik:
  - "Beslenme farkındalığı ve davranış desteği sunar"
  - "Tıbbi teşhis, tedavi veya diyet planı sunmaz"
  - "Sağlık durumun için doktoruna danış"
- Checkbox: "Anladım"
- Buton: "Devam"

**Karar — neden bir liste, uzun paragraf değil:**
Üç madde, okuması 8 saniye. Paragraf olsa %80 okumadan geçer, sonra sorun çıkarsa "yazmıyordu" diyebilir. Madde formatı göz taraması kolay.

---

### 1.3 AI Tahmini Scope

**Amaç:** AI'nın kesin değil, yaklaşık sonuç verdiğini baştan söylemek. Beklenti yönetimi.

**Ekran:**
- Başlık: "AI yaklaşık çalışır"
- İçerik: "Fotoğrafındaki yemek için yaklaşık kalori ve makro tahmini yaparım. Kesin ölçüm değil — gerekirse değiştirebilirsin. Her zaman."
- Görsel: Bir yemek fotoğrafı ve yanında tahmini gösteren küçük örnek
- Checkbox: "Anladım, kesin değil"
- Buton: "Devam"

**Karar — neden bu ekran kritik:**
Tüm rakip uygulamaların en büyük eleştirisi: "AI yanlış söyledi, hayatım battı." Bu ekran kullanıcıyı baştan tahmine hazırlar. Sonra yanılma olursa öfke değil, "zaten söylemişlerdi" tepkisi gelir.

---

### 1.4 Özel Durumlar

**Amaç:** Uygulama için uygun olmayan kullanıcıları erken belirlemek.

**Ekran:**
- Başlık: "Seninle ilgili"
- Metin: "Aşağıdakilerden herhangi biri senin için geçerliyse işaretle. Kalori önerileri ve bazı özellikler kapanır."
- Checkbox listesi:
  - "Hamile veya emziriyorum"
  - "Yeme bozukluğu geçmişim var"
  - "Kronik bir hastalığım var (diyabet, tiroid, vb.)"
  - "Hiçbiri"
- Buton: "Devam"

**Karar — neden "işaretleme zorunlu" yerine "hiçbiri" seçeneği:**
Kullanıcı psikolojisi: zorunlu işaretleme suçlu hissi yaratır. "Hiçbiri" seçeneği kullanıcıya eşitlik verir. Veri açısından da değerli.

**Özel durum işaretleyen kullanıcı için:**
- Kalori hedefi hesaplanmaz, gösterilmez
- Koç kısıtlı modda çalışır (davranış desteği var, sayısal öneri yok)
- Home ekranında üstte sabit banner: "Bu özellikler sizin durumunuz için uygun olmayabilir. Lütfen sağlık uzmanınıza danışın"

---

### 1.5 Şartlar ve Gizlilik

**Amaç:** Yasal zorunluluk + güven.

**Ekran:**
- Başlık: "Son bir şey"
- Checkbox: "Kullanım Şartları ve Gizlilik Politikası'nı okudum ve kabul ediyorum"
- Linkler: iki ayrı link (yeni pencerede açılır, tam metin)
- Buton: "Başla"

**Karar — neden "Başla" değil "Kabul Et":**
"Kabul Et" yasal bir fiil, soğuk. "Başla" uygulamayla ilişki başlatır. Aynı eylem, farklı his.

---

## 2. Auth Ekranı

Kabul sonrası auth. Önce ürünü görsün, sonra kayıt olsun istedik ama bu delete account için zorlu oluyor (anonymous user → veriler nereye?). Klasik yolu seçtik: önce kayıt.

### 2.1 Giriş / Kayıt

**Ekran:**
- Nuveli logosu
- "Başlamak için giriş yap veya kayıt ol"
- Butonlar (sıralı):
  1. "Apple ile devam et" (iOS)
  2. "Google ile devam et"
  3. "E-posta ile devam et" → email input ekranına git

**Karar — neden önce OAuth, sonra e-posta:**
Mac OAuth auth en hızlı, şifre yok, beğeniyor. E-posta ile ise magic link. Bu da parola stresini kaldırır.

**E-posta ekranı:**
- Input: email
- Buton: "Giriş Linki Gönder"
- Sonuç: "Mailbox'ını kontrol et" ekranı, gri metin "Gelmezse spam klasörüne bak"

---

## 3. Onboarding — Tasarım Kararları

### 3.1 Hedef Seçimi

**Ekran:**
- Başlık: "Ne için buradasın?"
- 3 büyük kart (tap edilebilir):
  - "Kilo vermek istiyorum" + simge
  - "Kilomu korumak istiyorum" + simge
  - "Kilo almak istiyorum" + simge
- Alt yazı: "Sonra değiştirebilirsin"
- Buton yok — kart tap'i seçer ve direkt devam eder

**Karar — neden "seçim yap + devam" değil, "tek tap":**
Her ekstra tap kaybedilmiş bir kullanıcı. Radio button + devam butonu iki tap, kart direkt tap tek. Sürtünme azaltma.

---

### 3.2 Profil 1 — Temel Veriler

**Ekran:**
- Başlık: "Birazdan bitti"
- Soru 1: "Yaşın?" → yıl slider (1940-2006, varsayılan 1995)
- Soru 2: "Cinsiyet?" → 4 seçenek (kadın / erkek / diğer / söylemek istemiyorum)
- Soru 3: "Boy?" → cm slider veya input
- Soru 4: "Şu anki kilo?" → kg input
- Buton: "Devam"

**Karar — neden slider + input karışık:**
Kilo spesifik, input lazım. Boy spesifik, input lazım. Yaş genelde yaklaşık biliniyor, slider kolay. Doğum yılı sormak + slider = hız kazanç.

---

### 3.3 Profil 2 — Aktivite

**Ekran:**
- Başlık: "Günlük hayatın?"
- 4 kart:
  - "Masabaşı hareketsiz" — "Oturarak çalışıyorum, az yürürüm"
  - "Hafif aktif" — "Haftada 1-2 gün hareket ederim"
  - "Orta aktif" — "Haftada 3-5 gün hareket ederim"
  - "Çok aktif" — "Neredeyse her gün aktifim"
- Alt yazı: "Gün içindeki genel hareketliliğini düşün"

**Karar — neden kısa açıklamalar:**
"Sedentary/Light/Moderate/Active" terimleri sıkıcı ve yabancı. "Masabaşı hareketsiz" Türk kullanıcının kendini hemen tanıyabileceği dil.

**Hedef + profil verileri ile kalori hedefi hesaplanır** (Mifflin-St Jeor), bir sonraki ekranda gösterilir.

---

### 3.4 Koç Persona Seçimi

**Ekran:**
- Başlık: "Nasıl bir koç istersin?"
- 3 kart:
  - **Destekleyici** — "Nazik, sakin, önce dinler." → avatar veya icon
  - **Motive edici** — "Enerjik, hedef odaklı, cesaretlendirici."
  - **Gerçekçi** — "Doğrudan ama şefkatli. Gerçeği söyler."
- Alt yazı: "Ayarlar'dan istediğin zaman değiştirebilirsin"

**Karar — neden 3, 5 değil:**
5 persona paralizi yaratır. 3 net karakter, her biri gerçekten farklı ton. Çok kullanıcı destekleyici seçer, bu normal.

**Örnek gösterim (kart içinde):**
Her kartın altında bir örnek mesaj:
- Destekleyici: "Bugün zor olabilir, biraz kendine alan ver."
- Motive edici: "Hadi, bir adım yeter. Başla!"
- Gerçekçi: "Bir şey kaçırdın, fark ettim. Yarın düzelir."

Bu örnekler seçim kararını çok kolaylaştırır.

---

### 3.5 Bildirim Tercihi

**Ekran:**
- Başlık: "Ne zaman seni rahatsız etmeyelim?"
- Toggle: "Öğün hatırlatıcıları" (varsayılan AÇIK)
- Toggle: "Koç nüdgleri" (varsayılan AÇIK)
- Toggle: "Haftalık özet" (varsayılan AÇIK)
- Sessiz saat seçici: "22:00 - 08:00 arası sessiz"
- Buton: "Tamam"
- Alt yazı: "Hepsini sonra ayardan değiştirebilirsin"

**Karar — neden "rahatsız etmeyelim" dili:**
"Bildirim izni ver" çok yaygın, duyulmaz oldu. "Seni rahatsız etmeyelim" kontrolün kullanıcıda olduğunu hissettirir. iOS push permission popup'ı bundan sonra gelir.

---

### 3.6 Onboarding Sonuç

**Ekran:**
- Büyük başlık: "Günlük hedefin: **1,820 kcal**"
- Alt yazı: "Kilo hedefine ulaşmak için yaklaşık bir başlangıç noktası. Yol boyunca birlikte ayarlarız."
- Koç kartı (alt): Seçtiğin persona'nın avatarı + mesajı
  - Örnek (destekleyici seçildiyse): "Merhaba Ali. Seninle tanışmak güzel. Ne zaman hazır olursan başlayalım."
- Buton: "Başla"

**Karar — neden "günlük hedefin" büyük ve net:**
İlk wow anı potansiyeli burada. Kullanıcı bir sayı görür, "bu benim hedefim" hissini yakalar. Sayının **doğruluğu** değil, **verilmiş** olması önemli. Kişiselleştirilmiş his.

**Edge case:** Özel durum işaretlediyse bu ekran farklı:
- Kalori hedefi yok
- Onun yerine: "Nuveli'ye hoş geldin. Özel durumunu dikkate aldık, koçun seninle yargısız çalışacak."

---

## 4. Başarı Metrikleri

Her adımı analytics event'le ölç:
- `acceptance_screen_passed` (screen_id)
- `onboarding_step_completed` (step_number)
- `onboarding_completed` (goal, persona, duration_seconds)
- `onboarding_abandoned` (last_step, time_spent)

**Hedef:** Her adımın %92+ geçişi. %20+ düşüş varsa o ekran yeniden tasarlanır.

---

## 5. Yapılmayanlar (bilinçli)

- **Boy/kilo için imperial/metric seçimi yok.** Türk pazarı metric. V2'de düşünülür.
- **Hesap oluşturma zorunlu değil, zorunludur.** Anonymous kullanıma izin yok. Delete account için hesap lazım.
- **Diyet tipi sormuyoruz (vegan, keto vb.).** Nuveli özelleşmiş diyet ürünü değil, genel wellness.
- **Yemek alerjisi sormuyoruz.** Öneri motoru yok, bu bilgi şu an kullanılmaz.

---

## 6. Değişiklik Geçmişi

- v1 (bu belge) — Prompt paketindeki 2.1 + 2.2 + 2.3 üzerine kararlarla yazıldı
