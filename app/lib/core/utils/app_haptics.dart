import 'package:flutter/services.dart';

/// Haptic feedback helper — kullanıcı deneyimini zenginleştiren titreşimler.
///
/// iOS ve Android'de farklı davranır:
/// - iOS: Haptic Engine (Taptic) ile net hissiyat
/// - Android: Vibrator API, daha kaba
///
/// Kullanım kuralı: Sadece kullanıcı gerçekten bir şey yaptığında titreşim.
/// Aşırı kullanımdan kaçın (her tap'ta titreşim YAPMA).
class AppHaptics {
  AppHaptics._();

  /// Hafif dokunuş — checkbox, switch, küçük aksiyonlar.
  /// Kullanıldığı yerler: onboarding adım geçişi, switch toggle.
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Device desteklemiyorsa sessizce geç
    }
  }

  /// Orta şiddet — önemli aksiyonlar.
  /// Kullanıldığı yerler: meal confirm, message send, CTA tıklama.
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Güçlü — kritik/geri alınamaz aksiyonlar.
  /// Kullanıldığı yerler: delete confirm, purchase success, onboarding complete.
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Seçim değişimi — slider, picker.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Başarı — trial activate, meal saved, onboarding done.
  /// iOS'ta özel "success" pattern.
  static Future<void> success() async {
    try {
      // iOS'ta mediumImpact başarı için en iyi
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Hata — validation fail, limit exceeded.
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Uyarı — premium limit approaching, network retry.
  static Future<void> warning() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
