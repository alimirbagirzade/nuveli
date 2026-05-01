import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Kullanıcının streak (gamification) verilerini tutan model.
///
/// Backend hem `/streak` endpoint'inden hem de `/home` payload'unda
/// streak alanı gönderir; her iki yerden de aynı modeli okuyabiliriz.
class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.longest,
    required this.todayLogged,
    required this.atRisk,
    this.lastActiveDay,
    this.milestone,
  });

  /// Şu an aktif streak (gün sayısı).
  final int current;

  /// Tüm zamanların en uzun streak'i.
  final int longest;

  /// Bugün öğün eklendi mi?
  final bool todayLogged;

  /// Akşam oldu, bugün kayıt yok → streak risk altında.
  final bool atRisk;

  /// Son öğün eklenen gün (ISO 8601 — örn. "2026-05-01").
  final DateTime? lastActiveDay;

  /// Önemli rakama ulaştıysa ("3", "7", "14", "30", "60", "100"...).
  final String? milestone;

  bool get hasStreak => current > 0;

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      current: (json['current_streak'] ?? json['current'] ?? 0) as int,
      longest: (json['longest_streak'] ?? json['longest'] ?? 0) as int,
      todayLogged: (json['today_logged'] ?? false) as bool,
      atRisk: (json['at_risk'] ?? false) as bool,
      lastActiveDay: _tryParseDate(json['last_active_day']),
      milestone: json['milestone'] as String?,
    );
  }

  /// Boş/sıfır streak — ilk kez giriş yapan kullanıcılar için.
  static const empty = StreakInfo(
    current: 0,
    longest: 0,
    todayLogged: false,
    atRisk: false,
  );

  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

// ─── Repository ──────────────────────────────────────────────────────

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(apiClientProvider));
});

class StreakRepository {
  StreakRepository(this._dio);
  final Dio _dio;

  /// GET /streak — kullanıcının güncel streak verisi.
  Future<StreakInfo> getStreak() async {
    try {
      final response = await _dio.get('/streak');
      final data = response.data['data'] as Map<String, dynamic>;
      return StreakInfo.fromJson(data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

// ─── Provider ────────────────────────────────────────────────────────

/// Streak verileri her ekran açılışında refresh edilir (autoDispose).
/// Profil veya ana ekran ne zaman görünürse en güncel veri çekilir.
final streakProvider = FutureProvider.autoDispose<StreakInfo>((ref) async {
  return ref.watch(streakRepositoryProvider).getStreak();
});
