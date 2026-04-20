# Release QA Listesi

Her sürüm öncesi bu liste baştan sonra yapılır. Her madde ya **geçti** ya **takıldı** olarak işaretlenir. Takılan maddeler çözülmeden release yok.

---

## Pre-release (kod donmasından önce)

### Kod kalitesi
- [ ] `flutter analyze` sıfır hata
- [ ] `flutter test` hepsi geçiyor
- [ ] Backend `pytest` hepsi geçiyor
- [ ] Lint uyarıları temizlendi
- [ ] TODO'lar gözden geçirildi (kritik olanları çöz, diğerlerini ticket'a dök)

### Güvenlik
- [ ] Hiçbir API key kodda hardcoded değil
- [ ] `.env` dosyaları `.gitignore`'da
- [ ] Supabase RLS tüm tablolarda aktif
- [ ] Backend tüm endpoint'leri auth dependency kullanıyor (health hariç)
- [ ] Crisis/safety metinleri değiştirilmemiş

---

## Onboarding akışı

### Kabul ekranları
- [ ] Yaş kapısı checkbox olmadan "Devam" tıklanamıyor
- [ ] Wellness scope ekranı checkbox zorunlu
- [ ] AI scope ekranı checkbox zorunlu
- [ ] Özel durumlar en az bir seçim veya "hiçbiri" gerektiriyor
- [ ] Şartlar/gizlilik linkleri gerçek sayfaya götürüyor (yeni tab)

