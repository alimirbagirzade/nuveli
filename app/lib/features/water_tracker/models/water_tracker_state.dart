import 'water_insight.dart';
import 'water_log.dart';
import 'water_reminder.dart';

/// `WaterTrackerNotifier` tarafından expose edilen ekran state'i.
///
/// Tüm UI bu state'ten okur. Mutable değil — her güncelleme `copyWith` ile
/// yeni bir kopya üretir.
class WaterTrackerState {
  final double consumedLiters;
  final double targetLiters;
  final int filledGlasses;
  final int totalGlasses;
  final List<WaterLog> timeline;
  final List<WaterReminder> reminders;
  final WaterInsight insight;

  const WaterTrackerState({
    required this.consumedLiters,
    required this.targetLiters,
    required this.filledGlasses,
    required this.totalGlasses,
    required this.timeline,
    required this.reminders,
    required this.insight,
  });

  /// 0.0 - 1.0 arası ilerleme oranı (halka grafiği için).
  double get progressRatio =>
      targetLiters == 0 ? 0 : (consumedLiters / targetLiters).clamp(0.0, 1.0);

  /// Yüzde olarak (örn: 70).
  int get progressPercent => (progressRatio * 100).round();

  /// Hedefe kalan litre miktarı (negatif olmaz).
  double get litersLeft =>
      (targetLiters - consumedLiters).clamp(0.0, targetLiters);

  WaterTrackerState copyWith({
    double? consumedLiters,
    double? targetLiters,
    int? filledGlasses,
    int? totalGlasses,
    List<WaterLog>? timeline,
    List<WaterReminder>? reminders,
    WaterInsight? insight,
  }) {
    return WaterTrackerState(
      consumedLiters: consumedLiters ?? this.consumedLiters,
      targetLiters: targetLiters ?? this.targetLiters,
      filledGlasses: filledGlasses ?? this.filledGlasses,
      totalGlasses: totalGlasses ?? this.totalGlasses,
      timeline: timeline ?? this.timeline,
      reminders: reminders ?? this.reminders,
      insight: insight ?? this.insight,
    );
  }
}
