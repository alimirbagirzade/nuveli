import 'package:flutter/material.dart';

import '../models/water_insight.dart';
import '../models/water_log.dart';
import '../models/water_reminder.dart';

/// Bugünün su kayıtları — Görsel 5'teki Timeline ile birebir.
///
/// Toplam: 250 + 500 + 500 + 250 + 600 = 2,100 ml = 2.1 L ✅
final mockTodaysWaterLogs = <WaterLog>[
  WaterLog(
    id: '1',
    amountMl: 250,
    loggedAt: DateTime.now().copyWith(hour: 9, minute: 0, second: 0),
  ),
  WaterLog(
    id: '2',
    amountMl: 500,
    loggedAt: DateTime.now().copyWith(hour: 11, minute: 30, second: 0),
  ),
  WaterLog(
    id: '3',
    amountMl: 500,
    loggedAt: DateTime.now().copyWith(hour: 13, minute: 0, second: 0),
  ),
  WaterLog(
    id: '4',
    amountMl: 250,
    loggedAt: DateTime.now().copyWith(hour: 15, minute: 45, second: 0),
    isCompleted: false,
  ),
  WaterLog(
    id: '5',
    amountMl: 600,
    loggedAt: DateTime.now().copyWith(hour: 18, minute: 30, second: 0),
    isCompleted: false,
  ),
];

/// Mock reminder listesi — Görsel 5 ile birebir (hepsi açık).
final mockWaterReminders = <WaterReminder>[
  const WaterReminder(
    id: 'r1',
    title: 'Morning reminder',
    time: TimeOfDay(hour: 9, minute: 0),
    isEnabled: true,
  ),
  const WaterReminder(
    id: 'r2',
    title: 'Afternoon reminder',
    time: TimeOfDay(hour: 13, minute: 0),
    isEnabled: true,
  ),
  const WaterReminder(
    id: 'r3',
    title: 'Evening reminder',
    time: TimeOfDay(hour: 18, minute: 30),
    isEnabled: true,
  ),
];

/// Mock insight — Görsel 5'teki "Insights" kartı.
const mockWaterInsight = WaterInsight(
  mainText: 'You hydrate better before lunch.',
  subText: 'Keep it up! Consistency leads to results.',
  icon: Icons.water_drop,
);

/// Sabit konfig + hesaplanmış değerler.
class WaterMockData {
  static const double targetLiters = 3.0;
  static const int glassSizeMl = 250;

  /// Görsel 5'teki ızgaranın boyutu. Hedef 2.5L gibi davranır
  /// (10 × 250ml = 2500ml). Halka hedefi (3.0L) ile karıştırma.
  static const int totalGlasses = 10;

  /// Tüm log'ların toplamını L cinsinden döner.
  static double get consumedLiters {
    final totalMl = mockTodaysWaterLogs.fold<int>(
      0,
      (sum, log) => sum + log.amountMl,
    );
    return totalMl / 1000.0;
  }

  /// 2.1L içildiğinde teorik olarak 8 bardak dolar (2100/250 = 8.4).
  /// Ancak Görsel 5'te 7 bardak dolu görünüyor, bu yüzden manuel sabit.
  /// (Tasarım kararı: kullanıcı kafiyeli hissetsin diye "kısmi bardak"
  ///  dolduğunda hesaba katılmaz.)
  static const int filledGlasses = 7;
}
