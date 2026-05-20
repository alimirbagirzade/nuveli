# 🐛 Nuveli — Chat 24 Hazırlık Paketi: Bug Hunt & Pre-Launch Polish

**Bu chat'in adı:** `Nuveli - Chat 24: Bug Hunt & Pre-Launch Polish`
**Hedef:** Launch'tan önce **son rötuş**. Edge case'leri kapla, hata mesajlarını insanlaştır, performans iyileştir, accessibility ekle.
**Önkoşul:** Chat 21-23 tamamlanmış. App + testler çalışıyor.
**Tahmini süre:** 1-2 chat (uzun ama parçalı — istediğin parçayı yap)

---

## 🎯 BU CHAT'TE NE YAPACAĞIZ

Bu chat **2 farklı bakış açısı** ile gidiyor:

### 🐛 Bug Hunt (Defense)
"App'i KIRMAYA çalış" — kötü kullanıcı simülasyonu:
- Network kapalıyken işlemler
- Hızlı tap'leme (double submit)
- Çok uzun input'lar (10000 karakter)
- Çok düşük/yüksek değerler
- Permission red etme
- Pil %1 durumu
- Eski cihaz / küçük ekran

### ✨ Polish (Offense)
"App'i SEVDİRMEYE çalış" — premium hissiyat:
- Loading skeleton'ları
- Smooth animasyonlar
- Sound effects (opsiyonel)
- Haptic feedback
- Empty state'ler
- Error mesajları → friendly
- Onboarding tooltip'ler
- Confetti / celebration moments

---

## 🐛 BUG HUNT KATEGORİLERİ

### Kategori 1: NETWORK & OFFLINE

```
SENARYO: Kullanıcı uçak modunda, app'i açıyor
BEKLENEN: Friendly offline screen, "Connect to internet" CTA
GERÇEK: ? (test edilecek)
```

**Test edilecek noktalar:**
- [ ] App açılışta offline → graceful handle
- [ ] Login attempt offline → "Check internet" mesajı (crash yok)
- [ ] Dashboard offline → cached data + "Offline" banner
- [ ] Meal scan offline → "Save locally, sync later" (opsiyonel) veya "Need internet for AI"
- [ ] Premium purchase offline → "Need internet" + retry
- [ ] Internet GİT-GEL → connection restored snackbar

**Çözüm pattern'leri:**
```dart
// Connectivity check
final connectivity = await Connectivity().checkConnectivity();
if (connectivity == ConnectivityResult.none) {
  return _showOfflineDialog();
}

// Network listener (global)
Connectivity().onConnectivityChanged.listen((result) {
  if (result == ConnectivityResult.none) {
    ref.read(globalNotifierProvider.notifier).showOffline();
  }
});
```

---

### Kategori 2: PERMISSION RED ETME

**Test edilecek:**
- [ ] Camera permission denied → "Open Settings" CTA
- [ ] Photos permission denied → meal scan disabled
- [ ] Notifications permission denied → settings'te uyarı, schedule etmek bloke
- [ ] Apple Health permission denied → premium feature açıklamayla soft fail

**Pattern:**
```dart
final status = await Permission.camera.request();
if (status.isDenied) {
  // Show explainer
  await showDialog(...);
} else if (status.isPermanentlyDenied) {
  // Settings'e yönlendir
  await openAppSettings();
}
```

---

### Kategori 3: EDGE CASES (Veri)

**Test edilecek:**
- [ ] 0 kalori meal log (mümkün mü, hesaplamalar bozulur mu)
- [ ] 50000 kalori meal log (saçma değer)
- [ ] Boyut 50 kg, kilo 20 kg (mantıksız BMR)
- [ ] Tarih girişi 1850 (geçmiş yıl)
- [ ] Tarih girişi 2100 (gelecek yıl)
- [ ] Profile name 100 karakter
- [ ] Profile name emoji + Arapça karakterler
- [ ] Water 10000 ml/gün (overflow)
- [ ] 0 habit, 0 meal → analytics ekranı bozulur mu
- [ ] İlk gün → "7 day average" ne göstermeli (1 gün?)

---

### Kategori 4: UI BREAKING POINTS

