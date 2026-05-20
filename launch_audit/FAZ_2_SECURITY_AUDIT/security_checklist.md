# 🛡️ FAZ 2.1 — OWASP Mobile Top 10 Checklist

**Tarih:** 2026-05-21
**Reference:** OWASP Mobile Top 10 (2024 edition)

---

## OWASP MASVS-VERIFIED Checklist

| # | Risk | Status | Detay |
|---|---|---|---|
| M1 | Improper Credential Usage | 🟡 PARTIAL | Apple SI good; Google SI yok; session refresh review gerekli |
| M2 | Insecure Storage | 🟢 OK | Supabase token Keychain/Keystore'da (flutter_secure_storage muhtemelen) — VERIFY |
| M3 | Insecure Communication | 🟡 PARTIAL | HTTPS default ✅, ATS/network_security_config explicit declaration eksik (M-1, M-2) |
| M4 | Insufficient Auth | 🟠 ATTENTION | Rate limiting yok (brute force koruması yok) — H-2 |
| M5 | Insufficient Cryptography | 🔴 BLOCKER | **python-jose 3.3.0 CVE-2024-33663 — JWS algorithm confusion** — C-1 |
| M6 | Insecure Auth | 🟡 PARTIAL | Session timeout policy belirsiz, JWT exp Supabase tarafında — verify |
| M7 | Client Code Quality | 🟢 OK | 0 empty catch, 0 print, exception sanitization var |
| M8 | Code Tampering | 🟡 LOW PRIORITY | Root/jailbreak detection YOK — v1.1+ |
| M9 | Reverse Engineering | 🟡 PARTIAL | Obfuscation aktif mi? — pubspec `--obfuscate` flag verify |
| M10 | Extraneous Functionality | 🟢 OK | Debug menü yok, `/docs` endpoint production'da kapatılmalı |

---

## M1: Improper Credential Usage — DETAYLI

### Apple Sign-In (✅ DOĞRU IMPLEMENT)
**Dosya:** `lib/features/auth/services/apple_signin_service.dart`
- ✅ Raw nonce generate
- ✅ SHA256 hash hashed nonce → Apple
- ✅ Supabase ID token bridge
- ✅ Platform check (iOS/macOS only)
- ✅ Replay attack koruması (nonce)

### Email/Password (Verify)
**Eksik kontroller:**
- [ ] Password complexity requirement (min 8 char, mixed, vs.) — Supabase Auth defaults?
- [ ] Email verification flow zorunlu mu?
- [ ] Password reset rate limit?

### Session Management
**Verify:**
- [ ] Refresh token rotation aktif mi? (Supabase config)
- [ ] Token expiration UI'da handle ediliyor mu? (graceful logout)
- [ ] "Remember me" durumunda nasıl çalışıyor?

---

## M2: Insecure Data Storage — DETAYLI

**Verify gerekli:**
- [ ] Supabase session token nerede saklanıyor?
  - iOS: Keychain (secure)
  - Android: EncryptedSharedPreferences (secure)
  - SharedPreferences plain text — INSECURE
- [ ] Sensitive UI state (premium status, user PII) cache'leniyor mu?
- [ ] Cache directory'de PII var mı?

**Tarama önerisi (post-launch):**
```bash
# iOS: Library/Caches içeriği temizliği
# Android: getApplicationContext().getCacheDir() review
```

---

## M3: Insecure Communication — DETAYLI

### HTTPS Enforcement
**Mevcut:**
- ✅ Backend API: `https://nuveli-api.onrender.com`
- ✅ Default HTTPS davranışı (iOS ATS default, Android API 28+ default)

**Eksik:**
- ❌ iOS `NSAppTransportSecurity` explicit declaration (M-2)
- ❌ Android `network_security_config.xml` (M-1)
- ❌ Certificate pinning YOK (orta-yüksek paranoya seviyesinde tavsiye, v1.1+ için)

---

## M4: Insufficient Authentication — DETAYLI

### Brute Force Koruması
**Mevcut:** Hiçbir rate limit yok.
**Senaryo:**
1. Saldırgan `/auth/v1/token?grant_type=password` endpoint'ine bir email + 1000 farklı password gönderir
2. Supabase rate limiti varsa: bloklanır. YOKSA: brute force başarılı olabilir.
**Mitigation:** Supabase dashboard'da auth rate limit config kontrol edilmeli.