### Auth
- [ ] Apple ile giriş (iOS sadece) çalışıyor
- [ ] Google ile giriş çalışıyor
- [ ] E-posta magic link geliyor (spam'de değil)
- [ ] Magic link tıklanınca uygulamaya dönüş + auto-login
- [ ] Yanlış email girince frontend validasyon çalışıyor

### Profil
- [ ] 18 yaş altı giriş yaparsa soft-block ekranı
- [ ] Kilo alanı 20-300 kg arası kabul ediyor
- [ ] Boy alanı 100-250 cm arası kabul ediyor
- [ ] Negative değer veya harf reddediliyor
- [ ] Aktivite seviyesi seçimi kaydediliyor
- [ ] Özel durum seçenler için kalori hedefi GÖSTERİLMİYOR

### Hesaplama
- [ ] Erkek + orta aktif + 80 kg + 180 cm + 30 yaş + "kilo ver" → ~2000 kcal civarı
- [ ] Kadın + hareketsiz + 60 kg + 165 cm + 28 yaş + "kilo ver" → ~1400 kcal civarı
- [ ] Minimum kalori limit'e (erkek 1500, kadın 1200) asla düşmüyor

### Koç persona
- [ ] 3 persona kartı seçilebiliyor
- [ ] Seçim görsel olarak aktif görünüyor
- [ ] Seçilen persona kaydediliyor

### Bildirim izni
- [ ] iOS permission popup çıkıyor
- [ ] Android (API 33+) permission popup çıkıyor
- [ ] Reddederse uygulama çalışmaya devam ediyor (zorunlu değil)
- [ ] Sessiz saat seçici çalışıyor

### Sonuç ekranı
- [ ] Günlük kalori hedefi büyük gösteriliyor
- [ ] Koç persona'nın karşılama mesajı gösteriliyor
- [ ] "Başla" butonu home'a götürüyor

---

## Home ekranı

### Yükleme
- [ ] Loading state gösteriliyor
- [ ] Boş kullanıcı için (yeni) empty day kartı
- [ ] Gerçek data geldiğinde grafikler doğru
- [ ] Pull-to-refresh çalışıyor
- [ ] Offline: cached data gösteriliyor, banner var

### Daily Summary Card
- [ ] Kalori sayacı doğru
- [ ] Makrolar doğru hesaplanıyor
- [ ] Circle progress bar orantılı
- [ ] Hedefi aşarsa yine doğru gösteriliyor (kırmızı değil, nötr)

### Quick Actions
- [ ] Öğün ekle → meal capture ekranı
- [ ] Su → bottom sheet
- [ ] Kilo → bottom sheet
- [ ] Check-in → bottom sheet

### Coach Card
- [ ] Mesaj context'e göre değişiyor
- [ ] Tap → coach chat ekranı

### Empty State
- [ ] Yeni kullanıcı: empty day kartı
- [ ] Dün kayıt varsa: bugün için invite

---

## Öğün akışı

### Meal Capture
- [ ] Kamera izni yoksa uyarı
- [ ] Galeri erişimi çalışıyor
- [ ] Fotoğraf büyüklüğü optimize ediliyor (backend'e < 1MB gidiyor)
- [ ] Açıklama alanı opsiyonel

### Analiz
- [ ] 4 saniye altında yanıt geliyor (GPT-4o normal)
- [ ] Loading mesajları değişiyor
- [ ] İnternet kesilirse timeout hatası, manuel giriş fallback

### Sonuç
- [ ] High confidence: değerler doğru format
- [ ] Low confidence: uyarı banner görünüyor
- [ ] Failed: manuel giriş yönlendirmesi
- [ ] Öğün tipi saate göre akıllı varsayılan

### Düzenleme
- [ ] Tüm değerler edit edilebilir
- [ ] Kaydet → meal_log yeni satır, summary yenilenir

### Manuel Giriş
- [ ] Yemek adı + kalori zorunlu
- [ ] Makro alanları opsiyonel
- [ ] Kaydet → home'a dön, snackbar

### Limit
- [ ] 4. analizde paywall ekranı görünüyor
- [ ] Manuel giriş her zaman alternatif
- [ ] Trial başlatıldıysa limit 100x açılıyor

### Silme
- [ ] Swipe to delete çalışıyor
- [ ] Onay modal çıkıyor
- [ ] Silme sonrası summary yenileniyor

---

## Koç

### Chat ekranı
- [ ] Yeni kullanıcı: empty state
- [ ] Thread geçmişi kronolojik sıralı
- [ ] Kullanıcı mesajı optimistic görünüyor
- [ ] Koç yanıtı 3-6 saniye içinde geliyor
- [ ] Fallback mesajlar `is_fallback=true` işaretleniyor
- [ ] Scroll en son mesaja otomatik gidiyor

### Sesli yanıt
- [ ] Premium kullanıcıda play butonu görünüyor
- [ ] Free kullanıcıda play butonu görünmüyor
- [ ] Play → ses oynatılıyor
- [ ] Yeniden play çalışıyor

### Limit
- [ ] Free: 5 mesaj sonrası paywall invite
- [ ] Premium/trial: limitsiz çalışıyor

### Risk handling
- [ ] "intihar etmek istiyorum" yazarsa → sabit kriz metni
- [ ] AI yanıtı değil, sabit metin
- [ ] ALO 182 yönlendirmesi doğru
- [ ] Kullanıcı risk mesajı sonrası normal devam edebiliyor

- [ ] "Hiç yemiyorum" yazarsa → distress modu, uzman öner
- [ ] "500 kalori yeterli" yazarsa → low_intake mod

### Persona değişimi
- [ ] Ayarlar'dan persona değiştirilebiliyor
- [ ] Yeni persona bir sonraki yanıtta devreye giriyor

---

## Su / Kilo / Check-in

### Su
- [ ] Hızlı miktarlar (200/250/330/500/750) çalışıyor
- [ ] Günlük toplam home'da görünüyor
- [ ] Manuel miktar girilebiliyor

### Kilo
- [ ] Günde bir kilo girişi (duplicate engelleniyor)
- [ ] Geçmiş kilolar grafik olarak görünüyor (progress ekranı)

### Check-in
- [ ] 5 mood seçeneği çalışıyor
- [ ] Opsiyonel not kaydediliyor
- [ ] Günde bir check-in (duplicate uyarısı)
- [ ] Mood koç decision'ını etkiliyor

---

## İlerleme

### Weekly Summary
- [ ] Önceki 7 gün verisi doğru
- [ ] Ortalama kalori hesabı doğru
- [ ] "İçgörüler" bölümü mantıklı yorumlar üretiyor
- [ ] Premium only → free kullanıcıda kilit gösteriyor

### Monthly Insight
- [ ] Son 30 gün verisi
- [ ] 3 içgörü gösteriliyor
- [ ] Premium only

---

## Premium

### Paywall
- [ ] RC offerings doğru yükleniyor
- [ ] Fiyat gösterimi doğru (TRY)
- [ ] "7 gün ücretsiz başla" butonu → RC satın alma
- [ ] Restore purchases çalışıyor
- [ ] Satın alma sonrası premium state home'da görünüyor

### Trial
- [ ] "Trial claim" endpoint çalışıyor (backend)
- [ ] Trial period sonunda otomatik free'ye düşüyor
- [ ] Trial aktifken tüm premium özellikler açık

### Premium özellikler
- [ ] Sınırsız meal analiz
- [ ] Sınırsız koç mesajı
- [ ] Sesli koç yanıtı
- [ ] Weekly summary erişimi
- [ ] Monthly insight erişimi

### Webhook
- [ ] RC webhook backend'e ulaşıyor
- [ ] Secret header doğrulanıyor
- [ ] `INITIAL_PURCHASE` → tier: premium
- [ ] `EXPIRATION` → tier: free
- [ ] `BILLING_ISSUE` → tier: free

---

## Settings

### Profil
- [ ] Bilgi güncellenebiliyor
- [ ] Değişiklik sonrası kalori hedefi yeniden hesaplanıyor

### Bildirimler
- [ ] Toggle'lar çalışıyor
- [ ] Sessiz saat değişikliği kaydediliyor
- [ ] Backend'e sync oluyor

### Support
- [ ] Mailto link çalışıyor
- [ ] SSS erişilebilir

### How AI Works
- [ ] Açıklamalar okunabilir

### Privacy & Safety
- [ ] Gizlilik ve şartlar linkleri çalışıyor
- [ ] ALO 182 bilgisi görünüyor

### Delete Account
- [ ] Checkbox + "SIL" yazımı gerektiriyor
- [ ] Silme backend'e istek gönderiyor
- [ ] Supabase'deki kullanıcı siliniyor
- [ ] RC'deki customer deleted olarak işaretleniyor
- [ ] Uygulama çıkışa zorlanıyor

---

## Web abonelik portalı (nuveli.com.tr/app)

- [ ] Magic link ile giriş çalışıyor
- [ ] Giriş sonrası RC configure oluyor
- [ ] Non-pro kullanıcı paywall görüyor
- [ ] "Paketleri Göster" RC paywall açıyor
- [ ] Satın alma Stripe checkout'a gidiyor
- [ ] Test kart (4242 4242 4242 4242) ile sandbox satın alma
- [ ] Pro kullanıcı customer center görüyor
- [ ] Customer center detayları doğru (plan, yenileme)
- [ ] Logout çalışıyor

---

## Performans

- [ ] App cold start < 3 saniye
- [ ] Home ekranı ilk yükleme < 2 saniye
- [ ] Meal analiz < 5 saniye
- [ ] Coach yanıt < 4 saniye
- [ ] Scroll 60fps sürekli
- [ ] Memory < 200 MB idle

---

## Accessibility

- [ ] VoiceOver/TalkBack tüm butonları okuyor
- [ ] Büyük yazı tipi desteği
- [ ] Renk kontrast AA seviyesi (WCAG)
- [ ] Tab keyboard navigasyonu (web için)

---

## Crash ve hata

- [ ] Crashlytics bağlantılı
- [ ] Test crash gönderildi, panelde göründü
- [ ] Global error handler çalışıyor
- [ ] Runtime exception uygulamayı kapatmıyor (fatal hariç)
- [ ] Network hatası kullanıcıya "tekrar dene" diyor

---

## Mağaza submission hazırlığı

### App Store
- [ ] App icon (1024x1024)
- [ ] Screenshot'lar (6.7", 5.5" iPhone; iPad opsiyonel)
- [ ] App description (TR)
- [ ] Keywords
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Age rating: 17+ (wellness)
- [ ] Data collection beyannamesi doğru

### Google Play
- [ ] App icon (512x512)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots
- [ ] Short description (80 char)
- [ ] Full description
- [ ] Privacy policy URL
- [ ] Data safety doldurulmuş

### Her ikisi
- [ ] Bundle ID doğru
- [ ] Version kodu arttırıldı
- [ ] Build number arttırıldı
- [ ] Signing key korunuyor (yedekli)

---

## Post-release (ilk 48 saat)

- [ ] Crashlytics'te kritik crash var mı
- [ ] Analytics event'leri akıyor mu
- [ ] Backend error rate normal mi (%1'den az)
- [ ] Paywall conversion rate ölçülüyor
- [ ] Kullanıcı geri bildirimleri (mail, review) toplanıyor
- [ ] RC webhook'lar düzgün gelmeye devam ediyor

---

## Hack kontrolü (ayda bir)

- [ ] API key'ler rotate edilmiş mi (quarterly)
- [ ] Supabase RLS test edilmiş mi (başka user'ın verisine erişilemez)
- [ ] Rate limiting çalışıyor mu (bir endpoint'e 1000 istek at, bloklanıyor mu)
- [ ] Delete account gerçekten siliyor mu (30 gün sonra kontrol)
- [ ] GDPR/KVKK veri dışa aktarma çalışıyor mu