**Cihazlar:**
- [ ] iPhone SE (küçük ekran 375x667) — text overflow var mı
- [ ] iPad Pro (tablet) — layout dağılıyor mu
- [ ] Çok küçük Android (kelime gelmeyebilir)
- [ ] Çok büyük font (accessibility) — UI bozulur mu
- [ ] RTL language (Arapça test) — layout mirror oluyor mu
- [ ] Landscape mode (yatay) — engelliyor muyuz, izin mi veriyoruz

**Test komutu:**
```bash
# iPhone SE simulator
flutter run -d "iPhone SE (3rd generation)"

# iPad
flutter run -d "iPad Pro (12.9-inch)"
```

---

### Kategori 5: STATE EDGE CASES

- [ ] Login → app kapat → tekrar aç → hala logged in mi (persistent session)
- [ ] Login → 30 dk bekle → API çağrı → token refresh otomatik mi
- [ ] Onboarding ortasında app kill → tekrar açınca kaldığı yer mi
- [ ] Meal eklerken app kill → veri kaybı oluyor mu
- [ ] Premium satın al → app kill → tekrar aç → hala premium mi
- [ ] 2 cihazdan aynı user → biri logout → diğeri etkilenir mi
- [ ] Token tampere edildi → 401 alır mı, graceful logout mu

---

### Kategori 6: PERFORMANCE

```bash
# Performance overlay açık
flutter run --profile

# Memory snapshot
flutter run --observatory-port=8888
# Sonra: dart devtools
```

**Hedefler:**
- [ ] App başlangıç < 3s (cold start)
- [ ] Tab switch < 200ms
- [ ] Meal scan (AI) < 5s
- [ ] Dashboard refresh < 2s
- [ ] FPS 60 (jank yok, scroll smooth)
- [ ] Memory < 200 MB (gerçek cihazda)
- [ ] Battery drain normal (30 dk kullanım <%5)

**Yaygın performans sorunları:**
- Image cache yok → her açılışta network'ten yükler
- `setState` çok geniş scope (bütün ekran rebuild)
- ListView yerine Column + ScrollView (big list'lerde)
- Provider invalidate çok sık
- Computation main thread'de (`compute()` kullan)

---

## ✨ POLISH KATEGORİLERİ

### Polish 1: Loading States

Her async UI için **3 state** olsun:

```dart
state.when(
  loading: () => _SkeletonView(),    // Ghost UI
  error: (e, _) => _ErrorView(...),  // Friendly error
  data: (d) => _ContentView(d),      // Asıl içerik
);
```

**Yaygın yerler:**
- Dashboard ilk yükleme → meal list skeleton
- Meal scan → "Analyzing..." animasyon
- Premium purchase → spinner + "Processing..."
- Analytics chart yüklenirken → shimmer chart placeholder

**Kütüphane:** `shimmer: ^3.0.0`

---

### Polish 2: Empty States

Veri yoksa ne göstermeli?

| Ekran | Empty State |
|---|---|
| Dashboard (0 meal) | "Start tracking! Tap + to add your first meal" + illustration |
| Analytics (yeni user) | "Log meals for 7 days to see trends" |
| Meal Planner (boş hafta) | "Create your first plan" + CTA |
| Habits (5 default var) | OK, ama custom 0 ise: "Add your first custom habit" |
| Achievements (hiç unlock yok) | "Keep going to unlock achievements" |
| Water timeline (bugün boş) | "+250ml" CTA prominent |

**Pattern:**
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaText;
  final VoidCallback? onCta;
  
  // Centered, 200px illustration, title 20px bold, message 14px secondary, CTA cyan button
}
```

---

### Polish 3: Error Messages (Friendly)

| Backend Error | Friendly Message |
|---|---|
| `401 Unauthorized` | "Please log in again" + auto logout |
| `403 Forbidden` | "You don't have access to this" |
| `404 Not Found` | "Couldn't find that. Maybe it was deleted." |
| `422 Validation` | Specific field hatalarını göster ("Email looks invalid") |
| `500 Server Error` | "Something went wrong on our end. Try again?" |
| `Network timeout` | "Slow connection. Try again?" |
| `OpenAI rate limit` | "AI is busy. Wait a moment and retry." |

---

### Polish 4: Micro-interactions (Hissiyat)

**Haptic feedback** (önemli aksiyon → fiziksel his):
```dart
import 'package:flutter/services.dart';

