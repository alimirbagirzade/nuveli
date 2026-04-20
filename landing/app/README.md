# Nuveli Web — Abonelik Portalı

nuveli.com.tr/app üzerinden web aboneliği (Stripe tabanlı RevenueCat Web Billing).

## Mimari

```
Tarayıcı (nuveli.com.tr/app)
   ↓
index.html + src/main.js + src/revenuecat.js + src/supabase.js
   ↓
┌─────────────────────┬──────────────────────────┐
│ @revenuecat/purch-js│ @supabase/supabase-js    │
│ (paywall + checkout)│ (magic link auth)        │
└─────────────────────┴──────────────────────────┘
          ↓                        ↓
     Stripe (RC yönetir)     Supabase Auth
```

**Önemli:** Kullanıcı web'de veya mobilde abone olduğunda aynı Supabase user ID, RC `app_user_id` olarak kullanıldığı için entitlement her iki platformda da aktif olur.

---

## Ön hazırlık (RevenueCat Dashboard)

1. **Apps & providers** → yeni **Web Billing** app ekle
2. Stripe hesabını bağla
3. **Public API Key**'i kopyala (bu frontend'e gider, güvenli)
4. **Products**:
   - `monthly` → Aylık abonelik (Stripe recurring)
   - `yearly` → Yıllık abonelik
   - `lifetime` → Tek seferlik ömür boyu
5. **Offerings** → "default" offering oluştur, paketleri ekle:
   - `$rc_monthly` → monthly product
   - `$rc_annual` → yearly product
   - `$rc_lifetime` → lifetime product
6. **Entitlements** → `nuveli_pro` entitlement'ı oluştur, 3 product'ı da bağla
7. **Paywalls** → offering için paywall tasarla (template seç + özelleştir)
8. **Webhook**: Settings → Integrations → Webhooks →
   URL: `https://api.nuveli.com.tr/premium/webhook/revenuecat`
   Authorization header: (rastgele bir secret oluştur → `REVENUECAT_WEBHOOK_SECRET` env var'ına koy)

---

## Geliştirme (local)

```bash
cd landing/app
cp .env.example .env
# .env'i doldur:
#   VITE_REVENUECAT_PUBLIC_KEY=...
#   VITE_SUPABASE_URL=...
#   VITE_SUPABASE_ANON_KEY=...
#   VITE_RC_ENTITLEMENT_ID=nuveli_pro

npm install
npm run dev
# http://localhost:5173
```

---

## Production build

```bash
cd landing/app
npm install
npm run build
# Çıktı: dist/
```

### Deploy — cPanel'e yükleme

1. `dist/` içindekileri cPanel → `public_html/app/` içine kopyala
2. `index.html` + `assets/` klasörü olmalı
3. Ana landing (`public_html/index.html`) zaten var → abonelik portalına link:

```html
<!-- landing/index.html içinde "Abone Ol" butonu -->
<a href="/app/" class="btn-primary">Nuveli Pro</a>
```

---

## Sertifika (HTTPS zorunlu)

RevenueCat Web Billing SADECE HTTPS üzerinde çalışır. Stripe checkout bundan başka türlü açılmaz. cPanel → SSL/TLS Status → Let's Encrypt otomatik aktif et.

---

## Test etme

1. **Sandbox key** ile (RC dashboard'da `Sandbox API Key`) .env dosyasını doldur
2. `npm run dev` → `http://localhost:5173`
3. E-posta gir → Supabase'den magic link gelir
4. Link'e tıkla → giriş tamam
5. Paywall aç → RC **test kartı** ile dene: `4242 4242 4242 4242`, CVC: `123`, son kullanma: gelecek bir tarih
6. Satın alma sonrası pro state'e geç

---

## Mobil app ile senkronizasyon

Kullanıcı web'de abone olduğunda:
1. RC → `nuveli_pro` entitlement aktif
2. RC webhook → backend `/premium/webhook/revenuecat`
3. Backend → `premium_status_cache` tablosunda `tier: premium` olarak kaydeder
4. Mobil app açıldığında → `/premium/status` endpoint'i `premium` döner → app kilidini açar

Aynı yönde: mobil app'te abone olursa web'de de entitlement aktif olur (tek RC projesi, tek user ID).

---

## Bilinen kısıtlar

- **Anonymous customer desteği yok** — Supabase login zorunlu. Bu, mobil-web entitlement birleşmesi için gerekli.
- **Redemption Links kullanılmıyor** — çünkü kullanıcı zaten auth'lu. RC dashboard'ında Redemption Links kapalı bırakılabilir.
- **Browser storage kullanılır** — Supabase session için `localStorage`. GDPR/KVKK banner gerekebilir, ama bu çerez değil, auth session'dır, iyi bir pratik önemli.

---

## Özel not — Güvenlik

- `.env` dosyasını ASLA commit etme (`.gitignore`'da zaten var)
- Public API Key ve Supabase anon key frontend'e gömülür, bu normal — RLS verileri korur
- Service role key ve RC secret key SADECE backend'de (Render.com env vars)
- Webhook secret de sadece backend'de
