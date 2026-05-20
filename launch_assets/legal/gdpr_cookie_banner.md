# 🍪 GDPR Cookie Banner & Consent

**Hedef:** `nuveli.app` web sitesi için GDPR/ePrivacy uyumlu cookie banner.

**Not:** Mobile app **cookie kullanmıyor** → mobile için cookie banner gerekmiyor. Bu doküman sadece web sitesi için.

---

## 🌐 Web Site Yapısı

`nuveli.app` üzerinde:
- Landing page (marketing)
- Privacy Policy (`/privacy`)
- Terms of Service (`/terms`)
- Support (`/support`)
- Cookies (`/cookies`)

---

## 🍪 Hangi Cookie'ler Kullanılıyor?

### Kategori 1: Strictly Necessary (Consent gerektirmez)
| Cookie | Amaç | Süre |
|---|---|---|
| `session_id` | CSRF protection | Session |
| `cookie_consent` | Banner tercihini hatırla | 1 yıl |

### Kategori 2: Analytics (Consent gerekir)
| Cookie | Provider | Amaç | Süre |
|---|---|---|---|
| `_ga` | Google Analytics 4 | Visitor identification | 2 yıl |
| `_ga_*` | Google Analytics 4 | Session tracking | 2 yıl |

### Kategori 3: Marketing (Consent gerekir)
**Şu an kullanılmıyor.** İleride Facebook Pixel veya Google Ads eklersek bu kategoriye girer.

---

## 🎨 Banner UI Tasarımı

```
┌────────────────────────────────────────────────┐
│                                                │
│  🍪 We use cookies                            │
│                                                │
│  We use essential cookies to make our site     │
│  work. We'd also like to use analytics         │
│  cookies to understand how you use our site.   │
│                                                │
│  See our [Cookie Policy] for details.          │
│                                                │
│  ┌─────────────┐  ┌──────────────┐            │
│  │  Reject All │  │  Accept All  │            │
│  └─────────────┘  └──────────────┘            │
│                                                │
│  [Manage preferences]                          │
│                                                │
└────────────────────────────────────────────────┘
```

