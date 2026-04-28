import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Su, kilo, mood check-in için API istekleri.
class TrackingRepository {
  TrackingRepository(this._api);
  final ApiClient _api;

  String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Su kaydı ekle (ml cinsinden).
  Future<void> addWater(int amountMl) async {
    try {
      await _api.dio.post('/water', data: {
        'amount_ml': amountMl,
        'local_day': _today,
      });
    } catch (e) {
      throw AppError.fromDioError(e);
    }
  }

  /// Kilo kaydı ekle/güncelle.
  Future<void> saveWeight(double kg) async {
    try {
      await _api.dio.post('/weight', data: {
        'weight_kg': kg,
        'local_day': _today,
      });
    } catch (e) {
      throw AppError.fromDioError(e);
    }
  }

  /// Mood check-in.
  Future<void> saveMood(String mood, {String? note}) async {
    try {
      await _api.dio.post('/checkins', data: {
        'mood': mood,
        if (note != null) 'note': note,
        'local_day': _today,
      });
    } catch (e) {
      throw AppError.fromDioError(e);
    }
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(ref.read(apiClientProvider));
});
