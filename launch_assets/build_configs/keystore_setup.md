# 🔑 Keystore Setup — Critical (Android Production)

**Hedef:** Android imzalama anahtarı oluşturma, yedekleme ve kullanma rehberi.

⚠️ **Bu dosyayı KAYBETMEK = Play Store'da app'i güncelleyememek.**
⚠️ **Şifreyi KAYBETMEK = Aynı sonuç.**

---

## 📋 Önemli Notlar

### Keystore Nedir?
- Android'in app imzalama mekanizması
- Her app benzersiz bir keystore ile imzalanır
- Play Store yeni APK/AAB upload'ında bu imzayı kontrol eder
- İmza uyuşmazsa → upload reddedilir

### Neden Bu Kadar Kritik?
Play Store policy:
> "Once an app is signed with a key, all future versions must be signed with the same key."

Yani:
- Keystore kayıp → app güncelleyemezsin
- Yeni keystore ile yeni app upload edersen → kullanıcılar **yeni app olarak görür**, eski install'lar update almaz, rating sıfırlanır

### Google Play App Signing
Google **2018'den beri** Google Play App Signing özelliği sunuyor:
- Sen bir **upload key** oluşturuyorsun
- Google senin için ayrı bir **app signing key** üretiyor ve saklıyor
- Upload key kaybolursa → Google'a reset talep edebilirsin

**Bizim stratejimiz:** Google Play App Signing'i kullan → ekstra güvenlik katmanı.

---

## 🛠️ Adım 1: Keystore Oluştur

```bash
# Klasör oluştur (kalıcı, ev dizininde)
mkdir -p ~/keys

# Keystore üret
keytool -genkey -v \
  -keystore ~/keys/nuveli-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias nuveli-release \
  -dname "CN=Ali Mirbagirzade, OU=Nuveli, O=Nuveli, L=Istanbul, S=Istanbul, C=TR"
```

