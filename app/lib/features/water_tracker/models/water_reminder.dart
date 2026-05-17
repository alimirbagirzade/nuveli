import 'package:flutter/material.dart';

/// Su içme hatırlatıcısı (Morning / Afternoon / Evening).
///
/// `isEnabled` toggle'ı `WaterRemindersCard`'taki switch ile kontrol edilir.
/// Gerçek `flutter_local_notifications` entegrasyonu Chat 17'de gelecek.
class WaterReminder {
  final String id;
  final String title;
  final TimeOfDay time;
  final bool isEnabled;

  const WaterReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.isEnabled,
  });

  /// "9:00 AM", "6:30 PM" gibi 12-saat formatı.
  String get formattedTime {
    final h = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayHour:$m $period';
  }

  WaterReminder copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    bool? isEnabled,
  }) {
    return WaterReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
