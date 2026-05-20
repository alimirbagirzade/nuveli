# 🧪 Nuveli — Chat 23 Hazırlık Paketi: Testing Suite (Sıfırdan)

**Bu chat'in adı:** `Nuveli - Chat 23: Testing Suite`
**Hedef:** Hiç test deneyimi olmadan, kritik test'leri yazıp regression önleme. Unit + Widget + Integration tests + Backend tests + CI/CD.
**Önkoşul:** Chat 22 (Smoke Test) tamamlanmış. App çalışıyor.
**Tahmini süre:** 1 BÜYÜK chat (uzun — sen öğreneceksin)

---

## 🎓 TEST'E SIFIRDAN BAŞLAYAN İÇİN

### Test nedir, neden yazıyoruz?

Şu sahneyi hayal et: Chat 22'de meal scan'i çalıştırdın, harika. Sonra Chat 24'te "küçük bir UI değişikliği" yaptın. Bilmeden meal scan'i bozdun. Launch'tan 1 saat önce fark ettin. 😱

**Test bunu önler.** Her commit'te otomatik çalışır:
- ✅ Hala signup çalışıyor
- ✅ BMR formülü doğru hesaplıyor  
- ✅ Dashboard mock data göstermiyor
- ❌ Meal scan bozuldu! (uyarı)

---

### 3 Test Türü

| Tür | Ne test eder | Hız | Örnek |
|---|---|---|---|
| **Unit** | Tek bir fonksiyon/sınıf | ⚡ ms | `calculateBMR()` doğru sonuç dönüyor mu |
| **Widget** | Bir UI bileşeni | ⏱️ sn | "Sign In" butonu tıklanınca login çağrıldı mı |
| **Integration** | Tüm app flow'u | 🐢 dk | Signup → Onboarding → Dashboard tam flow |

**Önerim:** Unit test bol yaz (hızlı, ucuz), widget test orta, integration test az ama kritik.

---

## 🎯 BU CHAT'TE ÜRETİLECEK

```
test/
├── unit/
│   ├── core/
│   │   ├── network/
│   │   │   └── api_exceptions_test.dart
│   │   └── utils/
│   │       ├── bmr_calculator_test.dart       ⭐ ÖNEMLİ
│   │       ├── tdee_calculator_test.dart
│   │       └── date_formatter_test.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_service_test.dart
│   │   │   └── password_validator_test.dart
│   │   ├── dashboard/
│   │   │   └── nutrition_score_test.dart
│   │   ├── ai_coach/
│   │   │   └── score_breakdown_test.dart
│   │   └── meal_scan/
│   │       └── portion_score_test.dart
│   └── shared/
│       └── models/
│           └── meal_test.dart                  # fromJson/toJson
│
├── widget/
│   ├── shared/
│   │   ├── nuveli_button_test.dart
│   │   ├── nuveli_card_test.dart
│   │   ├── meal_list_tile_test.dart
│   │   └── streak_card_test.dart
│   ├── auth/
│   │   ├── login_screen_test.dart
│   │   ├── signup_screen_test.dart
│   │   └── onboarding_step_test.dart
│   └── dashboard/
│       └── dashboard_screen_test.dart
│
├── integration_test/
│   ├── auth_flow_test.dart                     ⭐ KRİTİK
│   ├── meal_logging_test.dart                  ⭐ KRİTİK
│   ├── water_tracking_test.dart
│   └── premium_purchase_test.dart              (sandbox)
│
├── helpers/
│   ├── test_helpers.dart                       # makeTestWidget(), mockProviders
│   ├── mock_data.dart                          # Sample User, Meal, etc.
│   └── mock_services.dart                      # MockApiClient
│
└── fixtures/                                    # JSON sample responses
    ├── meals_response.json
    ├── profile_response.json
    └── ai_insight_response.json

backend/tests/
├── conftest.py                                  # Pytest fixtures
├── test_health.py
├── test_profiles.py
├── test_meals.py
├── test_water.py
├── test_habits.py
├── test_ai_coach.py
└── test_auth_dependencies.py

.github/
└── workflows/
    ├── flutter_tests.yml                       # CI: tests on PR
    └── backend_tests.yml                       # CI: pytest on backend changes
```

---

## 📚 TEST 101 — ANAHTAR KAVRAMLAR