HapticFeedback.lightImpact();    // butona tıklama
HapticFeedback.mediumImpact();   // önemli aksiyon (save)
HapticFeedback.heavyImpact();    // celebration (achievement)
HapticFeedback.selectionClick(); // chip seçimi
```

**Animations:**
- Tab geçişi: 200ms ease curve
- Card açılış: hero animation
- Number changes: TweenAnimationBuilder ile smooth count-up
- Success: confetti (`confetti: ^0.7.0`)
- Premium unlocked: starburst animation

**Sound effects (opsiyonel):**
```dart
// audioplayers paketi
final player = AudioPlayer();
await player.play(AssetSource('sounds/success.mp3'));
```

Sound'lar dikkatli kullan — kullanıcı **off edebilmeli** (Settings).

---

### Polish 5: Accessibility (A11y)

**Apple zorunlu (App Store reject sebebi):**
- [ ] Semantic labels her butona: `Semantics(label: 'Add food')`
- [ ] Image'lara `semanticsLabel`
- [ ] Color contrast minimum 4.5:1 (cyan #00D4FF on #0B1A3D → kontrol et)
- [ ] Touch target ≥ 44x44 pt
- [ ] Dynamic font size desteği (system font scale)
- [ ] VoiceOver test (iOS) / TalkBack (Android)

**Test:**
```bash
# iOS: Settings → Accessibility → VoiceOver → on
# Tüm ekranlarda swipe ile dolaş — her şey okunuyor mu?
```

---

### Polish 6: Onboarding Tooltips (İlk Kullanım)

İlk açılışta küçük tooltip'ler yardımcı olur:
```dart
// showcaseview paketi
class DashboardScreen extends StatefulWidget {
  // ...
}

// İlk açılışta:
showCaseWidget.startShowCase([
  _addFoodKey,        // "+ Add food" butonu
  _ringChartKey,      // Today's summary
  _streakKey,         // Streak counter
]);

// Sonra: SharedPreferences ile "shown_once" işaretle
```

**Önerim:** Aşırıya kaçma. Max 3-4 tooltip. Skip butonu olsun.

---

### Polish 7: Localization (TR + EN)

`intl` paketi ile multi-language:

```yaml
flutter:
  generate: true

dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
```

**ARB files:**
```
lib/l10n/
├── app_en.arb       # English
├── app_tr.arb       # Turkish
```

**Usage:**
```dart
Text(AppLocalizations.of(context)!.welcomeMessage)
```

**Önemli:**
- Backend response'lar değişmez (data layer dilden bağımsız)
- AI Coach insights backend'de TR/EN olarak generate edilebilir (prompt'a `language` ekle)
- Tarih/sayı formatları locale-aware

---

### Polish 8: Dark Mode / Light Mode

Nuveli zaten **dark theme** (underwater). Light mode opsiyonel:
- Çoğu kullanıcı dark mode tercih eder (özellikle uyumadan önce)
- Light mode yapılırsa Chat 24'te değil, post-launch v1.1'de

Karar:
- ✅ **v1.0**: Sadece dark mode
- ⏳ **v1.1**: Light mode (kullanıcı talep ederse)

---

### Polish 9: Crash Reporting (Sentry)

Production'da hataları yakala:

```dart
// pubspec.yaml
sentry_flutter: ^7.16.0

// main.dart
await SentryFlutter.init(
  (options) {
    options.dsn = dotenv.env['SENTRY_DSN'];
    options.tracesSampleRate = 0.2; // %20 transaction sample
  },
  appRunner: () => runApp(const NuveliApp()),
);

// User context (login sonrası)
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(id: user.id, email: user.email));
});
```

Backend için de aynı:
```python
import sentry_sdk
sentry_sdk.init(dsn=os.getenv("SENTRY_DSN"))
```

Sentry hesabı: Free tier 5000 events/ay yeterli.

---

### Polish 10: Analytics (Firebase / Mixpanel)

Kullanıcı davranışını izlemek için:
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'meal_scanned',
  parameters: {'meal_type': 'breakfast', 'success': true},
);
```

**Önemli event'ler:**
- `signup_completed`
- `onboarding_completed`
- `meal_scanned` (success/fail)
- `meal_logged`
- `premium_paywall_viewed` (source)
- `premium_purchased` (package)
- `premium_cancelled`
- `streak_milestone` (7, 30, 100)
- `achievement_unlocked`

**Tip:** Privacy-first — IP toplama, email gönderme.

---

## 📋 PRE-LAUNCH FINAL CHECKLIST

