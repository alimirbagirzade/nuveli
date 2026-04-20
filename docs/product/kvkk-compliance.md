# KVKK Uyum Belgesi

Bu belge, Nuveli'nin Türkiye KVKK (Kişisel Verilerin Korunması Kanunu) ve Avrupa GDPR ile uyumlu çalışması için attığı adımları ve yapılması gereken operasyonel uygulamaları tanımlar.

---

## Temel Tanımlar

**Kişisel veri:** Kimliği belirli veya belirlenebilir bir gerçek kişiye ait her türlü bilgi.

**Hassas kişisel veri:** Sağlık bilgileri de buna dahildir. Nuveli sağlık verisi topluyor — bu kategori bizim için kritik.

**İşleme:** Toplama, kaydetme, kullanma, aktarma, silme — hepsi işlemedir.

---

## Topladığımız Veriler

### Hesap ve profil
- E-posta
- Ad (opsiyonel)
- Doğum yılı
- Cinsiyet
- Boy, kilo
- Aktivite seviyesi
- Hedef (kilo ver/koru/al)

### Sağlık verisi (hassas kategori)
- Öğün kayıtları
- Kalori/besin tüketimi
- Su tüketimi
- Kilo geçmişi
- Ruh hali check-in'leri
- Özel durumlar (hamilelik, yeme bozukluğu geçmişi, kronik hastalık)
- Koç sohbet geçmişi

### Teknik veri
- Cihaz tipi, OS versiyonu
- Uygulama versiyonu
- IP adresi (log için, 30 gün sonra silinir)
- Push token

### Kullanım verisi (anonim)
- Ekran görüntülemeleri (Firebase Analytics)
- Buton tıklamaları
- Oturum süresi
- Hata olayları

---

## Amaç ve Hukuki Dayanak

Her veri türü için neden işlediğimiz ve hukuki dayanak:

### Hesap ve profil → Hizmet sunumu
**Dayanak:** Sözleşmenin kurulması ve ifası (KVKK m.5/2-c).
Hesap olmadan hizmet veremeyiz.

### Sağlık verisi → Hizmet sunumu + açık rıza
**Dayanak:** Açık rıza (KVKK m.6/2). Onboarding sırasında açık rıza alınır.
Bu veri olmadan AI analizi, koç desteği ve ilerleme takibi yapılamaz.

### Teknik veri → Meşru menfaat
**Dayanak:** Meşru menfaat (KVKK m.5/2-f). Servis kalitesi, güvenlik.
Log'lar 30 günde otomatik silinir.

### Kullanım verisi → Açık rıza
**Dayanak:** Açık rıza. Onboarding'de isteğe bağlı toggle.
Kullanıcı kapatabilir. Kapattığında Firebase Analytics SDK disable edilir.

---

## Kullanıcı Hakları (KVKK m.11)

Her Nuveli kullanıcısı uygulama içinden şu hakları kullanabilir:

### 1. Bilgi talep etme hakkı
Ayarlar → Gizlilik ve Güvenlik → "Verilerimi Gör"
Kullanıcının hesabındaki tüm veriler JSON olarak gösterilir/indirilir.

### 2. Veriyi düzeltme hakkı
Ayarlar → Profil → düzenle.
Her profil alanı değiştirilebilir.

### 3. Veriyi silme hakkı (hesap silme)
Ayarlar → Hesabı Sil.
30 gün içinde tüm veriler kalıcı olarak silinir.

### 4. İşlemeyi kısıtlama hakkı
Ayarlar → Gizlilik → "Analytics paylaşımı" toggle kapatılabilir.

### 5. İtiraz etme hakkı
support@nuveli.com.tr üzerinden manuel itiraz.

### 6. Veri taşınabilirliği hakkı
"Verilerimi İndir" özelliği yapılandırılmış (JSON) format sağlar. Başka bir servise taşınabilir.

---

## Hesap Silme Detayı

### Kullanıcı "Hesabı Sil" dediğinde

1. Checkbox onayı + "SIL" yazma zorunlu (yanlış tıklamaya karşı)
2. Silme isteği backend'e gönderilir
3. Status "pending_deletion" olarak işaretlenir
4. Kullanıcı çıkışa zorlanır
5. Supabase Auth kullanıcısı "disabled" → 30 gün sonra kalıcı silinir

### 30 günlük geri dönüş süresi
- Kullanıcı fikrini değiştirirse aynı e-posta ile giriş → hesap yeniden aktif
- 30 gün sonra hiçbir yerden geri getirilemez

### Neden 30 gün
- KVKK için spesifik süre yok, "makul süre"
- GDPR'da benzer pratikler 30 gün
- Yanlış tıklamalarda geri dönüş için güvenlik

### Silme kapsamı

**Silinenler:**
- Tüm `profiles`, `meal_logs`, `daily_summaries`, `water_logs`, `weight_logs`, `daily_checkins`
- `coach_threads`, `coach_messages`, `coach_preferences`, `notification_preferences`
- `premium_status_cache`, `usage_counters_daily`
- `meal_analysis_results` (AI analiz ham verileri)
- `device_tokens`, `safety_acknowledgements`
- Supabase Storage'daki koç audio dosyaları
- RevenueCat customer kaydı (API ile deleted olarak işaretlenir)
- Firebase Analytics user properties (API ile silme)

