# Android Build Config — Production

**Hedefler:** 
- `android/app/src/main/AndroidManifest.xml` (permissions)
- `android/app/build.gradle.kts` (signing, version, build types)

---

## 📄 AndroidManifest.xml

`android/app/src/main/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- PERMISSIONS                                              -->
    <!-- ═══════════════════════════════════════════════════════ -->
    
    <!-- Network (zorunlu — backend API çağrıları) -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Camera (meal scan) -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    
    <!-- Photo / Storage (Android 13+ scoped permissions) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <!-- Eski Android için (API < 33) -->
    <uses-permission 
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- Notifications (Android 13+ zorunlu) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Scheduled notifications (water reminders, vb.) -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    
    <!-- Boot completed (reminders'ı reboot sonrası restore et) -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <!-- Vibration (notification feedback) -->
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <!-- Wake lock (background sync için) -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Google Fit / Health Connect (Premium) -->
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    <uses-permission android:name="android.permission.health.READ_STEPS" />
    <uses-permission android:name="android.permission.health.READ_WEIGHT" />
    <uses-permission android:name="android.permission.health.WRITE_WEIGHT" />
    
    <!-- In-App Purchase (Google Play Billing) -->
    <uses-permission android:name="com.android.vending.BILLING" />
    
    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- HARDWARE FEATURES (optional)                             -->
    <!-- ═══════════════════════════════════════════════════════ -->
    
    <uses-feature
        android:name="android.hardware.camera.autofocus"
        android:required="false" />
    
    <uses-feature
        android:name="android.hardware.camera.flash"
        android:required="false" />
    
    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- APPLICATION                                              -->
    <!-- ═══════════════════════════════════════════════════════ -->
    
    <application
        android:label="Nuveli"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:requestLegacyExternalStorage="false"
        android:usesCleartextTraffic="false"
        android:networkSecurityConfig="@xml/network_security_config"
        android:enableOnBackInvokedCallback="true"
        android:hardwareAccelerated="true">
        
        <!-- Main Flutter Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
            
            <!-- Deeplink: nuveli://... -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="nuveli" />
            </intent-filter>
            
            <!-- Universal links: https://nuveli.app/... -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https"
                      android:host="nuveli.app" />
            </intent-filter>
        </activity>
        
        <!-- Flutter Embedding -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
        
        <!-- Firebase Messaging -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_notification" />
        
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
        
        <!-- Firebase Analytics -->
        <meta-data
            android:name="firebase_analytics_collection_enabled"
            android:value="true" />
        
        <!-- Boot Receiver (notifications restore) -->
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>
    </application>
    
    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- QUERIES (Android 11+ package visibility)                  -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <queries>
        <!-- launchUrl için diğer app'leri görebilmek -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        
        <!-- Email app'i görmek -->
        <intent>
            <action android:name="android.intent.action.SENDTO" />
            <data android:scheme="mailto" />
        </intent>
    </queries>
</manifest>
```

---

## 📄 Network Security Config

`android/app/src/main/res/xml/network_security_config.xml` oluştur:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

Bu Android'in eşdeğeri iOS'un ATS'i. **Tüm trafik HTTPS** olmalı.

---

## 📄 build.gradle.kts (App Level)

`android/app/build.gradle.kts`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Firebase
    id("com.google.firebase.crashlytics")  // Crashlytics
}