### Functional ✅
- [ ] Tüm Chat 22 smoke test'leri geçiyor (TEKRAR test et)
- [ ] Tüm Chat 23 testleri yeşil
- [ ] Offline mode graceful
- [ ] Permissions handle edildi
- [ ] Edge case'ler kapsanmış

### UX ✅
- [ ] Loading states her yerde
- [ ] Empty states her ekranda
- [ ] Error messages friendly
- [ ] Haptic feedback eklendi
- [ ] Smooth animations (60 FPS)
- [ ] Tooltips ilk kullanım

### Accessibility ✅
- [ ] Semantic labels
- [ ] Color contrast OK
- [ ] Touch target ≥ 44x44
- [ ] Dynamic font size
- [ ] VoiceOver test
- [ ] RTL test (Arabic preview için)

### Performance ✅
- [ ] Cold start < 3s
- [ ] Tab switch < 200ms
- [ ] 60 FPS scrolling
- [ ] Memory < 200 MB
- [ ] Battery normal

### Production Setup ✅
- [ ] Sentry crash reporting
- [ ] Firebase Analytics
- [ ] Privacy policy URL live
- [ ] Terms of service URL live
- [ ] Support email aktif (support@nuveli.app)
- [ ] Render production plan (free tier launch için riskli)
- [ ] OpenAI budget alert kuruldu
- [ ] Supabase backup daily
- [ ] App Store / Play Console formları dolu

### Marketing ✅
- [ ] Landing page (nuveli.app)
- [ ] Twitter/X duyuru hazır
- [ ] Press kit (logo, screenshots)
- [ ] Email waitlist'e ilk mail

---

## 📋 AÇILIŞ MESAJI (KOPYALA-YAPIŞTIR)

```
Selam Claude! Nuveli AI Calorie Coach projesindeyiz.

📎 Project files'da:
- nuveli_master_plan.md
- nuveli_chat24_hazirlik.md ⭐

📍 Şu an: Chat 24 — Bug Hunt & Pre-Launch Polish
🎯 Hedef: Launch öncesi son rötuş, edge case'leri kapsa, premium hissiyat ver

DURUM:
✅ Chat 21-23 tamamlandı
✅ App çalışıyor, test'ler yeşil
🎯 Şimdi: Launch quality'ye getirme

GÖREVIN — 2 PHASE:

PHASE A: BUG HUNT (Defense)
6 kategori, sistematik:
1. Network & Offline (uçak modu testi)
2. Permission denial (camera, notif, photo)
3. Data edge cases (0 kalori, 50000 kalori, vs.)
4. UI breaking points (iPhone SE, iPad, RTL)
5. State edge cases (token refresh, persistent session)
6. Performance (60 FPS, memory, battery)

Her kategori için:
- Test senaryosu ver
- Ben yapıp sonucu paylaşırım
- Bug bulunca: SEBEBİ + FIX + RETEST

PHASE B: POLISH (Offense)
10 alan:
1. Loading states (skeleton'lar)
2. Empty states (her ekran için)
3. Error messages (friendly mesajlar)
4. Micro-interactions (haptic, animation)
5. Accessibility (a11y zorunlu)
6. Onboarding tooltips
7. Localization (TR + EN setup)
8. Dark mode (zaten var, sadece check)
9. Sentry crash reporting (kurulumu)
10. Firebase Analytics (kritik event'ler)

KURALLAR:
- Phase A önce (kritik), Phase B sonra (kozmetik)
- Her bug → minimum fix (overengineer ETME)
- Her polish → user value (özellik için özellik değil)
- Performance: hedefler net (< 3s cold start, 60 FPS)
- A11y zorunlu (Apple reject sebebi)

ÇIKTI:
1. PRE_LAUNCH_CHECKLIST.md (her madde ✅/❌)
2. KNOWN_ISSUES.md (launch'a katılan minor bug'lar, post-launch'ta düzelt)
3. lib/core/services/connectivity_service.dart (eğer offline pattern eklersek)
4. lib/shared/widgets/empty_state.dart (reusable)
5. lib/shared/widgets/skeleton_loader.dart (shimmer skeleton)
6. lib/l10n/ (ARB files, en azından TR + EN)
7. lib/core/analytics/analytics_service.dart (Firebase wrapper)
8. lib/core/error_reporting/sentry_init.dart

ÖNCELİK:
- Phase A kategori 1-3 (network, permission, data) → KRİTİK
- Phase A kategori 4-6 (UI, state, perf) → ÖNEMLİ
- Phase B 1-5 (UX core) → ÖNEMLİ
- Phase B 6-10 (Sentry, analytics) → İSTEĞE BAĞLI ama önerilen

NASIL ÇALIŞACAĞIZ:
1. Önce Phase A'dan başla (defense)
2. Her kategori için checklist ver, ben test edeyim
3. Bug bulunca durup fix, sonra devam
4. Phase A bittikten sonra Phase B
5. Her polish için "ne, neden, nasıl" açıkla

ÖNEMLİ:
- Bu chat çok uzun olabilir — 2 oturuma bölebiliriz (24a + 24b)
- Phase A ilk gün, Phase B ikinci gün
- Veya kritik olanları seç, gerisini post-launch v1.1
- Mukemmel olma — "good enough to launch" hedef

OLASI BUG'LAR:
- Offline'da app crash
- Camera permission red → meal scan kilitli
- Onboarding back button → state kayıp
- Token expire → infinite loop
- Premium purchase çift tıklama → 2 charge
- Notification permission denial → settings'e bağlı
- iPad layout → çok geniş, çirkin
- Very small font → text overflow

Başla! Önce Phase A Kategori 1 (Network & Offline)'dan başla.
```

