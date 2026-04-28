import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Su, kilo, mood check-in için API istekleri.
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(ref.watch(apiClientProvider));
});

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
}