**Silinmeyenler (yasal zorunluluk):**
- Finansal kayıtlar (vergi mevzuatı 5 yıl saklanmalı) — anonimleştirilir
- Güvenlik logları (suçla ilgili) — yargıya teslim edilirse

---

## Veri Depolama ve Lokasyon

### Sunucular
- **Supabase:** EU West (Frankfurt)
- **Render.com:** Frankfurt region (EU)
- **Firebase:** Multi-region (EU aktif)

### Neden EU
- GDPR uyumu zaten sağlanır
- Türkiye KVKK için "yeterli koruma" sağlayan ülkeler arasında
- Düşük gecikme (TR'ye yakın)

### Cross-border transfer
- Kullanıcının verisi Türkiye dışında işlenir (EU'da)
- Onboarding'de bu belirtilir
- Açık rıza alınır

---

## AI (OpenAI) ile Veri Paylaşımı

### Hangi veriler gider

- **Meal analizi:** Yemek fotoğrafı + metin açıklaması
- **Koç yanıtı:** Kullanıcı mesajı + persona/context bilgisi
- **TTS:** Koç yanıt metni

### OpenAI ile anlaşma

- OpenAI Business Associate Agreement (BAA) olmadan **sağlık verisi gönderilmez** — ama Nuveli'de gönderdiğimiz veriler spesifik sağlık tanıtımı içermiyor
- OpenAI "data processor" rolünde, veriyi eğitim için kullanmadıklarını taahhüt ediyor (Platform API opt-out)
- API çağrılarında `X-OpenAI-Organization` header ile organizasyon ID

### Kullanıcı adı ve e-posta OpenAI'ya gitmez
- AI promptlarında kullanıcı kimliği yazılmaz
- "Merhaba Ali, bugün..." değil "Merhaba, bugün..."
- Analytics gibi kullanılmaz

---

## Çocuk Verisi (18 yaş altı)

### Nuveli 18 yaş altı kullanıcıya hizmet vermez

- Yaş kapısı onboarding'de zorunlu
- Profil adımında 18 yaş altı tespit edilirse hesap kilitlenir
- Yaş bypass edilmez

### Şüpheli durumda

Kullanıcının 18 altı olduğu sonradan tespit edilirse (örn. destek yazışmasında):
1. Hesap derhal kilitlenir
2. Tüm verileri hemen silinir (30 gün bekleme yok)
3. Ebeveyn iletişim bilgisi varsa bilgilendirilir

---

## Veri Sızıntısı Müdahale Planı

### Sızıntı tespit edilirse

**Saat 0-6:**
- Sızıntının kapsamı tespit edilir
- Sızıntının devamı engellenir (credential değişir, access kesilir)
- Log'lar korunur

**Saat 6-24:**
- Etkilenen kullanıcı sayısı çıkarılır
- Hangi verilerin sızdığı belirlenir
- Hukuki danışmanlık alınır

**Saat 24-72:**
- KVKK Kuruluna bildirim (yasal zorunluluk 72 saat içinde)
- Etkilenen kullanıcılara e-posta ile bildirim
- Uygulama içi banner gösterim

**Saat 72+:**
- Kamu açıklaması gerekirse
- Düzeltici önlemler (zorunlu şifre sıfırlama, audit, vb.)

### Bildirim şablonu (kullanıcıya)

```
Değerli Nuveli kullanıcısı,

[tarih] tarihinde sistemlerimizde bir güvenlik olayı tespit ettik.

Ne oldu: [açıklama]
Hangi verilerin etkilendiği: [liste]
Ne yaptık: [önlemler]
Sen ne yapmalısın: [eylemler — şifre değiştirme, vs.]

Seninle dürüst olmak bizim için önemli. Sorularını
support@nuveli.com.tr'e iletebilirsin.

Nuveli Ekibi
```

---

## Çerezler ve Web Sitesi

### nuveli.com.tr landing
- Essential cookies sadece (session, CSRF)
- Analytics yok (v1)
- Üçüncü parti çerez yok
- Cookie banner gerekmez (essential-only olduğumuz için)

### nuveli.com.tr/app (abonelik portalı)
- Supabase auth cookie'si
- Stripe checkout iframe (Stripe'ın kendi politikası)
- Cookie banner gösterilmez (essential)

### Değiştirirsek

Gelecekte analytics eklersek:
- Cookie consent banner zorunlu
- Opt-in modeli (default OFF)
- Granüler kontrol (analytics/marketing ayrı)

---

## Üçüncü Parti Hizmetler

### Tam liste (KVKK'ya kayıt için gerekli)

| Hizmet | Amaç | Veri Paylaşımı | Lokasyon |
|--------|------|---------------|----------|
| Supabase | Auth + DB + Storage | Tüm veriler | Frankfurt, EU |
| OpenAI | AI | Sınırlı (yukarıda) | USA (OpenAI's controller) |
| RevenueCat | Abonelik | Email, UserID | USA |
| Stripe | Ödeme | Ödeme bilgisi | USA (PCI-DSS) |
| Firebase | Push + Analytics + Crash | Device token, event'ler | USA |
| Render.com | Backend hosting | Log'lar | Frankfurt, EU |
| Cloudflare | CDN | IP, headers | Global |

### Her biri için sözleşme

KVKK/GDPR Data Processor Agreement her üçüncü parti ile imzalı olmalı. Çoğu self-serve online agreement (Supabase, Firebase, RevenueCat).

---

## Gizlilik Politikası ve Kullanım Şartları

### Gizlilik politikası — içerik

Zaten yazılı (`landing/gizlilik.html`). İçerik:
1. Hangi veriler toplanır
2. Neden toplanır
3. Kimlerle paylaşılır
4. Ne kadar saklanır
5. Hakların neler (KVKK m.11)
6. İletişim nasıl kurulur

### Kullanım şartları — içerik

Zaten yazılı (`landing/sartlar.html`). İçerik:
1. Hizmet tanımı
2. Yaş sınırı
3. Kullanıcı sorumlulukları
4. Sağlık uyarısı
5. Abonelik şartları
6. Fikri mülkiyet
7. Sorumluluk sınırı

### Güncellenme

Politika değişirse:
- Uygulama içi bildirim (uygulama açılınca modal)
- E-posta ile bildirim
- Eski versiyonlar web'de erişilebilir
- Kullanıcı kabul etmezse hesap dondurulur

---

## İç Operasyonel Kontroller

### Erişim kontrolleri
- Geliştiriciler sadece geliştirme ortamına erişir
- Prod veritabanına erişim sadece yetkili kişide
- Audit log aktif (kim ne sorgulamış)

### Şifreleme
- DB'de at-rest encryption (Supabase otomatik)
- In-transit TLS 1.3
- OpenAI API çağrıları HTTPS
- Koç audio dosyaları Storage'da şifreli

### Backup
- Supabase günlük backup (7 gün saklanır)
- Backup'lar da şifrelidir

### Audit
- Her 3 ayda bir iç audit
- Gereksiz veri toplama var mı
- Eski loglar siliniyor mu
- Hesap silme gerçekten çalışıyor mu

---

## Kayıtlı Kontrolör Atama

Türkiye'de VERBIS (Veri Sorumluları Sicili) kaydı 2 çalışanı ve yıllık 2 milyon TL ciro üstü şirketler için zorunlu. Nuveli bu sınıra ulaştığında:

1. VERBIS'e kayıt
2. Veri İşleyen ve Veri Sorumlusu atama
3. Kişisel Veri İşleme Envanteri
4. İmha Politikası
5. Teknik ve İdari Tedbirler belgesi

**MVP aşamasında bunlar gerekli değil ama hazırlığı yapılmalı.**

---

## Kullanıcı Talebi İş Akışı

### "Verilerimi görmek/silmek istiyorum" e-postası gelirse

**1. Doğrulama (saat 0-24):**
- E-posta doğrulama (hesaba kayıtlı e-postadan gelmeli)
- Gerekirse ek kimlik doğrulama

**2. İşlem (saat 24-72):**
- **Bilgi talebi:** JSON export, e-posta ile gönderim
- **Silme talebi:** Hesap silme akışı başlatılır
- **Düzeltme talebi:** İlgili alan güncellenir, kullanıcıya onay

**3. Yanıt (saat 72 içinde):**
- KVKK m.13: 30 gün içinde ücretsiz yanıt. Biz 72 saati hedefliyoruz.
- Yazılı yanıt, hangi işlemi yaptığımız belirtilir

---

## Yapılmayanlar (bilinçli)

- **Üçüncü parti reklam** — hiç koymuyoruz. Veri reklam amacıyla işlenmez.
- **Datalayer satışı** — asla kullanıcı verisi satılmaz (bu zaten yasal değil).
- **Influencer'a dashboard açma** — ortaklıklar anonim metriklerle yapılır.
- **B2B satış (enterprise)** — şimdilik yok. Olursa ayrı veri işleme anlaşmaları gerekir.

---

## Özet

Nuveli hassas sağlık verisi işlediği için KVKK/GDPR uyumu **opsiyonel değil**. Bu belge:
- Hangi verileri işlediğimizi
- Hangi hukuki dayanakla işlediğimizi
- Kullanıcı haklarını nasıl sağladığımızı
- Sızıntı durumunda ne yapacağımızı
- Hangi üçüncü parti servislerle çalıştığımızı

tanımlar.

**Launch öncesi yapılacak:**
- Gizlilik politikası yasal danışmandan geçsin
- Kullanım şartları yasal danışmandan geçsin
- VERBIS kayıt eşiği kontrol edilsin
- Tüm üçüncü parti hizmetlerin DPA (Data Processing Agreement) imzalanmış olsun
- Veri sızıntısı müdahale prosedürü test edilsin (tatbikat)

**Launch sonrası sürekli:**
- 3 ayda bir iç audit
- Kullanıcı talepleri 72 saatte yanıtlanır
- Yeni özellik geldiğinde KVKK impact assessment