### 1. AAA Pattern

Her test 3 bölüm:
```dart
test('calculateBMR returns correct value for male', () {
  // ARRANGE: ortamı hazırla
  const weight = 75.0;
  const height = 180.0;
  const age = 30;
  const gender = Gender.male;
  
  // ACT: kodu çalıştır
  final result = calculateBMR(
    weightKg: weight,
    heightCm: height,
    age: age,
    gender: gender,
  );
  
  // ASSERT: sonucu doğrula
  expect(result, closeTo(1755.0, 0.1)); // ±0.1 tolerans
});
```

---

### 2. Expect Matchers

```dart
expect(42, equals(42));                    // ==
expect('hello', isA<String>());            // tip kontrolü
expect(myList, contains('item'));          // içerir mi
expect(myList, hasLength(3));              // uzunluk
expect(myMap, containsPair('key', 'val'));// map'te var mı
expect(() => throwingFn(), throwsA(isA<ArgumentError>()));
expect(future, completes);                 // Future biter mi
expect(myValue, isNotNull);
expect(myValue, isNull);
```

---

### 3. setUp / tearDown

```dart
group('MealsRepository', () {
  late MealsRepository repo;
  late MockApiClient mockApi;
  
  setUp(() {
    // Her test öncesi
    mockApi = MockApiClient();
    repo = MealsRepository(mockApi);
  });
  
  tearDown(() {
    // Her test sonrası temizlik
  });
  
  test('getTodaysMeals returns meal list', () async {
    // arrange
    when(mockApi.get(any)).thenAnswer((_) async => [/* sample data */]);
    // act
    final meals = await repo.getTodaysMeals();
    // assert
    expect(meals, hasLength(2));
  });
});
```

---

### 4. Mocking (mockito veya mocktail)

Test'te gerçek API çağrısı yapma, **fake** ile değiştir:

```dart
// mocktail kullanımı
class MockApiClient extends Mock implements ApiClient {}

test('login calls api with correct params', () async {
  final mockApi = MockApiClient();
  
  // Fake response
  when(() => mockApi.post('/login', data: any(named: 'data')))
    .thenAnswer((_) async => {'token': 'fake-token'});
  
  final service = AuthService(mockApi);
  await service.login('test@test.com', 'pass123');
  
  // Doğrulama: api çağrıldı mı, doğru parametrelerle
  verify(() => mockApi.post(
    '/login',
    data: {'email': 'test@test.com', 'password': 'pass123'},
  )).called(1);
});
```

---

## 🧪 ÖRNEK TESTLER (KOPYALA, ÖĞREN)

### 1. Unit Test — BMR Calculator

