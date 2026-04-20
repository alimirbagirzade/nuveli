# Nuveli — Hızlı Başlangıç

ZIP'i açtın, şimdi ne yapacaksın? Aşağıdaki sırayı takip et.

---

## ⚠️ ÖNCE GÜVENLİK

Chat'te paylaştığın `11c3321d-...` UUID değerini **hemen iptal/değiştir**. Hangi servisin key'i ise (cPanel, Supabase, RevenueCat, Firebase, vb.) o servisin panelinden yenile. Bir daha API key veya token değerlerini chat'te paylaşma.

---

## 1️⃣ GitHub'a Push Et (5 dk)

ZIP'i bir klasöre çıkart ve terminal aç:

```bash
cd nuveli
bash deploy/push-to-github.sh
```

> İlk seferinde GitHub kullanıcı adı + Personal Access Token isteyecek.
> Token oluşturmak için: https://github.com/settings/tokens → "Generate new token (classic)" → `repo` yetkisi seç.

Push bittiğinde → https://github.com/alimirbagirzade/Nuveli dolu olacak.

---

## 2️⃣ Supabase (15 dk)

1. https://supabase.com/dashboard → **New Project**
2. **SQL Editor** → sırayla çalıştır:
   - `backend/migrations/001_initial_user_tables.sql`
   - `backend/migrations/002_meal_and_summary_tables.sql`
   - `backend/migrations/003_coach_tables.sql`
3. **Settings → API** → üç değeri not al:
   - Project URL
   - anon public key
   - service_role key (GİZLİ — sadece backend)
4. **Settings → API → JWT Settings** → JWT Secret'ı not al

---

## 3️⃣ Backend Deploy — Render.com (10 dk)

1. https://render.com → **Connect GitHub** → `Nuveli` reposunu seç
2. **New → Web Service** ayarlar:
   - Root Directory: `backend`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
3. Environment Variables ekle:
   ```
   APP_ENV=production
   SUPABASE_URL=<Supabase Project URL>
   SUPABASE_SERVICE_ROLE_KEY=<service_role key>
   SUPABASE_JWT_SECRET=<JWT Secret>
   OPENAI_API_KEY=<OpenAI key — opsiyonel, meal analizi için>
   ```
4. **Create Web Service** → 5 dk bekle
5. Test: `https://nuveli-api.onrender.com/health` → `{"status":"ok"}` dönmeli

---

## 4️⃣ Landing Page — cPanel'e Yükle (10 dk)

1. cPanel → **File Manager** → `public_html/`
2. İçini boşalt (default index.html gibi şeyleri sil)
3. `landing/` klasöründeki **tüm dosyaları** (index.html, gizlilik.html, sartlar.html, favicon.svg, robots.txt, sitemap.xml) seç → upload
4. Tarayıcıda `https://nuveli.com.tr` → çalışıyor olmalı
5. cPanel → **SSL/TLS Status** → Let's Encrypt (ücretsiz SSL) otomatik etkinleştir

---

## 5️⃣ `api.nuveli.com.tr` Subdomain Bağlama (5 dk)

1. cPanel → **Subdomains** → `api` subdomain oluştur
2. cPanel → **Zone Editor** (veya DNS) → **Add Record**:
   - Type: `CNAME`
   - Name: `api`
   - Points to: `nuveli-api.onrender.com` (Render URL'in)
3. Render → Web Service → **Settings → Custom Domain** → `api.nuveli.com.tr` ekle
4. 5-30 dk DNS propagation → `https://api.nuveli.com.tr/health` çalışmalı

---

## 6️⃣ Flutter App Build (sonra)

Bu aşama App Store / Play Store developer hesapları gerektirir (₺~$99/yıl Apple, $25 one-time Google).

Şimdilik local test için:
```bash
cd app
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=API_BASE_URL=https://api.nuveli.com.tr
```

---

## ✅ Checklist

- [ ] UUID iptal edildi
- [ ] GitHub repo dolu
- [ ] Supabase projesi + 3 migration çalıştırıldı
- [ ] Render backend canlı, `/health` OK
- [ ] Landing nuveli.com.tr'de canlı + SSL
- [ ] api.nuveli.com.tr DNS bağlandı
- [ ] Flutter local'de çalışıyor

---

## Dosya Haritası

```
nuveli/
├── README.md                    Ana bilgilendirme
├── CLAUDE.md                    AI agent hafıza dosyası
├── QUICK_START.md               ← Bu dosya
├── .cursor/rules/               Cursor/Claude Code kuralları (5 dosya)
├── docs/                        Ürün, protokol, mimari belgeleri (15 dosya)
├── app/                         Flutter uygulaması
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart, app.dart
│       ├── core/                Theme, routing, config
│       ├── shared/widgets/      AppScaffold, PrimaryButton, vb.
│       └── features/            onboarding, meal, home, coach, premium, progress, settings
├── backend/                     FastAPI backend
│   ├── requirements.txt
│   ├── .env.example
│   ├── app/
│   │   ├── main.py
│   │   ├── core/                config, security, logging, dependencies
│   │   ├── api/routes/          tüm endpoint'ler
│   │   ├── services/            profile, meal, coach, home, premium, summary
│   │   ├── db/client.py
│   │   └── schemas/common.py
│   └── migrations/              3 SQL migration
├── landing/                     nuveli.com.tr için static siteyi
│   ├── index.html               Ana sayfa
│   ├── gizlilik.html
│   ├── sartlar.html
│   └── ...
└── deploy/
    ├── README.md                Tam deployment rehberi
    └── push-to-github.sh        GitHub push script
```

---

## Sorular?

Prompt paketinde belirli bir promptu (5.1 koç motoru, 6.2 aylık özet, 7.2 premium backend, vb.) tam implementasyonla ilerletmemi istersen söyle.