### Önemli UX Kuralları (GDPR)
- ✅ **"Reject All"** ve **"Accept All"** **eşit görsel ağırlıkta** olmalı (aynı boyut, aynı belirginlik)
- ❌ **"Accept All"** vurgulu, **"Reject"** soluk renkli olamaz (dark pattern)
- ✅ Tracking cookie'leri **kullanıcı consent vermeden YÜKLENMEMELİ**
- ✅ Banner kapanmadan tracking yok
- ✅ Tercih değiştirme imkânı (footer'da "Cookie Settings" linki)

---

## 💻 Implementation (Vercel/Next.js örneği)

### Seçenek 1: Cookiebot (Önerilen, hazır çözüm)

**Maliyet:** $9-39/ay
**URL:** https://www.cookiebot.com/

**Avantajları:**
- GDPR + CCPA + LGPD uyumlu
- Otomatik cookie scanner
- 47 dil desteği
- IAB TCF v2.2 uyumlu

**Kurulum:**
```html
<!-- Site head'ine ekle -->
<script id="Cookiebot" 
        src="https://consent.cookiebot.com/uc.js" 
        data-cbid="YOUR_DOMAIN_GROUP_ID"
        data-blockingmode="auto"
        type="text/javascript">
</script>
```

### Seçenek 2: Manuel Implementation (ücretsiz)

```typescript
// app/components/CookieBanner.tsx
'use client';

import { useState, useEffect } from 'react';

export default function CookieBanner() {
  const [showBanner, setShowBanner] = useState(false);

  useEffect(() => {
    const consent = localStorage.getItem('cookie_consent');
    if (!consent) {
      setShowBanner(true);
    } else if (consent === 'accepted') {
      loadAnalytics();
    }
  }, []);

  const acceptAll = () => {
    localStorage.setItem('cookie_consent', 'accepted');
    setShowBanner(false);
    loadAnalytics();
  };

  const rejectAll = () => {
    localStorage.setItem('cookie_consent', 'rejected');
    setShowBanner(false);
    // Analytics yüklenmez
  };

  const loadAnalytics = () => {
    // Google Analytics dynamic load
    const script = document.createElement('script');
    script.src = `https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX`;
    script.async = true;
    document.head.appendChild(script);
    
    window.dataLayer = window.dataLayer || [];
    function gtag(...args: any[]) { window.dataLayer.push(args); }
    gtag('js', new Date());
    gtag('config', 'G-XXXXXXXXXX');
  };

  if (!showBanner) return null;

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-slate-900 text-white p-6 shadow-2xl z-50">
      <div className="max-w-4xl mx-auto">
        <h3 className="text-lg font-bold mb-2">🍪 We use cookies</h3>
        <p className="text-sm mb-4">
          We use essential cookies to make our site work. We'd also like to use 
          analytics cookies to understand how you use our site. 
          See our <a href="/cookies" className="underline">Cookie Policy</a> for details.
        </p>
        <div className="flex gap-3 flex-wrap">
          <button 
            onClick={rejectAll}
            className="px-6 py-2 border border-white rounded hover:bg-white/10"
          >
            Reject All
          </button>
          <button 
            onClick={acceptAll}
            className="px-6 py-2 bg-cyan-500 text-slate-900 rounded font-semibold hover:bg-cyan-400"
          >
            Accept All
          </button>
          <a 
            href="/cookies"
            className="px-6 py-2 underline text-sm self-center"
          >
            Manage preferences →
          </a>
        </div>
      </div>
    </div>
  );
}
```

---

## 📄 Cookie Policy Sayfası

`nuveli.app/cookies` URL'inde host edilecek metin:

```markdown
# Cookie Policy

**Last Updated:** May 18, 2026

This page explains how Nuveli uses cookies on our website (nuveli.app). 
For our mobile app's privacy practices, see our [Privacy Policy](/privacy).

## What are cookies?

Cookies are small text files stored on your device when you visit a website. 
They help websites remember your preferences and improve your experience.

## Cookies We Use

### Strictly Necessary (no consent required)
- `session_id` — CSRF protection (session)
- `cookie_consent` — Remembers your cookie preferences (1 year)

### Analytics (consent required)
- `_ga`, `_ga_*` — Google Analytics 4. Helps us understand how visitors 
  use our site. **Data is anonymized.**

### Marketing
We do not currently use marketing cookies. If we add them, we will update 
this policy and ask for your consent.

## Your Choices

You can:
- **Accept all cookies** — full analytics
- **Reject all cookies** — only essential cookies
- **Manage preferences** — choose by category

To change your preferences, click "Cookie Settings" in the footer or clear 
your browser's site data and reload.

## Third-Party Cookies

We use Google Analytics. See [Google's Privacy Policy](https://policies.google.com/privacy).

## Contact

Questions about cookies? Email privacy@nuveli.app.
```

---

## 🚨 GDPR Compliance Checklist

- [ ] Banner görünür yerleştirildi (bottom veya overlay)
- [ ] "Accept" ve "Reject" eşit ağırlıkta
- [ ] Tracking cookies banner kapanmadan YÜKLENMİYOR
- [ ] Granular control (manage preferences) var
- [ ] Cookie Policy sayfası canlı
- [ ] Footer'da "Cookie Settings" linki var (tercihi değiştirme)
- [ ] Üçüncü taraf cookie'ler dökümante edildi
- [ ] User region detection (EU dışı kullanıcılar için banner gizlenebilir, ama Türkiye'de KVKK gereği zorunlu)
- [ ] DSAR (Data Subject Access Request) endpoint'i var (privacy@nuveli.app)

---

## 🌍 ePrivacy + CCPA + KVKK Farkları

| Bölge | Kural | Bizim Uyumumuz |
|---|---|---|
| **EU (GDPR/ePrivacy)** | Tracking için aktif rıza zorunlu, dark pattern yasak | ✅ Cookiebot veya manuel banner |
| **California (CCPA)** | "Do Not Sell" linki + opt-out | ✅ "We do not sell" (Privacy Policy'de var) |
| **Türkiye (KVKK)** | Açık rıza, aydınlatma yükümlülüğü | ✅ Aynı banner yeterli |
| **Brezilya (LGPD)** | GDPR'a benzer | ✅ Aynı banner yeterli |

---

## ✅ Final Submission Checklist

- [ ] Banner deploy edildi (Cookiebot veya manuel)
- [ ] Cookie Policy sayfası canlı (`nuveli.app/cookies`)
- [ ] Privacy Policy'de cookie referansı eklendi (Section 12)
- [ ] Google Analytics dynamic load (consent sonrası)
- [ ] Test edildi: Reject → no `_ga` cookie var
- [ ] Test edildi: Accept → `_ga` cookie eklendi
- [ ] Footer'da "Cookie Settings" linki
- [ ] 14 günde bir cookie scanner çalışıyor (Cookiebot otomatik yapar)

---

**Önemli:** Mobile app **cookie kullanmıyor**. App Store'a submission'da bu konuda soru gelmez. Web sitesi ayrı tutulmalı.
