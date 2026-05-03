# Nuveli Premium — App Store Connect Kurulum Rehberi

**Hedef:** Apple Developer hesabı aktif olduktan sonra premium subscription'ları kur.

## Fiyatlandırma stratejisi

Cal AI rakibinden %40 daha ucuz:

| Plan | Fiyat (TL) | Fiyat (USD ~kur 33) | Trial |
|------|-----------|---------------------|-------|
| Aylık | 49 TL | ~$1.50 | 7 gün ücretsiz |
| Yıllık | 599 TL | ~$18 | 7 gün ücretsiz |

Yıllık aboneliğin aylık karşılığı: 49.92 TL → **aylık planla aynı**, ama **bir kerede** ödüyorlar. Conversion için yıllık daha cazip görünsün diye fiyat tier seçimini öyle yap.

## Adım 1: Apple Developer kayıt
1. https://developer.apple.com/programs/enroll
2. Individual üyelik ($99/yıl ~3300 TL)
3. **Apple Small Business Program**'a başvur (yıllık geliri $1M altı için %15 komisyon, otomatik onay)
4. Onay 24-48 saat

## Adım 2: App Store Connect'te app oluştur
1. https://appstoreconnect.apple.com → My Apps → +
2. Bundle ID: `com.nuveli.app`
3. SKU: `nuveli-ios-001`
4. Primary Language: Turkish

## Adım 3: Subscription Group oluştur
1. App Store Connect → Nuveli → Monetization → Subscriptions
2. **Create Subscription Group:**
   - Reference Name: `Nuveli Premium`
   - Subscription Group Display Name: `Nuveli Premium`

## Adım 4: Aylık subscription
1. Subscription Group → Create Subscription
2. **Reference Name:** `Nuveli Monthly`
3. **Product ID:** `nuveli_monthly_49` ⚠️ (sabit, kod buna referans verir)
4. **Subscription Duration:** 1 Month
5. **Subscription Pricing:**
   - Türkiye: ₺49.99 (Tier 6)
   - Diğer ülkeler: Apple'ın otomatik kur dönüşümünü kullan
6. **Localization (Turkish):**
   - Display Name: `Aylık Premium`
   - Description: `Sınırsız AI yemek analizi, sınırsız koç sohbeti, haftalık derin analiz`
7. **Introductory Offer:**
   - Type: Free
   - Duration: 7 Days
   - Eligible Customers: New Subscribers

## Adım 5: Yıllık subscription
1. Subscription Group → Create Subscription
2. **Reference Name:** `Nuveli Yearly`
3. **Product ID:** `nuveli_yearly_599`
4. **Subscription Duration:** 1 Year
5. **Subscription Pricing:**
   - Türkiye: ₺599 (en yakın tier'a yuvarla)
6. **Localization (Turkish):**
   - Display Name: `Yıllık Premium (en avantajlı)`
   - Description: `Sınırsız AI yemek analizi, sınırsız koç sohbeti, haftalık derin analiz. 12 ay tek seferde — aylık fiyatla aynı.`
7. **Introductory Offer:**
   - Type: Free
   - Duration: 7 Days

## Adım 6: RevenueCat bağlantısı
1. https://app.revenuecat.com → Project Settings → Apps → iOS
2. **App Store Connect API Key** ekle:
   - App Store Connect → Users and Access → Keys → +
   - Role: App Manager
   - Download `.p8` file
   - Key ID + Issuer ID kopyala
3. RevenueCat'te paste et
4. **Products** sekmesi → otomatik sync
5. **Offerings** oluştur:
   - Default offering içinde:
     - Monthly package → `nuveli_monthly_49`
     - Annual package → `nuveli_yearly_599`
6. **Entitlement** oluştur:
   - ID: `premium`
   - Hem aylık hem yıllık ürünü bu entitlement'a bağla

## Adım 7: Frontend entegrasyon doğrulama
RevenueCat key zaten kodda var ama boş gelir. Apple Developer'dan API key gelince:

`.env.development` ve `.env.production`:
Frontend `app_config.dart` zaten bunu okur. Ekstra kod değişikliği yok.

## Adım 8: Sandbox test
1. App Store Connect → Users and Access → Sandbox Testers → +
2. Yeni sandbox tester yarat (gerçek e-posta + şifre)
3. iOS Simulator'da:
   - Settings → App Store → Sign Out (gerçek hesap)
   - Sandbox tester ile sign in
4. Nuveli'de paywall'a git → "Satın al" → sandbox satın alımı dene
5. Trial 7 gün başlamalı, gerçek para çekilmemeli

## Adım 9: Subscription review
Apple subscription'ları **app review** sırasında ayrı inceler:
- Localization metinleri açıklayıcı olmalı
- Premium features listesi clear olmalı
- Restore Purchases butonu çalışmalı (kod zaten var)
- Privacy Policy URL'i Subscription Terms içermeli

## Maliyet analizi (referans için)

**Free user maliyeti** (3 fotoğraf + 3 mesaj/gün ile):
- OpenAI: $0.10-0.15/ay/user
- Supabase + Render: marjinal

**Aylık abone net gelir** (Apple Small Business %15 sonrası):
- 49 TL × %85 = 41.65 TL net
- ~$1.26/ay net
- 1 abone = 8-12 free user'ı amorte eder

**Yıllık abone net gelir:**
- 599 TL × %85 = 509 TL net
- ~$15.40/yıl net
- 1 yıllık abone = 100-150 free user'ı amorte eder

**Break-even için gereken conversion:**
- 100 free user'a 1 yıllık abone yeterli (% 1 conversion)
- Bu sektör ortalaması (%2-5 conversion)'ın çok altında, gerçekçi hedef
