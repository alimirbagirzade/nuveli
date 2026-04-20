# UI Copy Kütüphanesi

Nuveli'nin tüm ekran metinleri bu belgede. Geliştirici bu dosyaya bakar, Türkçe referans olarak kullanır. Her değişiklik bu dosyadan başlar, kodlar sonra güncellenir.

---

## Ton Kuralları (kısa hatırlatıcı)

- Sıcak, yargısız, kısa
- "Sen" kullanırız, "siz" kullanmayız (samimiyet)
- Emri değil, daveti yeğleriz
- Türkçe fiil çekimini rahat tutarız ("başlayalım", "ekleyelim")
- Emoji çok sınırlı, sadece anlamlıysa

---

## 1. Splash ve Boş Durumlar

### Splash
- (yok — logo + dot animasyonu yeterli)

### Bağlantı hatası (genel)
- Başlık: "Bağlantı kurulamadı"
- Metin: "İnternet bağlantını kontrol et, tekrar dene."
- Buton: "Tekrar dene"

### Bilinmeyen hata
- Başlık: "Bir şey ters gitti"
- Metin: "Az sonra tekrar dener misin?"
- Buton: "Tamam"

---

## 2. Onboarding Metinleri

### Kabul 1 — Yaş Kapısı
- Başlık: "Önce kısa bir onay"
- Metin: "Nuveli 18 yaş ve üzeri için tasarlandı."
- Checkbox: "18 yaşında veya daha büyüğüm"
- Buton: "Devam"

### Kabul 2 — Wellness Scope
- Başlık: "Nuveli bir wellness arkadaşı"
- Liste:
  - "Beslenme farkındalığı ve davranış desteği sunar"
  - "Tıbbi teşhis, tedavi veya diyet planı sunmaz"
  - "Sağlık durumun için doktoruna danış"
- Checkbox: "Anladım"
- Buton: "Devam"

### Kabul 3 — AI Scope
- Başlık: "AI yaklaşık çalışır"
- Metin: "Fotoğrafındaki yemek için yaklaşık kalori ve makro tahmini yaparım. Kesin ölçüm değil — gerekirse değiştirebilirsin. Her zaman."
- Checkbox: "Anladım, kesin değil"
- Buton: "Devam"

### Kabul 4 — Özel Durumlar
- Başlık: "Seninle ilgili"
- Metin: "Aşağıdakilerden biri senin için geçerliyse işaretle. Kalori önerileri ve bazı özellikler kapanır."
- Seçenekler:
  - "Hamile veya emziriyorum"
  - "Yeme bozukluğu geçmişim var"
  - "Kronik bir hastalığım var (diyabet, tiroid, vb.)"
  - "Hiçbiri"
- Buton: "Devam"

### Kabul 5 — Şartlar
- Başlık: "Son bir şey"
- Metin: "Kullanım Şartları ve Gizlilik Politikası'nı kabul ediyorum"
- Linkler: "Kullanım Şartları" · "Gizlilik Politikası"
- Buton: "Başla"

### Auth
- Başlık: "Başlamak için kayıt ol"
- Butonlar:
  - "Apple ile devam et"
  - "Google ile devam et"
  - "E-posta ile devam et"

### Email input
- Input placeholder: "ornek@mail.com"
- Buton: "Giriş Linki Gönder"
- Sonuç başlık: "Mail'ini kontrol et"
- Sonuç metin: "Giriş linkini [EMAIL] adresine gönderdik. Gelmezse spam klasörüne bak."

### Onboarding 1 — Hedef
- Başlık: "Ne için buradasın?"
- Kartlar:
  - "Kilo vermek istiyorum"
  - "Kilomu korumak istiyorum"
  - "Kilo almak istiyorum"
- Alt yazı: "Sonra değiştirebilirsin"

### Onboarding 2 — Profil 1
- Başlık: "Birazdan bitti"
- Sorular:
  - "Yaşın?" → slider
  - "Cinsiyet?" → kadın / erkek / diğer / söylemek istemiyorum
  - "Boy (cm)?" → input
  - "Şu anki kilo (kg)?" → input
- Buton: "Devam"

