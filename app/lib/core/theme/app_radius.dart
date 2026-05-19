/// Nuveli border radius sistemi
///
/// Chat 4-11 kodunda kullanılan değerler (gerçek kullanıma göre):
/// - AppRadius.pill → progress bar, weight goal pill, vs.
/// - AppRadius.card → camera frame, kart dış köşeleri
///
/// Master plan'a göre ek değerler de var (kullanılmıyor ama uyumluluk için).
class AppRadius {
  AppRadius._();

  // ─── Kullanım Görülmüş ──────────────────────────────────────
  /// Tamamen yuvarlanmış (pill / chip shape)
  static const double pill = 999.0;

  /// Standart kart radius (camera frame, kart yüzeyi)
  static const double card = 20.0;

  // ─── Master Plan Standart Scale ─────────────────────────────
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 28.0;   // butonlar
  static const double cardLarge = card;
  static const double button = xl;
}
