# 🍎 Apple Privacy Nutrition Label

**Hedef:** App Store Connect → App Privacy → Data Collection formu için tam doldurma rehberi.

⚠️ **Önemli:** Apple bu form'u **dikkatle inceler**. Eksik veya yanlış doldurma 5.1.1 reject sebebidir (Privacy Practices Inaccurate).

---

## 📋 Genel Sorular

### Soru 1: "Do you or your third-party partners collect data from this app?"
**Cevap:** ✅ **Yes**

### Soru 2: Hangi veri kategorileri toplanır?

Aşağıdaki tablo App Store Connect'te işaretlenecek olan kategorilerdir:

---

## 📊 Data Type Detayları

### 1. ✅ Contact Info — **Email Address**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| **Linked to user?** | **Yes** (account ile bağlı) |
| **Used for tracking?** | **No** |
| **Used for:** | App Functionality, Account Management |

**Açıklama:** Hesap oluşturma ve giriş için email kullanıyoruz. Marketing veya tracking için kullanmıyoruz.

---

### 2. ✅ Contact Info — **Name** (opsiyonel)

| Soru | Cevap |
|---|---|
| Data collected? | Yes (optional) |
| Linked to user? | Yes |
| Used for tracking? | No |
| Used for: | App Functionality, Personalization |

**Açıklama:** Kullanıcı profili ve AI Coach'ta hitap için (örn. "Günaydın Ali").

---

### 3. ✅ Health & Fitness — **Health**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | Yes |
| Used for tracking? | No |
| Used for: | App Functionality, Personalization, Analytics |

**Toplanan sağlık verileri:**
- Kilo, boy, yaş, cinsiyet (BMR/TDEE hesabı için)
- Yemek logları (kalori, makro)
- Su tüketimi
- Apple Health'ten senkron (Premium): adımlar, antrenmanlar

**Açıklama:** Beslenme koçluğu sağlamak için sağlık verilerini topluyoruz. Tüm veriler şifreli ve Frankfurt EU'da saklanır.

---

### 4. ✅ Health & Fitness — **Fitness**

| Soru | Cevap |
|---|---|
| Data collected? | Yes (Premium only, opt-in) |
| Linked to user? | Yes |
| Used for tracking? | No |
| Used for: | App Functionality, Personalization |

**Açıklama:** Apple HealthKit entegrasyonu sayesinde adım sayısı ve antrenmanlar (kullanıcı izni gerekir).

---

### 5. ✅ Identifiers — **User ID**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | Yes |
| Used for tracking? | No |
| Used for: | App Functionality, Account Management |

**Açıklama:** Supabase Auth tarafından üretilen UUID. Hesabı tanımlamak için.

---

### 6. ✅ Identifiers — **Device ID**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | No (anonymized) |
| Used for tracking? | No |
| Used for: | Analytics, App Functionality |

**Açıklama:** Crash report ve analytics için (Firebase). Reklam için kullanılmıyor. IDFA (Identifier for Advertisers) **toplanmıyor**.

⚠️ **ATT (App Tracking Transparency):** Bu app IDFA istemiyor. ATT prompt göstermiyoruz.

---

### 7. ✅ Usage Data — **Product Interaction**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | Yes (hesap bazlı) |
| Used for tracking? | No |
| Used for: | Analytics, App Functionality |

**Açıklama:** Hangi ekranlar ziyaret edildi, hangi butonlar tıklandı (Firebase Analytics).

---

### 8. ✅ Diagnostics — **Crash Data**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | No (anonymized) |
| Used for tracking? | No |
| Used for: | App Functionality |

**Açıklama:** Firebase Crashlytics. Çökme nedenini bulmak için, marketing'e bağlı değil.

---

### 9. ✅ Diagnostics — **Performance Data**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | No |
| Used for tracking? | No |
| Used for: | App Functionality |

**Açıklama:** App load time, API response time. Anonim.

---

### 10. ✅ Purchases — **Purchase History**

| Soru | Cevap |
|---|---|
| Data collected? | Yes |
| Linked to user? | Yes |
| Used for tracking? | No |
| Used for: | App Functionality (subscription management) |

**Açıklama:** RevenueCat ve Apple/Google üzerinden yönetilir. Premium durumu kontrolü için.

---

### 11. ✅ User Content — **Photos** (meal scan)

| Soru | Cevap |
|---|---|
| Data collected? | Yes (optional) |
| Linked to user? | Yes |
| Used for tracking? | No |
| Used for: | App Functionality, AI Processing |

**Açıklama:**
- Yemek fotoğrafları AI analiz için OpenAI'ya gönderilir
- EXIF metadata (konum, kamera info) silinerek gönderilir
- 90 gün sonra otomatik silinir
- OpenAI bunları training için kullanmaz (API tier policy)

---

## ❌ TOPLAMADIĞIMIZ Veri Kategorileri

Apple form'unda **"No"** seçilecekler:

