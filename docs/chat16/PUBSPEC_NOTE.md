# 📦 Chat 16 — pubspec.yaml Eklemesi

`pubspec.yaml` dosyandaki **dependencies:** bloğuna şu satırı ekle (varsa atla):

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... mevcut paketlerin ...
  dio: ^5.4.0   # ← BUNU EKLE (Chat 16)
```

Sonra:

```bash
flutter pub get
```

## ✅ Var olması gerekenler (önceki chat'lerden)

Bunlar zaten ekli olmalı — yoksa pubspec'e ekle:

```yaml
flutter_riverpod: ^2.4.0
supabase_flutter: ^2.3.0
```

## 🧪 Hızlı doğrulama

`flutter pub get` çalıştıktan sonra projeyi build et:

```bash
flutter analyze lib/core/network/
```

`api_client.dart`, `auth_interceptor.dart`, `api_endpoints.dart`,
`api_exceptions.dart` için 0 error / 0 warning beklenir.