### Onboarding 3 — Aktivite
- Başlık: "Günlük hayatın?"
- Alt: "Gün içindeki genel hareketliliğini düşün"
- Kartlar:
  - "Masabaşı hareketsiz" — "Oturarak çalışıyorum, az yürürüm"
  - "Hafif aktif" — "Haftada 1-2 gün hareket ederim"
  - "Orta aktif" — "Haftada 3-5 gün hareket ederim"
  - "Çok aktif" — "Neredeyse her gün aktifim"

### Onboarding 4 — Persona
- Başlık: "Nasıl bir koç istersin?"
- Alt: "Ayarlar'dan istediğin zaman değiştirebilirsin"
- Kartlar:
  - **Destekleyici** — "Nazik, sakin, önce dinler."
  - **Motive edici** — "Enerjik, hedef odaklı, cesaretlendirici."
  - **Gerçekçi** — "Doğrudan ama şefkatli. Gerçeği söyler."

### Onboarding 5 — Bildirimler
- Başlık: "Ne zaman seni rahatsız etmeyelim?"
- Alt: "Hepsini sonra ayardan değiştirebilirsin"
- Toggle'lar:
  - "Öğün hatırlatıcıları"
  - "Koç nüdgleri"
  - "Haftalık özet"
- Sessiz saat seçici

