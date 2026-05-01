import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Su, kilo, mood check-in için API istekleri.
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(ref.watch(apiClientProvider));
});

/// Single day of water intake (aggregate of all entries for that day).
class WaterDay {
  const WaterDay({required this.day, required this.totalMl});
  final DateTime day;
  final int totalMl;

  factory WaterDay.fromJson(Map<String, dynamic> json) {
    return WaterDay(
      day: DateTime.parse(json['local_day'] as String),
      totalMl: (json['total_ml'] as num? ?? 0).toInt(),
    );
  }
}

class WaterHistory {
  const WaterHistory({
    required this.entries,
    required this.averageMl,
    required this.days,
  });
  final List<WaterDay> entries;
  final int averageMl;
  final int days;

  factory WaterHistory.fromJson(Map<String, dynamic> json) {
    final raw = (json['entries'] as List?) ?? const [];
    return WaterHistory(
      entries: raw
          .whereType<Map<String, dynamic>>()
          .map(WaterDay.fromJson)
          .toList(),
      averageMl: (json['average_ml'] as num? ?? 0).toInt(),
      days: (json['days'] as num? ?? 0).toInt(),
    );
  }
}

/// Single weight log entry (one per day).
class WeightEntry {
  const WeightEntry({required this.day, required this.weightKg});
  final DateTime day;
  final double weightKg;

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      day: DateTime.parse(json['local_day'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
    );
  }
}

class TrackingRepository {
  TrackingRepository(this._dio);
  final Dio _dio;

  String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// POST /water — Su kaydı ekle (ml cinsinden).
  Future<void> addWater(int amountMl) async {
    try {
      await _dio.post('/water', data: {
        'amount_ml': amountMl,
        'local_day': _today,
      });
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// POST /weight — Kilo kaydı ekle/güncelle.
  Future<void> saveWeight(double kg) async {
    try {
      await _dio.post('/weight', data: {
        'weight_kg': kg,
        'local_day': _today,
      });
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// POST /checkins — Mood check-in.
  Future<void> saveMood(String mood, {String? note}) async {
    try {
      await _dio.post('/checkins', data: {
        'mood': mood,
        if (note != null) 'note': note,
        'local_day': _today,
      });
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// GET /water/history — Günlük toplam su miktarları (son N gün).
  Future<WaterHistory> getWaterHistory({int days = 30}) async {
    try {
      final response = await _dio.get(
        '/water/history',
        queryParameters: {'days': days},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return WaterHistory.fromJson(data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// GET /weight/history — Kilo kayıtları (son 90 gün).
  Future<List<WeightEntry>> getWeightHistory() async {
    try {
      final response = await _dio.get('/weight/history');
      final list = (response.data['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(WeightEntry.fromJson)
          .toList();
      // Backend orders newest-first; keep that for display, the chart
      // widget will reverse internally for left-to-right time axis.
      return list;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

/// Auto-disposed providers so leaving and re-entering history pages
/// always shows fresh data without manual cache busting.
final waterHistoryProvider =
    FutureProvider.autoDispose<WaterHistory>((ref) async {
  final repo = ref.watch(trackingRepositoryProvider);
  return repo.getWaterHistory(days: 30);
});

final weightHistoryProvider =
    FutureProvider.autoDispose<List<WeightEntry>>((ref) async {
  final repo = ref.watch(trackingRepositoryProvider);
  return repo.getWeightHistory();
});