**Parametre açıklamaları:**
| Parametre | Anlamı |
|---|---|
| `-keystore` | Output path |
| `-keyalg RSA` | Algoritma (RSA standart) |
| `-keysize 2048` | Key size (2048 modern standart) |
| `-validity 10000` | Geçerlilik gün cinsinden (27 yıl) |
| `-alias` | Key adı (Play Console'da görünür) |
| `-dname` | Distinguished name (X.500 format) |

### Interaktif soru (manuel)
Eğer `-dname` parametresini geçmek istersen:
```bash
keytool -genkey -v \
  -keystore ~/keys/nuveli-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias nuveli-release
```

Sorular:
```
Enter keystore password: [12+ karakter, uppercase + lowercase + sayı + sembol]
Re-enter new password: [aynısı]
What is your first and last name? [Ali Mirbagirzade]
What is the name of your organizational unit? [Nuveli]
What is the name of your organization? [Nuveli]
What is the name of your City or Locality? [Istanbul]
What is the name of your State or Province? [Istanbul]
What is the two-letter country code for this unit? [TR]
Is CN=..., correct? [yes]

Enter key password for <nuveli-release>: [keystore ile aynı olabilir veya farklı, RECOMMEND: aynı]
Re-enter new password: [aynısı]
```

**Çıktı:** `~/keys/nuveli-release.jks` dosyası oluşur (~2 KB).

---

## 🔐 Adım 2: Şifreleri Sakla

### 1Password / Bitwarden Yapısı

```
Folder: Nuveli Production
└── Android Keystore
    ├── Title: Nuveli Release Keystore
    ├── Username: nuveli-release (alias)
    ├── Password: <STORE_PASSWORD>
    ├── Notes:
    │   ├── Key Password: <KEY_PASSWORD>
    │   ├── File path (your Mac): /Users/ali/keys/nuveli-release.jks
    │   ├── Created: 2026-05-18
    │   ├── Validity: 10000 days (until 2053)
    │   ├── SHA-1: 14:6D:E9:... (line below)
    │   └── SHA-256: 92:AB:CD:... (after generating)
    └── Attachment: nuveli-release.jks (binary file)
```

### Şifre Önerileri
- **Minimum 16 karakter**
- **Mixed case + numbers + symbols**
- **Sözlük kelimesi olmamalı**
- Örnek (kullanma!): `K3yst0r3#Nuvel1$2026Pr0d`

⚠️ Bu şifreleri **asla** Slack/Email/WhatsApp/Discord'da paylaşma.

---

## 💾 Adım 3: Yedekleme (3-2-1 Stratejisi)

**3 kopya** + **2 farklı medya** + **1 offsite**.

### Kopya 1: 1Password / Bitwarden (Primary)
- Vault attachment olarak `nuveli-release.jks`
- Şifreler aynı item'da

### Kopya 2: Encrypted iCloud / Google Drive
```bash
# macOS: ZIP içinde şifrele
zip -e nuveli-keystore-backup.zip \
  ~/keys/nuveli-release.jks \
  ~/Documents/nuveli-keystore-passwords.txt

# Sonra iCloud Drive veya Google Drive'a yükle
mv nuveli-keystore-backup.zip ~/Library/Mobile\ Documents/com~apple~CloudDocs/Backups/
```

ZIP şifresi de 1Password'da saklı olmalı.

### Kopya 3: Physical USB Stick (Offline)
- Encrypted USB drive (FileVault veya VeraCrypt)
- Şifreli ZIP içinde keystore + passwords
- USB stick'i güvenli bir yerde sakla (ev kasası, kiralık kasa, vb.)

### NEREDE OLMAMALI
- ❌ Git repo
- ❌ Plain text dosya local disk'te
- ❌ Email
- ❌ Slack/Discord
- ❌ Unencrypted USB drive
- ❌ Public cloud (Dropbox unencrypted)

---

## 🔑 Adım 4: keystore.properties Oluştur

`android/keystore.properties` (PROJECT_ROOT/android/ klasörü içinde):

```properties
storePassword=YOUR_STORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=nuveli-release
storeFile=/Users/YOUR_USERNAME/keys/nuveli-release.jks
```

⚠️ **Bu dosya .gitignore'da olmalı.** (Aşağıda `.gitignore` bölümüne bakacağız)

---

## 🔍 Adım 5: SHA-1 ve SHA-256 Fingerprint Al

Play Console + Firebase için gerekli.

```bash
keytool -list -v \
  -keystore ~/keys/nuveli-release.jks \
  -alias nuveli-release

# Şifreyi sorar → store password gir
```

Çıktıda:
```
Certificate fingerprints:
  SHA1: 14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:1A:2B:3C:4D
  SHA256: 92:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:...
```

Bu değerleri:
1. **Google Play Console** → Setup → App integrity → SHA fingerprints
2. **Firebase Console** → Project Settings → Your apps → Android app → Add fingerprint
3. **1Password notes** (referans için)

---

## 🏗️ Adım 6: Build Test

```bash
cd ~/Development/nuveli/app
flutter clean
flutter pub get
flutter build appbundle --release \
  --build-name=1.0.0 \
  --build-number=1
```

**Başarılı çıktı:**
```
✓ Built build/app/outputs/bundle/release/app-release.aab (35.2MB)
```

Eğer şu hata gelirse:
```
Failed to read key from store: Keystore was tampered with, or password was incorrect
```
→ keystore.properties şifresi yanlış. Kontrol et.

```
Failed to read key from store: File not found
```
→ storeFile path'i yanlış. Mac kullanıcı adın doğru mu?

---

## 🚨 Adım 7: Google Play App Signing'i Aktif Et (ÖNERİLEN)

İlk upload sırasında Play Console "Use Play App Signing" seçeneği gösterir.

### Süreç
1. Upload AAB → Play Console
2. Play Console: "Let Google manage your app signing key" → **Yes**
3. Google senin AAB'ini bir kez imzalar (upload key ile gelir)
4. Google ayrıca **app signing key** üretir ve saklar
5. Her upload'da:
   - Sen upload key ile imzalarsın → AAB'yi Google'a yollarsın
   - Google upload key'i doğrular → kendi app signing key'iyle re-sign eder
   - Re-signed AAB'yi Play Store'a koyar

### Avantajları
- ✅ Upload key kaybolursa → Google'dan reset talep edebilirsin
- ✅ Daha güvenli (Google tarafında HSM ile korunur)
- ✅ Future-proof (Google'ın policy değişikliklerine uyumlu)

### Dezavantajları
- ❌ Bir kez aktif edersen geri dönemezsin
- ❌ Apple App Store'a uploadlar etkilenmez (her platform bağımsız)

**Karar:** Bizim için Play App Signing **şiddetle önerilir**.

---

## 🔄 Disaster Recovery

### Senaryo 1: Keystore.jks kaybı (dosya silindi)
✅ **Çözüm:** Yedeklerden geri yükle (1Password attachment veya USB).

### Senaryo 2: Şifreler kaybı (1Password silindi)
✅ **Çözüm:**
- 1Password recovery code ile aç
- 1Password Family / Business hesabında "Family Organizer" reset yapabilir
- Bitwarden'da emergency contact aktifse oradan recovery

### Senaryo 3: Keystore + Şifre TÜM yedekler kaybı
⚠️ **Çözüm (Google Play App Signing aktifse):**
- Play Console → App integrity → "Upload key reset"
- Google bir form gönderir, kimlik doğrulama yapar
- 1-2 hafta içinde yeni upload key yetkilendirir
- App signing key (Google'da) hala aktif, app crash etmez

⚠️ **Çözüm (Play App Signing DEĞİLSE):**
- 💀 **App güncellenemez.**
- Yeni keystore ile yeni package name'le yeni app yayınlamak zorunda kalırsın
- Kullanıcı tabanı sıfırdan başlar

### Senaryo 4: Şifreler kaybı ama .jks dosyası var
```bash
# Brute force tools (sadece kendi keystore'un için)
# AndroidKeystoreBrute (GitHub) — basit şifreler için
# Çoğunlukla 16+ karakter şifrede başarısız
```
⚠️ **Bu yöntem güvenilir değil**. Yedekleme her şey.

---

## 📋 Adım 8: .gitignore Güncelle

`.gitignore` dosyasına ekle (project root'ta):

```
# ═══════════════════════════════════════════════
# ANDROID — KEYSTORE & SECRETS
# ═══════════════════════════════════════════════
android/keystore.properties
android/app/*.jks
android/app/*.keystore
**/*.jks
**/*.keystore

# ═══════════════════════════════════════════════
# IOS — PROVISIONING & CERTIFICATES
# ═══════════════════════════════════════════════
ios/Runner/GoogleService-Info.plist  # ⚠️ Firebase config (örnek olarak istersek koyabilirsin ama secrets içerir)
ios/*.mobileprovision
ios/*.p12

# ═══════════════════════════════════════════════
# ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════
.env
.env.local
.env.development
.env.staging
.env.production
**/.env*

# ═══════════════════════════════════════════════
# FIREBASE
# ═══════════════════════════════════════════════
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
# Eğer firebase config'leri commit etmek istemiyorsan
# Çoğu proje commit eder (Apple/Google ID'ler public'dir)
# Ama service account JSON'ları ASLA commit etme

# ═══════════════════════════════════════════════
# FLUTTER
# ═══════════════════════════════════════════════
**/build/
**/.dart_tool/
**/.flutter-plugins
**/.flutter-plugins-dependencies
**/.packages
**/.pub-cache/
**/.pub/

# ═══════════════════════════════════════════════
# IDE
# ═══════════════════════════════════════════════
.idea/
.vscode/
*.iml
*.iws
*.ipr

# ═══════════════════════════════════════════════
# OS
# ═══════════════════════════════════════════════
.DS_Store
Thumbs.db
```

---

## ✅ Final Checklist

- [ ] Keystore oluşturuldu (`~/keys/nuveli-release.jks`)
- [ ] Store password ve key password 1Password'da kayıtlı
- [ ] Keystore dosyası **3 farklı yere** yedeklendi
- [ ] SHA-1 ve SHA-256 fingerprint alındı
- [ ] Play Console'a SHA-1 girildi
- [ ] Firebase Console'a SHA-1 girildi
- [ ] `android/keystore.properties` oluşturuldu
- [ ] `.gitignore` güncellendi
- [ ] `flutter build appbundle --release` hatasız çalıştı
- [ ] Google Play App Signing aktif edildi (ilk upload'da)
- [ ] Test AAB Play Console'a yüklendi (Internal Testing)

---

**Önemli son not:** Keystore yönetimi **bir kez doğru kurulursa hayat boyu sorun çıkarmaz**. İlk gün titiz ol, yedekle, sonraki 10 yıl rahatlık.