### Onboarding 6 — Sonuç
- Başlık: "Günlük hedefin: **[X] kcal**"
- Alt: "Kilo hedefine ulaşmak için yaklaşık bir başlangıç noktası. Yol boyunca birlikte ayarlarız."
- Koç tanışma (persona'ya göre): bkz. Koç Persona Örnekleri
- Buton: "Başla"

---

## 3. Home Ekranı

### Selamlama (saate göre)
- 05:00-12:00 → "Günaydın"
- 12:00-18:00 → "İyi öğleden sonralar"
- 18:00-23:00 → "İyi akşamlar"
- 23:00-05:00 → "Geç saatler"

### Daily Summary
- Üstte: "Bugün"
- Büyük sayı: tüketilen kalori
- Altında: "/ [hedef] kcal hedefi"
- Kalan: "[sayı] kaldı" (büyük → küçük dönüş)
- Macrolar: "Protein · Karb · Yağ" + gram

### Quick Actions
- Öğün Ekle → ikon + "Öğün Ekle"
- Su → ikon + "Su"
- Kilo → ikon + "Kilo"
- Check-in → ikon + "Check-in"

### Craving Prompt
- "Bir şeye canın çekiyor mu? 60 saniye dur, derin nefes al."

### Mini Progress
- Başlık: "Bu Hafta"
- Bar grafik, günler: Pzt/Sal/Çar/Per/Cum/Cmt/Paz

### Mini Task
- Başlık: "Bugünkü Mini Hedef"
- Örnek task: "Bir öğüne protein ekle"

### Empty Day
- Başlık: "Yeni bir gün"
- Metin: "Bugün henüz kayıt yok. Başlamak için küçük bir adımla başlayalım."
- Buton: "İlk Öğünü Ekle"

---

## 4. Meal Ekranları

### Meal Capture
- AppBar: "Öğün Ekle"
- Başlık: "Fotoğraf veya açıklama"
- Boş kamera state: "Fotoğraf eklenmedi"
- Butonlar: "Kamera" · "Galeri"
- Textarea placeholder: "Veya yemeği yaz (örn. tavuk göğsü, pilav, salata)"
- Primary: "Analiz Et"
- Alt link: "Manuel giriş yap"

### Analyze loading
- 0-2sn: "Yemeğine bakıyorum..."
- 2-4sn: "Besin değerlerini hesaplıyorum..."
- 4+sn: "Biraz vakit alıyor, sabret..."

### Analiz Sonucu (high)
- AppBar: "Analiz Sonucu"
- Info banner: "Bu yaklaşık bir tahmindir. Gerekirse değerleri düzenle."
- Yemek adı (büyük)
- Makrolar
- Butonlar: "Düzenle" · "Onayla"

### Analiz Sonucu (low confidence)
- Banner (turuncu): "Tam emin olamadım. Lütfen kontrol et ve düzeltebileceklerini düzelt."

### Analiz Failed
- Başlık: "Bu fotoğraftan anlayamadım 🤔"
- Butonlar: "Manuel giriş yap" · "Başka fotoğraf dene"

### Manuel Giriş
- AppBar: "Manuel Giriş"
- Input placeholder'lar:
  - "Yemek adı"
  - "Kalori (kcal)"
  - "Protein (g)"
  - "Karb (g)"
  - "Yağ (g)"
- Öğün tipi chips: "Kahvaltı · Öğle · Akşam · Ara öğün"
- Buton: "Kaydet"

### Snackbar (başarı)
- "Öğün eklendi."

### Silme onayı
- Başlık: "Öğünü sil"
- Metin: "Bu öğünü silmek istediğine emin misin?"
- Butonlar: "İptal" · "Sil"

### Meal list empty
- "Henüz öğün kaydın yok. İlk yemeği ekleyelim!"

---

## 5. Water, Weight, Check-in

### Su ekle sheet
- Başlık: "Su Ekle"
- Hızlı butonlar: "200 ml · 250 ml · 330 ml · 500 ml · 750 ml"
- Manuel input: "Başka miktar"

### Kilo ekle sheet
- Başlık: "Kilonu Girin"
- Input: "kg"
- Buton: "Kaydet"

### Check-in sheet
- Başlık: "Bugün nasılsın?"
- 5 emoji + etiket:
  - 😄 Harika
  - 🙂 İyi
  - 😐 Normal
  - 😔 Zor
  - 😞 Çok Zor
- (Opsiyonel not alanı)

### Not input placeholder
- "Bir şey eklemek ister misin? (opsiyonel)"

---

## 6. Koç Ekranı

### Koç chat AppBar
- Başlık: "Koçun"
- Alt: persona adı (örn. "Destekleyici")

### Input placeholder
- "Mesajını yaz..."

### Empty chat state
- "Merhaba! Bugün nasıl hissediyorsun?"

### Limit ulaşıldı
- "Bugün beş mesaj attık — güzel konuştuk. Yarın devam edelim, ya da Pro ile sınırsız sohbet et."
- Butonlar: "Pro'ya Geç" · "Yarın Devam"

---

## 7. İlerleme

### Weekly Summary
- AppBar: "Haftalık Özet"
- Stat kartları:
  - "Ortalama kalori"
  - "Kayıt tutulan gün"
  - "Ortalama su"
- Bölüm: "İçgörüler"

### Monthly Insight
- AppBar: "Aylık İçgörü"
- Üst: "Son 30 gün"
- Başlık: "3 önemli örüntü"

### Empty progress
- "Birkaç gün kayıt yaptıktan sonra grafiğin burada belirir."

---

## 8. Premium / Paywall

### Paywall
- Badge: "NUVELI PREMIUM"
- Başlık: "Tüm özellikler, sınır yok."
- Özellik listesi:
  - "Sınırsız öğün analizi"
  - "Gelişmiş AI koç + sesli yanıt"
  - "Haftalık özet ve aylık içgörü"
  - "Tüm ilerleme grafikleri"
  - "Öncelikli destek"
- Fiyat kartı:
  - Başlık: "7 gün ücretsiz dene"
  - Alt: "Sonrasında [FİYAT]/ay · istediğin zaman iptal et"
- Primary: "7 Gün Ücretsiz Başla"
- Alt link: "Satın almayı geri yükle"

### Trial teklif modal
- Icon: hediye
- Başlık: "Sana bir hediye"
- Metin: "7 gün tam erişim. Kredi kartı gerekmez."
- Butonlar: "Kabul Et" · "Belki sonra"

### Limit reached (genel)
- "Bugünkü [feature] limitini kullandın. Devam etmek ister misin?"

---

## 9. Ayarlar

### Ana settings
- Bölümler:
  - "Hesap"
  - "Destek ve Güvenlik"
  - "Abonelik"
  - "Tehlikeli Bölge"
- Items:
  - "Profil"
  - "Bildirimler"
  - "Destek"
  - "AI nasıl çalışır"
  - "Gizlilik ve Güvenlik"
  - "Premium"
  - "Hesabı Sil"

### Notifications prefs
- AppBar: "Bildirimler"
- Bölüm: "Sessiz Saatler"
- Toggle'lar: (onboarding'deki aynı metin)