### Account Lockout
- Şu an UI'da "yanlış password 3x sonra bekleme" YOK
- Supabase default rate limit: 5/minute? (versiyon-bağımlı, doğrulanmalı)

---

## M5: Insufficient Cryptography — 🔴 CRITICAL

### python-jose 3.3.0
**CVE-2024-33663 detayı:**
- Saldırgan, HS256 algoritmasıyla imzalanmış JWT'yi RS256'ymış gibi sunabilir
- Server, public key'i HMAC secret olarak kullanarak doğrular (yanlış!)
- Sonuç: **Saldırgan herhangi bir kullanıcı için geçerli JWT üretebilir**
- **Backend bu kütüphaneyi `core/security.py` üzerinden Supabase JWT doğrulamasında kullanıyor**

**Saldırı senaryosu:**
```
1. Saldırgan Supabase'in public key'ini alır (jwks endpoint)
2. JWT header'ı: {"alg": "HS256"}
3. JWT payload: {"sub": "victim_user_id", "exp": future}
4. Signature: HMAC-SHA256(public_key, payload) 
5. python-jose 3.3.0 bunu kabul edebilir → AUTH BYPASSED
```

**Fix:** `python-jose==3.5.0` veya `pyjwt==2.10+` (alternatif).

### TLS
- ✅ Production'da HTTPS only (Render üzerinde TLS 1.2+ varsayılan)
- ❓ TLS 1.0/1.1 reddediliyor mu? (Render config — varsayılan modern)

---

## M6: Insecure Authentication — DETAYLI

### JWT Expiration
**Verify:**
- [ ] Supabase JWT default `exp` ne kadar? (1 saat default)
- [ ] Frontend expired token handle ediyor mu? (Phase 4'te test)

### Session Fixation
**Verify:**
- [ ] Login öncesi session ID, login sonrası farklı mı?
- [ ] Logout sonrası backend'de token blacklist var mı? (Supabase default: no)

---

## M7: Client Code Quality — ✅ OK

| Kontrol | Sonuç |
|---|---|
| Empty catch | 0 |
| Print/log leak | 0 |
| Exception sanitization | ✅ |
| Input validation | 27 Pydantic Field |
| Type safety | Dart strict (null safety on) |

---

## M8: Code Tampering — LOW PRIORITY

**Mevcut:** Root/jailbreak detection YOK.
**Risk:** Düşük (wellness app, finansal app değil).
**Action:** v1.1+ için `flutter_jailbreak_detection` paketi entegre edilebilir.

---

## M9: Reverse Engineering

### Obfuscation
**Verify:**
```bash
# pubspec'te custom obfuscate build script var mı?
# Build komutu: flutter build apk --release --obfuscate --split-debug-info=...
```

**Action:**
- [ ] CI/CD build script'inde `--obfuscate` flag eklenmiş mi?
- [ ] Symbol dosyaları (debug-info) güvenli yerde saklanıyor mu?

---

## M10: Extraneous Functionality — ✅ OK

### Debug Menüler
- Settings'de "Developer Mode" yok
- Debug build çıktısı production'da yok (release build)

### API Docs
- `/docs` (FastAPI Swagger) endpoint **production'da AÇIK mi?**
```python
# main.py
app = FastAPI(
    ...,
    docs_url="/docs",       # 🟡 PROD'da kapat
    redoc_url="/redoc",     # 🟡 PROD'da kapat
)
```

**Risk:** API surface enumeration kolaylaşır.
**Fix:**
```python
docs_url="/docs" if not settings.is_production else None,
redoc_url=None,
```

**Severity:** Medium (security through obscurity, ama defense in depth).

---

## 📊 OWASP Genel Skor: 58/100

- 1 BLOCKER (M5) — `-30 puan`
- 2 ATTENTION (M3, M4) — `-12 puan`

Sonra ki fazlarda kontrol edilecek:
- M2 (data storage at rest)
- M6 (session timeout)
- M9 (obfuscation build)
