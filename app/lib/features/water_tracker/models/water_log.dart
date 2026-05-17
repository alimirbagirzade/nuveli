/// Bir su tüketim kaydını temsil eder.
///
/// Mock data'da ya da kullanıcı `+250ml` butonuna bastığında üretilir.
/// Timeline kartında görüntülenirken `formattedTime` ve `formattedAmount`
/// getter'ları kullanılır.
class WaterLog {
  final String id;
  final int amountMl;
  final DateTime loggedAt;
  final bool isCompleted;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
    this.isCompleted = true,
  });

  /// "9:00 AM", "1:00 PM" gibi 12-saat formatı.
  String get formattedTime {
    final hour = loggedAt.hour;
    final minute = loggedAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// "250 ml", "600 ml" gibi.
  String get formattedAmount => '$amountMl ml';

  WaterLog copyWith({
    String? id,
    int? amountMl,
    DateTime? loggedAt,
    bool? isCompleted,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
