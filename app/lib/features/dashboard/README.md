# Chat 4 — Dashboard Screen

Nuveli AI Calorie Coach — Dashboard ekranı (Görsel 1).

## 📦 Kurulum

### 1. Dosyaları yerleştir

ZIP'i aç ve `dashboard/` klasörünü olduğu gibi şuraya koy:

```
your_flutter_project/
└── lib/
    └── features/
        └── dashboard/     ← buraya
            ├── dashboard_screen.dart
            ├── models/
            ├── data/
            ├── providers/
            └── widgets/
```

Terminal komutu (proje root'undan):
```bash
mkdir -p lib/features
unzip nuveli_chat4_dashboard.zip -d lib/features/
```

### 2. Paket bağımlılıkları

`pubspec.yaml`'da bu üçü olmalı (Chat 1'de eklenmiş olmalı, kontrol et):

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  intl: ^0.19.0
```

Yoksa:
```bash
flutter pub add flutter_riverpod intl
```

### 3. Paket adı kontrolü

Tüm dosyalarda `package:nuveli/...` import'ları var.
`pubspec.yaml`'daki `name:` satırı farklıysa (örn. `nuveli_test`) tüm `.dart` dosyalarında bul-değiştir yap:

```bash
# macOS / Linux
find lib/features/dashboard -name "*.dart" -exec sed -i '' 's|package:nuveli/|package:nuveli_test/|g' {} \;
```

### 4. Main'e bağla

`main.dart`'ta `MaterialApp`'in `home`'unu geçici olarak şu yap:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: NuveliApp()));
}

class NuveliApp extends StatelessWidget {
  const NuveliApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
```

### 5. Çalıştır

```bash
flutter run
```

## ✅ Beklenen Görünüm

- Halka: **1,480 / 2,100 kcal** (~%70 dolu, cyan)
- Halka altında: **620 kcal left**
- Makrolar: Protein 95/140g, Carbs 160/210g, Fat 48/70g
- 3 öğün: Greek Yogurt (7:30 AM) / Grilled Chicken (12:45 PM) / Salmon (7:15 PM)
- Cyan **+ Add Food** butonu
- Bottom nav

## 🐛 Olası Hatalar

| Hata | Çözüm |
|---|---|
| `Target of URI doesn't exist: package:nuveli/...` | Paket adı farklı, adım 3'ü uygula |
| `Undefined name 'AppColors.proteinColor'` | Chat 1'de bu rengi farklı isimlendirmişsin (örn. `protein`), `app_colors.dart`'ı kontrol et |
| `MealListTile.dashboard isn't defined` | Chat 3'te factory yok, `meals_section.dart`'ta `MealListTile.dashboard(...)` → `MealListTile(...)` yap |
| `NuveliButton` parametre hatası | Chat 1'deki imzaya bak, `add_food_button.dart`'ı uydur |

Tüm bu uyumsuzluklar dakikalar içinde düzelir, Chat 1/2/3 dosyalarının imzasını paylaşırsan ben senin için düzeltirim.