- ❌ Location (Precise) — GPS toplamıyoruz
- ❌ Location (Coarse) — IP geolocation toplamıyoruz, sadece country-level inference
- ❌ Browsing History
- ❌ Search History
- ❌ Contacts (telefon defteri)
- ❌ Audio Data (mikrofon)
- ❌ Video Data (kamera sadece foto için)
- ❌ Sensitive Info (din, etnik köken, vb.)
- ❌ Other Financial Info (kredi kartı doğrudan değil — Apple/Google işler)
- ❌ Credit Info
- ❌ Other Diagnostic Data (sadece crash ve performance)
- ❌ Customer Support (formdan ayrı — email iletişimi tracking değil)
- ❌ Gameplay Content (oyun değil)
- ❌ Advertising Data
- ❌ Other Data Types

---

## 🚨 KRİTİK: "Data Used to Track You" Bölümü

Apple'ın en hassas sorusu: **"Do you use data to track users across apps and websites owned by other companies?"**

**Cevap:** ❌ **NO**

Bu cevap çok önemli çünkü:
- ✅ "No" dersek ATT prompt göstermek **zorunda değiliz**
- ❌ "Yes" dersek IDFA için izin sorma zorunlu, conversion %30 düşer

**Doğrulama:**
- Reklam SDK kullanmıyoruz (Facebook SDK, Google Ads SDK yok)
- Cross-app tracking yapmıyoruz
- Verileri ad networks ile paylaşmıyoruz

⚠️ **Eğer ileride Facebook SDK eklersek bu "Yes" olur. Şimdilik temiz.**

---

## 📋 App Store Connect'te Adım Adım

### Form Doldurma

1. **App Store Connect** → **App Privacy** sekmesi
2. **Data Collection** → "Yes"
3. Her data type için:
   - Click "Add Data Type"
   - Kategori seç (örn. "Health & Fitness")
   - Sub-type seç (örn. "Health")
   - "Used for" işaretle (App Functionality, Analytics, vb.)
   - "Linked to identity": Yes/No
   - "Used for tracking": No
   - "Optional or Required" belirt
4. **Data Used to Track You** bölümü → "No"
5. **Privacy Policy URL:** `https://nuveli.app/privacy`
6. **Save**

### Preview

Save sonrası App Store'da görünecek "Privacy Label" preview'unu kontrol et. Şöyle gözükmeli:

```
🟢 Data Not Linked to You:
   • Diagnostics
   • Identifiers (Device ID)

🟡 Data Linked to You:
   • Contact Info
   • Health & Fitness
   • Identifiers (User ID)
   • Usage Data
   • Purchases
   • User Content (Photos)

🔴 Data Used to Track You:
   (Nothing — temiz!)
```

---

## 🚨 Reject Riski Kontrolü

Apple Reviewer'ın gözünden:

| Risk | Önleme |
|---|---|
| Health verileri "Not Linked" olarak işaretlersen | Yanlış — kesinlikle "Linked to User" |
| User Content (photos) eksik | Meal scan fotoğrafları için zorunlu |
| Crash data "Linked to User" işaretlersen | Yanlış — anonim |
| "Used for tracking" yanlışlıkla işaretlersen | ATT prompt zorunluluğu doğar, reject yağmuru |
| Privacy Policy URL erişilemez | Önce host et, sonra submit |
| Backend'e gönderilen sensitive data eksik | OpenAI'ya giden photo'ları unutma |

---

## ✅ Final Checklist

Submission öncesi son kontrol:

- [ ] Tüm 11 data type doğru işaretlendi
- [ ] "Used to Track You" = NO
- [ ] Privacy Policy URL canlı (https://nuveli.app/privacy)
- [ ] App içinde Settings → Privacy Policy linki çalışıyor
- [ ] Onboarding'de explicit consent var
- [ ] Meal scan permission ifadesi açık ("Photos used for AI nutrition analysis")
- [ ] OpenAI'ya veri gönderildiği transparent olarak belirtilmiş
- [ ] EU sunucu lokasyonu (Frankfurt) Privacy Policy'de belirtilmiş

---

## 📞 Reject Sonrası Apel Stratejisi

Eğer Apple "Privacy Practices not accurate" diye reject ederse:

1. **Resolution Center'da reviewer'a yanıt yaz:**
   ```
   Hello Apple Reviewer,
   
   Thank you for your feedback. We have reviewed our privacy practices and confirm:
   
   1. Health data is collected to provide nutrition coaching functionality (Section X of our Privacy Policy at nuveli.app/privacy)
   2. Meal photos are processed by OpenAI's API solely for AI nutrition analysis. They are not used for AI training (per OpenAI's API data policy).
   3. We do not engage in cross-app tracking; we do not collect IDFA.
   
   We have not changed any data practices, only clarified our privacy label entries. Please confirm if additional documentation is needed.
   ```

2. **Eğer reviewer Privacy Policy bağlantısını test edemediyse:** URL'i kontrol et, response içinde direct link ver.

3. **Eğer "Health data işlemi yetersiz açıklama" diye gelirse:** Privacy Policy'de Section 2.2'yi genişlet, örnek veri akışını ekle.

---

**Önemli:** Bu Privacy Label, **app güncellemelerinde otomatik güncellenmez**. Yeni özellik eklediğinde (örn. mikrofon entegrasyonu) form'u tekrar düzenle, yoksa Apple onaylamaz.