// ═══════════════════════════════════════════════════════════════
// KEYSTORE
// ═══════════════════════════════════════════════════════════════
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nuveli.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }
    
    defaultConfig {
        applicationId = "com.nuveli.app"
        minSdk = 23      // Android 6.0+ (sign_in_with_apple gerektirir)
        targetSdk = 34   // Android 14 (Play Store 2024 zorunlu)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Multidex (büyük app için)
        multiDexEnabled = true
        
        // Test
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    
    // ═════════════════════════════════════════════════════════════
    // SIGNING CONFIGS
    // ═════════════════════════════════════════════════════════════
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    // ═════════════════════════════════════════════════════════════
    // BUILD TYPES
    // ═════════════════════════════════════════════════════════════
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            
            // Code shrinking + optimization
            isMinifyEnabled = true
            isShrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Application label
            resValue("string", "app_name", "Nuveli")
        }
        
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            resValue("string", "app_name", "Nuveli Debug")
            
            isMinifyEnabled = false
            isDebuggable = true
        }
    }
    
    // ═════════════════════════════════════════════════════════════
    // BUNDLE (App Bundle config)
    // ═════════════════════════════════════════════════════════════
    bundle {
        language { enableSplit = true }
        density { enableSplit = true }
        abi { enableSplit = true }
    }
    
    // ═════════════════════════════════════════════════════════════
    // PACKAGING (duplicate file çakışmaları)
    // ═════════════════════════════════════════════════════════════
    packaging {
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

---

## 📄 keystore.properties (TEMPLATE)

⚠️ **Bu dosya `.gitignore`'da olmalı. ASLA commit etme.**

`android/keystore.properties` oluştur (PROJECT ROOT'TA değil, ANDROID klasörü içinde):

```properties
storePassword=YOUR_STORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=nuveli-release
storeFile=/Users/YOUR_USERNAME/keys/nuveli-release.jks
```

---

## 🔑 Keystore Oluşturma

```bash
# Mac/Linux
keytool -genkey -v \
  -keystore ~/keys/nuveli-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias nuveli-release \
  -dname "CN=Ali Mirbagirzade, OU=Nuveli, O=Nuveli, L=Istanbul, S=Istanbul, C=TR"

# Ne soracak:
# 1. Keystore password (uzun + kompleks)
# 2. Key password (aynı olabilir veya farklı)
# 3. First and last name → onaydan geçtin
```

**Çıktı:**
- Dosya: `~/keys/nuveli-release.jks`
- Geçerlilik: ~27 yıl (10000 gün)

### ⚠️ ÇOK ÖNEMLİ — Keystore Yedekleme

Keystore dosyasını **kaybedersen** Play Store'da app'i güncelleyemezsin. Bu felakettir.

**Yedekle:**
1. **1Password / Bitwarden** — keystore.jks + tüm şifreler
2. **iCloud Drive** (encrypted)
3. **Google Drive** (encrypted)
4. **USB stick** (offline backup)

**Şifreleri sakla:**
```
Folder: Nuveli Production → Android Keystore
├── keystore.jks (file attachment)
├── Store Password: ...
├── Key Password: ...
├── Key Alias: nuveli-release
└── SHA-1 fingerprint: (Play Console'a vermek için)
```

### SHA-1 Fingerprint Alma

Play Console'a verilecek:

```bash
keytool -list -v \
  -keystore ~/keys/nuveli-release.jks \
  -alias nuveli-release

# Çıktıda "SHA1:" satırını kopyala
# Örnek: SHA1: 14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:...
```

Bu fingerprint:
- Play Console → Setup → App Integrity → SHA fingerprints
- Firebase Console → Project Settings → Your apps → Android → SHA-1

---

## 🚨 Google Play 2024+ Zorunlulukları

| Kural | Bizim Durum |
|---|---|
| `targetSdk = 34` (Android 14) | ✅ Yukarıda set |
| App Bundle (AAB) zorunlu (APK değil) | ✅ `flutter build appbundle` |
| Data Safety form doldurulmuş | ⏳ Submission'da yapılacak |
| Account deletion in-app | ✅ Apple ile aynı |
| Privacy policy URL | ✅ nuveli.app/privacy |
| Notification permission (API 33+) | ✅ POST_NOTIFICATIONS manifest'te |
| 64-bit support | ✅ Flutter default |
| Permissions justified | ✅ Privacy Policy + Permission rationale UI |

---

## ✅ Submission Checklist

- [ ] AndroidManifest.xml tüm permission'lar ekli
- [ ] `targetSdk = 34`, `minSdk = 23`
- [ ] `applicationId = "com.nuveli.app"`
- [ ] Keystore oluşturuldu ve yedeklendi (3 yer)
- [ ] keystore.properties .gitignore'da
- [ ] SHA-1 fingerprint alındı
- [ ] Play Console + Firebase'e SHA-1 girildi
- [ ] Network security config (HTTPS-only)
- [ ] Multidex enabled
- [ ] Proguard rules (release shrinking)
- [ ] Bundle splits (dil/density/ABI)
- [ ] `flutter build appbundle` hatasız çalışıyor
- [ ] AAB boyutu < 200 MB

---

## 🚨 Google Play Reject Sebepleri (Build Spesifik)

| Hata | Çözüm |
|---|---|
| targetSdk eski | 34'e güncelle |
| APK upload | AAB kullan (`flutter build appbundle`) |
| Permission justification yok | Privacy Policy detaylandır, in-app rationale UI ekle |
| 64-bit support yok | Flutter default ✅ |
| Health permissions yetkisiz kullanım | Data Safety form'da declare et + permission rationale göster |
