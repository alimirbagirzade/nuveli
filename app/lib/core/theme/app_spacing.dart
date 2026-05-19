/// Nuveli spacing sistemi — 8'in katları
///
/// Chat 4-11 kodunda kullanılan değerler (gerçek kullanıma göre):
/// - AppSpacing.sm  → 8  (en yaygın)
/// - AppSpacing.md  → 16 (kart padding'leri)
/// - AppSpacing.lg  → 24 (section gap'leri)
///
/// Not: Bazı yerlerde `AppSpacing.sm + 4` veya `AppSpacing.lg + 4` görülüyor
/// (12 ve 28). Ben sm=8 ve lg=24 tutarak o pattern'i bozmuyorum.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 8.0;    // sm + 4 = 12 olur (kodda yaygın)
  static const double md = 16.0;
  static const double lg = 24.0;   // lg + 4 = 28 olur
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ─── YAYGIN PADDING'LER ───
  /// Kart iç padding'i
  static const double cardPadding = 16.0;

  /// Ekran kenar padding'i
  static const double screenPadding = 16.0;

  /// Section'lar arası boşluk
  static const double sectionGap = 24.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
}
