# Backend Deployment Guide

Nuveli backend'i production'a deploy etme rehberi. 3 platform desteklenir:

| Platform | Maliyet | Özellik |
|----------|---------|---------|
| **Render.com** | Free tier mevcut, $7/ay starter | En kolay, Docker, auto-deploy |
| **Fly.io** | Free tier mevcut, $1.94/ay başlangıç | Global edge, hızlı, Docker |
| **AWS / GCP** | Pay-as-you-go | Kurumsal, ölçeklenebilir |

> **Önerim:** Başlangıç için **Render.com**. Trafik artarsa Fly.io'ya geç.

---

## Önkoşullar

Backend deploy edilmeden önce:
- ✅ Supabase projesi oluşturulmuş, URL + service role key alınmış
- ✅ OpenAI API key (https://platform.openai.com/api-keys)
- ✅ RevenueCat webhook secret (RevenueCat dashboard → Project Settings → Webhooks)
- ✅ GitHub repo public veya CI access verilmiş
- ✅ `Dockerfile`, `render.yaml`, `fly.toml` dosyaları repo'da (✅ hazır)

---

## Yöntem 1: Render.com (Önerilen)

### 1. Hesap oluştur
https://render.com → Sign up with GitHub

### 2. Yeni Blueprint
- Dashboard → **New** → **Blueprint**
- GitHub repo: `alimirbagirzade/nuveli`
- Render `render.yaml`'i otomatik tespit eder ✅
- "Apply" butonuna bas

### 3. Environment variables ekle
Render dashboard → `nuveli-backend` service → **Environment**:

```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_JWT_SECRET=your-jwt-secret-min-32-chars
OPENAI_API_KEY=sk-...
REVENUECAT_WEBHOOK_SECRET=your-webhook-secret
```

> **NOT:** `ENV=production` ve `PORT` Render tarafından otomatik set edilir.

### 4. Deploy
- "Manual Deploy" → "Deploy latest commit"
- Build log'ları izle: ~3-5 dakika
- Deployed URL: `https://nuveli-backend.onrender.com`

### 5. Test
```bash
curl https://nuveli-backend.onrender.com/health
# {"status":"healthy","service":"nuveli-backend","version":"1.0.0","env":"production"}
```

### 6. Flutter app'i bağla
`app/.env.production`:
```bash
API_URL=https://nuveli-backend.onrender.com
ENV=production
```

---

## Yöntem 2: Fly.io

### 1. Fly CLI kur
```bash
# macOS
brew install flyctl

# Linux/WSL
curl -L https://fly.io/install.sh | sh
```

### 2. Login
```bash
fly auth login
```

### 3. App oluştur (ilk kez)
```bash
cd ~/development/nuveli
fly launch
```

`fly.toml` zaten hazır. Sadece onayla:
- App name: `nuveli-backend`
- Region: `fra` (Frankfurt) veya `iad` (US-East)
- Postgres: `No` (Supabase kullanıyoruz)
- Deploy now: `No` (önce secrets)

### 4. Secrets ekle
```bash
fly secrets set SUPABASE_URL=https://xxx.supabase.co
fly secrets set SUPABASE_SERVICE_ROLE_KEY=eyJ...
fly secrets set SUPABASE_JWT_SECRET=your-jwt-secret
fly secrets set OPENAI_API_KEY=sk-...
fly secrets set REVENUECAT_WEBHOOK_SECRET=your-secret
```

### 5. Deploy
```bash
fly deploy
```

### 6. Test
```bash
curl https://nuveli-backend.fly.dev/health
fly logs   # Real-time log
fly status # Health check
```

---

## Yöntem 3: Docker (Self-hosted)

### Local test
```bash
cd backend
docker build -t nuveli-backend .
docker run -p 8000:8000 \
  -e SUPABASE_URL=... \
  -e SUPABASE_SERVICE_ROLE_KEY=... \
  -e SUPABASE_JWT_SECRET=... \
  -e OPENAI_API_KEY=... \
  -e REVENUECAT_WEBHOOK_SECRET=... \
  nuveli-backend

curl http://localhost:8000/health
```

### Production (DigitalOcean Droplet, AWS EC2, vs.)
```bash
# 1. Server'a Docker kur
# 2. Image'ı transfer et
docker save nuveli-backend | ssh user@server 'docker load'

# 3. Run
ssh user@server
docker run -d \
  --name nuveli \
  --restart unless-stopped \
  -p 80:8000 \
  --env-file /etc/nuveli/.env \
  nuveli-backend
```

---

## Production Checklist

Deploy öncesi son kontroller:

### Backend
- [ ] `ENV=production` set edilmiş
- [ ] CORS `allow_origins` production domain'ler
- [ ] `/docs` endpoint kapatılmış (otomatik, settings.is_production)
- [ ] Rate limiting aktif (TODO: slowapi entegrasyonu)
- [ ] Sentry/error tracking bağlı (opsiyonel)
- [ ] Database migration'ları run edildi

### Database (Supabase)
- [ ] Production project ayrı (dev'den izole)
- [ ] Row Level Security (RLS) aktif tüm tablolarda
- [ ] Backup otomatik (Supabase → Settings → Database → Backups)
- [ ] Connection pooling açık

### Security
- [ ] `.env` GitHub'a commit edilmemiş (`.gitignore` ✅)
- [ ] Service role key sadece backend'de (Flutter'da YOK)
- [ ] HTTPS zorunlu (Render/Fly otomatik)
- [ ] JWT secret en az 32 karakter
- [ ] OpenAI API key rate limit set edilmiş

### Monitoring
- [ ] Health check endpoint çalışıyor (`/health`)
- [ ] Deploy alerting (Render/Fly auto-email)
- [ ] Cost alerting (OpenAI, Supabase)
- [ ] Crashlytics (Flutter) production key'i

### Performance
- [ ] Cold start <3 saniye
- [ ] Free tier limitler bilinçli (Render: 750 saat/ay, sleep)
- [ ] Database index'leri kontrol edildi (yavaş query yok)

---

## Sorun Giderme

### "Application failed to respond" (Render)
- Build log: PORT env yanlış olabilir → `$PORT` kullandığından emin ol
- Health check: `/health` 200 dönüyor mu?
- Memory: 512MB yetiyor mu? (model çağrıları RAM yer)

### "Unhealthy" (Fly.io)
```bash
fly logs           # Detaylı log
fly ssh console    # Container içine gir
fly checks list    # Health check status
```

### CORS hatası (Flutter)
Backend log'unda "Origin not allowed" görüyorsan:
1. `app/main.py` `allow_origins` listesine domain ekle
2. Production'da `*` kullanma

### Rate limit (OpenAI)
Free tier: 3 request/dakika. Production:
- Pay-as-you-go'ya geç ($5+ kredi)
- Caching ekle (aynı meal foto için)
- Retry logic backend'de (`tenacity` paketi)

---

## Maliyet Tahmini

**Aylık 1000 aktif kullanıcı için:**

| Servis | Plan | Aylık |
|--------|------|-------|
| Render Backend | Starter | $7 |
| Supabase | Free | $0 (50K satır limit) |
| OpenAI Vision | Pay-as-you-go | $30-50 |
| OpenAI TTS | Pay-as-you-go | $5-10 |
| RevenueCat | Free | $0 (<$10K MTR) |
| Firebase | Spark | $0 |
| **TOPLAM** | | **~$45-70** |

**Gelir hedefi:** 50 ücretli kullanıcı × $5 = $250/ay → **3-5x ROI**

---

## Sonraki Adımlar

1. ✅ Backend deploy edildi
2. 🔜 Flutter `.env.production` oluştur, API_URL'i set et
3. 🔜 `flutter build ipa` (iOS) / `flutter build appbundle` (Android)
4. 🔜 TestFlight / Play Internal Testing
5. 🔜 App Store / Play Store submission

Bkz. `docs/DEPLOYMENT.md` (mobile app deployment).