---

## ✅ POST-CHAT CHECKLIST

1. **PRE_LAUNCH_CHECKLIST.md %90+ ✅**
2. **Bilinen sorunlar dokümante** (KNOWN_ISSUES.md)
3. **App "feels premium"**:
   - Loading state'ler smooth
   - Animations 60 FPS
   - Error messages anlamlı
   - Empty state'ler güzel
4. **Production setup tamam**:
   - Sentry connected
   - Analytics tracking
   - Crash reports görünüyor
5. **GitHub:**
   ```bash
   git checkout -b feature/chat-24-polish
   git add -A
   git commit -m "feat: Chat 24 - Bug fixes + pre-launch polish"
   git push
   git checkout main
   git merge feature/chat-24-polish
   git tag v1.0.0
   git push origin v1.0.0
   ```
6. **Master plan:** Chat 24 ✅ — **HAZIR LAUNCH!**

---

## 🚀 LAUNCH WEEK PLAN

Chat 24 bitince:

### Pazartesi
- App Store submit + Play Console submit
- Landing page live (nuveli.app)
- Privacy + Terms live

### Salı-Perşembe
- Review beklerken: Product Hunt schedule, Twitter content hazırla
- Email waitlist'e "coming soon" mail
- Beta testers'a son thanks mail

### Cuma
- Apple review tipik 24-48 saat = belki bu gün approval
- Manual release Pazartesi sabah için hazır

### **PAZARTESİ SABAHI: 🚀 GO LIVE!**

- 09:00 Manual release App Store + Play Console
- 09:30 Twitter announcement (thread, demo video)
- 10:00 Product Hunt launch
- 11:00 Email blast
- 12:00 Reddit post (r/SideProject)
- Sonra: dinle, yanıtla, yangın söndür

---

## 📊 BEKLENEN ÇIKTI ÖZETİ

Chat 24 bittiğinde:
- ✅ Network/offline handling
- ✅ Permission flows graceful
- ✅ Edge case'ler kapsanmış
- ✅ Performance hedefleri tutuldu
- ✅ Loading/Empty/Error state'ler her yerde
- ✅ Haptic + animations
- ✅ Accessibility (a11y)
- ✅ Sentry + Analytics
- ✅ TR + EN localization
- ✅ **PRODUCTION READY**

---

## 💎 SON SÖZ

Ali, buraya kadar geldiyen demek **Nuveli'yi LAUNCH'a hazırladın.**

Hatırla:
- 🎯 v1.0 perfect değil — **v1.1, v1.2** olacak
- 📊 İlk hafta data topla, kullanıcı dinle
- 🚀 İlk gün **launch DEĞİL**, bir başlangıç
- 💪 1000 kullanıcıya ulaşmadan **scale problemi düşünme**
- ❤️ Her review'i (1-yıldız bile) bir hediye olarak gör

**Şimdi: yeni chat aç, Chat 21'den başla.**

İyi şanslar! 🌊

---

**🚀 Chat 21 → 22 → 23 → 24 → LAUNCH 🚀**