### Support
- AppBar: "Destek"
- Başlık: "Size nasıl yardım edebiliriz?"
- Kartlar:
  - "E-posta ile ulaş" → support@nuveli.com.tr
  - "SSS"

### How AI Works
- AppBar: "AI Nasıl Çalışır"
- Bloklar:
  - **Yemek Tanıma** — "Fotoğrafını incelerim ve yaklaşık kalori/besin tahmini yaparım. Bu kesin bir ölçüm değildir — gerekirse düzeltebilirsin."
  - **Koç Yanıtları** — "Kısa, yargısız ve destekleyici mesajlar üretirim. Tıbbi tavsiye ya da diyet planı sunmam."
  - **Güvenlik** — "Riskli durumlarda profesyonel destek kaynaklarını gösteririm. Kriz anında doğrudan sabit güvenlik metni gelir."
  - **Verilerin** — "Verilerin şifreli iletilir ve sadece sen erişirsin. Ayarlar > Hesabı Sil ile tamamen silebilirsin."

### Privacy & Safety
- AppBar: "Gizlilik ve Güvenlik"
- Başlık: "Güvenliğin bizim önceliğimiz"
- Metin: "Nuveli bir wellness uygulamasıdır. Tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. Zor bir dönemden geçiyorsan lütfen profesyonel destek al."
- Acil kart: "Acil Destek" — "ALO 182 — Psikolojik Destek Hattı (7/24)"
- Linkler: "Gizlilik Politikası · Kullanım Şartları · Verimi İndir"

### Delete Account
- AppBar: "Hesabı Sil"
- Uyarı: "Bu işlem geri alınamaz. Tüm öğün kayıtların, koç konuşmaların ve profil bilgilerin silinecek."
- Checkbox: "Bu eylemin geri alınamayacağını anladım"
- Prompt: "Onaylamak için aşağıya SIL yaz"
- Input placeholder: "SIL"
- Buton: "Hesabı Kalıcı Olarak Sil"

---

## 10. Hata Mesajları (Dio / API)

Her hata için kullanıcı dostu mesaj:

| Code | Mesaj |
|------|-------|
| `AUTH_REQUIRED` | "Oturumun süresi doldu. Tekrar giriş yap." |
| `LIMIT_EXCEEDED` | (custom, feature bazlı) |
| `NETWORK_ERROR` | "Bağlantı kurulamadı. Tekrar dene." |
| `ANALYSIS_FAILED` | "Şu an analiz yapamıyorum. Manuel giriş yapar mısın?" |
| `NOT_FOUND` | "İstediğin şeyi bulamadım." |
| `VALIDATION_ERROR` | "Gönderdiğin bilgide bir sorun var, kontrol et." |
| `INTERNAL_ERROR` | "Bir şeyler ters gitti. Az sonra tekrar dene." |

---

## 11. Push Notification Metinleri

### Öğün hatırlatıcısı (saat 12:30 ve 19:00)
- "Öğle yemeğini eklesek mi?"
- "Akşam yemeğin nasıldı? Ekleyelim."

### Check-in daveti (saat 20:00-22:00)
- "Bugünü nasıl geçirdin?"

### Streak kutlama (7/30 gün)
- "7 gün üst üste. İyi gidiyorsun."
- "30 gün. Bu bir alışkanlık artık."

### Weekly summary hazır (her pazartesi)
- "Geçen haftan hazır. Bir bakar mısın?"

### Push kopyası kuralları
- Max 60 karakter (iOS preview limiti)
- Soru veya davet olsun, emri olmasın
- Kullanıcı adı **kullanma** ("Merhaba Ali" gereksiz)

---

## 12. Değişiklik ve Ekleme

Bu dosya **tek doğruluk kaynağıdır**. Yeni ekran/buton gelirse önce buraya yazılır, sonra kodlanır. Kod ve bu dosya çelişirse, bu dosyaya göre kod düzeltilir.
