/// Form alan validator'ları — pure function'lar, test edilebilir.
///
/// Kullanım:
/// ```dart
/// TextFormField(
///   validator: AppValidators.email,
/// )
/// ```
class AppValidators {
  AppValidators._();

  // ─────────────────────────────────────────────────────────────
  // Email
  // ─────────────────────────────────────────────────────────────

  /// RFC 5322'nin basitleştirilmiş hali. Türkçe karakter kabul edilir.
  /// "user@example.com" ✓
  /// "user@" ✗
  /// "user" ✗
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email gerekli';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Geçerli bir email gir';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Password
  // ─────────────────────────────────────────────────────────────

  /// Login için: sadece "boş değil + min 6 karakter".
  /// Mevcut kullanıcının eski şifresi 6 karakterden kısa olabilir,
  /// signup için ayrı validator kullan.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'En az 6 karakter';
    }
    return null;
  }

  /// Signup için sıkı validator — minimum güvenlik için.
  /// 8+ karakter, en az 1 sayı, en az 1 harf.
  static String? passwordStrong(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 8) {
      return 'En az 8 karakter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'En az bir rakam içermeli';
    }
    if (!value.contains(RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ]'))) {
      return 'En az bir harf içermeli';
    }
    return null;
  }

  /// Şifre tekrarı doğrulaması.
  static String? Function(String?) passwordMatch(String original) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Şifreyi tekrar gir';
      }
      if (value != original) {
        return 'Şifreler eşleşmiyor';
      }
      return null;
    };
  }

  // ─────────────────────────────────────────────────────────────
  // Generic required
  // ─────────────────────────────────────────────────────────────

  /// Boş olamaz.
  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName gerekli';
      }
      return null;
    };
  }

  // ─────────────────────────────────────────────────────────────
  // Numeric
  // ─────────────────────────────────────────────────────────────

  /// Sayı parse edilebiliyor mu + opsiyonel min/max kontrolü.
  static String? Function(String?) numeric({
    int? min,
    int? max,
    String? fieldName,
  }) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '${fieldName ?? 'Bu alan'} gerekli';
      }
      final n = int.tryParse(value.trim());
      if (n == null) return 'Sayı gir';
      if (min != null && n < min) return 'En az $min olmalı';
      if (max != null && n > max) return 'En fazla $max olmalı';
      return null;
    };
  }

  /// Yaş için özel — 18-100 arası.
  static String? age(String? value) {
    return numeric(min: 18, max: 100, fieldName: 'Yaş')(value);
  }

  /// Kilo için (kg) — 30-300 arası.
  static String? weight(String? value) {
    return numeric(min: 30, max: 300, fieldName: 'Kilo')(value);
  }

  /// Boy için (cm) — 100-250 arası.
  static String? height(String? value) {
    return numeric(min: 100, max: 250, fieldName: 'Boy')(value);
  }
}