```dart
// test/unit/core/utils/bmr_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/utils/bmr_calculator.dart';

void main() {
  group('BMR Calculator (Mifflin-St Jeor)', () {
    test('correct value for adult male', () {
      // 75kg, 180cm, 30 yaş erkek
      final result = calculateBMR(
        weightKg: 75.0,
        heightCm: 180.0,
        age: 30,
        gender: Gender.male,
      );
      // Formül: 10*75 + 6.25*180 - 5*30 + 5 = 750 + 1125 - 150 + 5 = 1730
      expect(result, closeTo(1730, 0.1));
    });
    
    test('correct value for adult female', () {
      final result = calculateBMR(
        weightKg: 65.0,
        heightCm: 165.0,
        age: 28,
        gender: Gender.female,
      );
      // 10*65 + 6.25*165 - 5*28 - 161 = 650 + 1031.25 - 140 - 161 = 1380.25
      expect(result, closeTo(1380.25, 0.1));
    });
    
    test('throws on negative weight', () {
      expect(
        () => calculateBMR(weightKg: -10, heightCm: 170, age: 25, gender: Gender.male),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    test('throws on age 0', () {
      expect(
        () => calculateBMR(weightKg: 70, heightCm: 170, age: 0, gender: Gender.male),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

---

### 2. Unit Test — Nutrition Score

```dart
// test/unit/features/ai_coach/score_breakdown_test.dart
void main() {
  group('Nutrition Score (0-100)', () {
    test('full score when all targets met', () {
      final score = calculateNutritionScore(
        dailyKcal: 2000,
        targetKcal: 2000,        // %100 match → 40 puan
        proteinG: 100, carbsG: 250, fatG: 60,  // target makro
        proteinTarget: 100, carbsTarget: 250, fatTarget: 60,  // 30 puan
        waterMl: 2500,           // hedef ≥ 2500 → 15 puan
        habitsCompleted: 5, habitsTotal: 5,  // 15 puan
      );
      
      expect(score, equals(100));
    });
    
    test('40 puan calorie OK ama macro/water/habits sıfır', () {
      final score = calculateNutritionScore(
        dailyKcal: 2000, targetKcal: 2000,  // 40 puan
        proteinG: 0, carbsG: 500, fatG: 0,  // dengesiz → 0 puan
        proteinTarget: 100, carbsTarget: 250, fatTarget: 60,
        waterMl: 0,                          // 0 puan
        habitsCompleted: 0, habitsTotal: 5,  // 0 puan
      );
      
      expect(score, equals(40));
    });
    
    test('score does not exceed 100', () {
      final score = calculateNutritionScore(
        dailyKcal: 2100, targetKcal: 2000,   // %5 fark = full 40 puan
        proteinG: 100, carbsG: 250, fatG: 60,
        proteinTarget: 100, carbsTarget: 250, fatTarget: 60,
        waterMl: 5000,                       // hedeften fazla
        habitsCompleted: 5, habitsTotal: 5,
      );
      
      expect(score, lessThanOrEqualTo(100));
    });
  });
}
```

---

### 3. Widget Test — Login Screen

```dart
// test/widget/auth/login_screen_test.dart
void main() {
  group('LoginScreen', () {
    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      
      // Email field var mı
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      // Password field var mı
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      // Sign In butonu var mı
      expect(find.text('Sign in'), findsOneWidget);
    });
    
    testWidgets('shows error on empty email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: LoginScreen())),
      );
      
      // Sign in butonuna direkt bas (email boş)
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      
      // Hata mesajı görünmeli
      expect(find.text('Email is required'), findsOneWidget);
    });
    
    testWidgets('calls login with entered credentials', (tester) async {
      // Mock provider override
      final mockAuth = MockAuthNotifier();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => mockAuth),
          ],
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      
      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'pass123');
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      
      // Login çağrıldı mı doğru parametrelerle?
      verify(() => mockAuth.signInWithEmail(
        email: 'test@test.com',
        password: 'pass123',
      )).called(1);
    });
  });
}
```

---

### 4. Integration Test — Auth Flow

```dart
// integration_test/auth_flow_test.dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Auth Flow E2E', () {
    testWidgets('signup → onboarding → dashboard', (tester) async {
      // Test environment ile başlat
      await tester.pumpWidget(const NuveliApp());
      await tester.pumpAndSettle();
      
      // Welcome screen
      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Signup screen
      final randomEmail = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
      await tester.enterText(find.byKey(const Key('email_field')), randomEmail);
      await tester.enterText(find.byKey(const Key('password_field')), 'TestPass123!');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'TestPass123!');
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Onboarding Step 1
      expect(find.text("Hi! Let's get to know you"), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // ... diğer onboarding adımları
      
      // Dashboard'a varış
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
```

---

### 5. Backend Test (pytest)

```python
# backend/tests/test_meals.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

@pytest.fixture
def auth_token(test_user):
    """Sahte JWT token üret (test için)"""
    return create_test_jwt(user_id=test_user.id)

def test_create_meal_requires_auth():
    """Auth header olmadan 401 dönmeli"""
    response = client.post('/meals', json={'meal_type': 'breakfast'})
    assert response.status_code == 401

def test_create_meal_with_foods(auth_token):
    """Meal + foods birlikte oluşturulmalı"""
    response = client.post(
        '/meals',
        json={
            'meal_type': 'breakfast',
            'name': 'Greek Yogurt Bowl',
            'foods': [
                {
                    'name': 'Yogurt',
                    'calories': 150,
                    'protein_g': 15,
                    'carbs_g': 12,
                    'fat_g': 4,
                },
            ],
        },
        headers={'Authorization': f'Bearer {auth_token}'},
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data['name'] == 'Greek Yogurt Bowl'
    assert data['total_calories'] == 150  # Trigger ile auto-calculated
    assert len(data['meal_foods']) == 1

def test_get_meals_only_returns_user_meals(auth_token, other_user_token):
    """RLS: kullanıcı sadece kendi meal'lerini görmeli"""
    # User A creates meal
    client.post('/meals', json={...}, headers={'Authorization': f'Bearer {auth_token}'})
    
    # User B fetches meals
    response = client.get('/meals', headers={'Authorization': f'Bearer {other_user_token}'})
    
    assert response.status_code == 200
    assert len(response.json()) == 0  # Kendi meal'i yok
```

---

## 🚀 CI/CD (GitHub Actions)

### .github/workflows/flutter_tests.yml

```yaml
name: Flutter Tests

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze --no-fatal-infos
      
      - name: Run unit + widget tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

### .github/workflows/backend_tests.yml

```yaml
name: Backend Tests

on:
  pull_request:
    paths:
      - 'backend/**'
  push:
    branches: [main]
    paths:
      - 'backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        working-directory: backend
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-asyncio httpx
      
      - name: Run pytest
        working-directory: backend
        run: pytest -v
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL_TEST }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY_TEST }}
          SUPABASE_JWT_SECRET: ${{ secrets.SUPABASE_JWT_SECRET_TEST }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY_TEST }}
```

---

## 📋 AÇILIŞ MESAJI (KOPYALA-YAPIŞTIR)

```
Selam Claude! Nuveli AI Calorie Coach projesindeyiz.

📎 Project files'da:
- nuveli_master_plan.md
- nuveli_chat23_hazirlik.md ⭐

📍 Şu an: Chat 23 — Testing Suite (sıfırdan)
🎯 Hedef: Kritik testleri yaz, CI/CD kur, regression önle

DURUM:
✅ Chat 21 + 22 tamamlandı
✅ Tüm flow'lar manuel test edildi, çalışıyor
🟡 Test deneyimim YOK (hiç test yazmadım)
🎯 Bu chat'te: ÖĞRENEREK test yazacağız

ÖĞRETME MODU:
- Her test öncesi: BU TEST NE YAPIYOR ne demek
- AAA pattern (Arrange-Act-Assert) açıkla
- Mocking nedir, neden yapıyoruz açıkla
- Her satıra yorum ekle (ilk testlerde)
- Beni "test culture"a alıştır

ÜRETİLECEK TEST YAPISI (öncelik sıralı):

ÖNCELİK 1 — UNIT TESTS (en hızlı, en faydalı):
1. test/unit/core/utils/bmr_calculator_test.dart (formül doğruluğu)
2. test/unit/core/utils/tdee_calculator_test.dart
3. test/unit/features/ai_coach/score_breakdown_test.dart (nutrition score)
4. test/unit/features/meal_scan/portion_score_test.dart
5. test/unit/core/network/api_exceptions_test.dart
6. test/unit/shared/models/meal_test.dart (fromJson/toJson)

ÖNCELİK 2 — WIDGET TESTS (UI doğrulama):
1. test/widget/shared/nuveli_button_test.dart (loading state, tap)
2. test/widget/auth/login_screen_test.dart (validation, submit)
3. test/widget/auth/signup_screen_test.dart
4. test/widget/dashboard/dashboard_screen_test.dart (provider mock'lu)

ÖNCELİK 3 — INTEGRATION TESTS (kritik flow):
1. integration_test/auth_flow_test.dart (signup → onboarding → dashboard)
2. integration_test/meal_logging_test.dart (add meal → see in dashboard)

ÖNCELİK 4 — BACKEND TESTS (pytest):
1. backend/tests/conftest.py (fixtures)
2. backend/tests/test_health.py
3. backend/tests/test_meals.py (RLS dahil)
4. backend/tests/test_auth_dependencies.py

ÖNCELİK 5 — CI/CD:
1. .github/workflows/flutter_tests.yml
2. .github/workflows/backend_tests.yml

HELPER'LAR:
- test/helpers/test_helpers.dart (makeTestWidget pattern)
- test/helpers/mock_data.dart (sample User, Meal vs.)
- test/helpers/mock_services.dart (MockApiClient, MockAuthService)

PAKETLER (pubspec.yaml dev_dependencies):
- flutter_test (mevcut)
- integration_test (mevcut)
- mocktail: ^1.0.0
- network_image_mock: ^2.1.1 (Image.network test için)

KURALLAR:
- HER test'i açıklayarak yaz (yorum ekle)
- AAA pattern her zaman görünür
- Test'in adı NE YAPTIĞINI söylesin (test ne anlamına gelmemeli)
- Mock'ları abartma — gerçekçi data kullan
- Coverage 80% hedefi (gerçek, 60-70 de OK launch için)
- Flaky test yok (her zaman aynı sonuç)

ÖNEMLİ:
- Test bir kez yaz, sonsuza dek çalışır
- Test fail olunca: TEST DOĞRU MU önce kontrol et, sonra kod
- Slow test → suspect (network, sleep, vs.)
- "Test for testing's sake" yapma — kritik path'ler önce
- Coverage uğruna test yazma — value'su olsun

GÖREV SIRASI:
1. Önce ÖĞRETİM (10 dk): "Test nedir, neden yazıyoruz, AAA pattern"
2. Sonra Önelik 1 — Unit tests (5 dosya, en basit, en hızlı)
3. Her test bittikten sonra: `flutter test test/unit/...` çalıştır, sonucu gör
4. Önelik 2 — Widget tests (3 dosya)
5. Önelik 3 — Integration tests (1-2 kritik flow)
6. Önelik 4 — Backend tests
7. Önelik 5 — CI/CD

İLK ADIM:
"Önce sana test'in mantığını anlat. Sonra ilk unit test'i birlikte yazalım — BMR calculator (en basit, sonucu net). Sen test'i çalıştır, görelim yeşil mi."

Başla!
```

---

## ✅ POST-CHAT CHECKLIST

1. **Unit tests yeşil:**
   ```bash
   flutter test test/unit/
   # All tests passed!
   ```

2. **Widget tests yeşil:**
   ```bash
   flutter test test/widget/
   ```

3. **Integration tests yeşil:**
   ```bash
   flutter test integration_test/
   ```

4. **Backend tests yeşil:**
   ```bash
   cd backend && pytest -v
   ```

5. **Coverage report (opsiyonel):**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

6. **GitHub Actions yeşil:**
   - PR aç → CI çalışsın → green ✅

7. **Master plan:** Chat 23 ✅

---

## 🎯 BEKLENEN TEST SAYISI

Bu chat sonunda elinde olacak:
- ~25-30 unit test
- ~8-10 widget test
- ~2-3 integration test
- ~10-15 backend test
- 2 CI/CD workflow

**Toplam: ~50 test.** Bu bir startup launch için **iyi** bir başlangıç. (Big tech 1000+ olur ama Nuveli için fazlasıyla yeterli.)

---

## 🚨 YAYGIN TEST HATALARI

| Hata | Sebep | Çözüm |
|---|---|---|
| `Type 'X' not found` | Import eksik | Hata mesajındaki dosyayı import et |
| `Bad state: Cannot find a default value` | Provider override yok | `ProviderScope(overrides: [...])` |
| `pumpAndSettle timed out` | Sonsuz loading | Mock'la veya time-limited await |
| `MissingPluginException` | Native plugin test'te yok | `TestWidgetsFlutterBinding.ensureInitialized()` |
| Test geçti ama yanlış | Assertion zayıf | `expect(true, true)` değil, gerçek değer |
| Flaky (bazen geçer bazen kalır) | Race condition | `await tester.pumpAndSettle()` ekle |
| `late initialization` hata | setUp olmadı | `late` yerine init et |
| Network test çok yavaş | Gerçek API çağrısı | Mock'la! |
| Coverage 0% | `--coverage` flag eksik | `flutter test --coverage` |

---

## 💡 TEST FELSEFESİ — Önemli Mottolar

> **"Test'le söyleşmek, kodla söyleşmekten daha hızlıdır."**

> **"Bir test geçtiyse ama kod yanlışsa, test zayıftır."**

> **"Bug yakalamak için değil, REGRESSION önlemek için yazıyoruz."**

> **"Test yazmak = gelecekteki sana güven göstermek."**

---

## 🔗 BU CHAT'TEN SONRA NE OLACAK?

```
Chat 23 (Testing) ✅ Kritik test'ler var, CI yeşil
   ↓
Chat 24 (Polish) → Edge case, UX, accessibility, performance
   ↓
🚀 PRODUCTION READY
```

---

**🚀 Chat 22 bitince Chat 23'e geç. Test yazmak ÖĞRENİLİR — endişelenme!**
