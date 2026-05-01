import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

class HomePayload {
  final String greeting;
  final DailySummary summary;
  final CoachCardData coachCard;
  final bool isEmptyDay;
  final UsageCounters usage;
  final String tier; // free | trial | premium

  const HomePayload({
    required this.greeting,
    required this.summary,
    required this.coachCard,
    required this.isEmptyDay,
    required this.usage,
    required this.tier,
  });

  factory HomePayload.fromJson(Map<String, dynamic> j) => HomePayload(
        greeting: j['greeting'] as String? ?? 'Merhaba',
        summary: DailySummary.fromJson(j['summary'] as Map<String, dynamic>? ?? {}),
        coachCard: CoachCardData.fromJson(j['coach_card'] as Map<String, dynamic>? ?? {}),
        isEmptyDay: j['is_empty_day'] as bool? ?? false,
        usage: UsageCounters.fromJson(j['usage'] as Map<String, dynamic>? ?? {}),
        tier: j['tier'] as String? ?? 'free',
      );
}

class DailySummary {
  final int totalCalories;
  final int targetCalories;
  final double proteinG;
  final double carbG;
  final double fatG;
  final int waterMl;
  final int mealCount;

  const DailySummary({
    required this.totalCalories,
    required this.targetCalories,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.waterMl,
    required this.mealCount,
  });

  factory DailySummary.fromJson(Map<String, dynamic> j) => DailySummary(
        totalCalories: (j['total_calories'] as num?)?.toInt() ?? 0,
        targetCalories: (j['target_calories'] as num?)?.toInt() ?? 2000,
        proteinG: (j['total_protein_g'] as num?)?.toDouble() ?? 0,
        carbG: (j['total_carb_g'] as num?)?.toDouble() ?? 0,
        fatG: (j['total_fat_g'] as num?)?.toDouble() ?? 0,
        waterMl: (j['water_ml'] as num?)?.toInt() ?? 0,
        mealCount: (j['meal_count'] as num?)?.toInt() ?? 0,
      );
}

class CoachCardData {
  final String message;
  final bool hasNewActivity;
  const CoachCardData({required this.message, this.hasNewActivity = false});

  factory CoachCardData.fromJson(Map<String, dynamic> j) => CoachCardData(
        message: j['message'] as String? ?? 'Bugün nasıl hissediyorsun?',
        hasNewActivity: j['has_new_activity'] as bool? ?? false,
      );
}

class UsageCounters {
  final int mealAnalyses;
  final int coachMessages;
  final int mealLimit;
  final int coachLimit;
  const UsageCounters({
    required this.mealAnalyses,
    required this.coachMessages,
    required this.mealLimit,
    required this.coachLimit,
  });

  factory UsageCounters.fromJson(Map<String, dynamic> j) => UsageCounters(
        mealAnalyses: (j['meal_analyses'] as num?)?.toInt() ?? 0,
        coachMessages: (j['coach_messages'] as num?)?.toInt() ?? 0,
        mealLimit: (j['meal_limit'] as num?)?.toInt() ?? 3,
        coachLimit: (j['coach_limit'] as num?)?.toInt() ?? 5,
      );
}

// ─── Repository ─────────────────────────────

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

class HomeRepository {
  HomeRepository(this._dio);
  final Dio _dio;

  Future<HomePayload> fetchHome() async {
    try {
      final resp = await _dio.get('/home');
      return HomePayload.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

// ─── Provider ─────────────────────────────

final homePayloadProvider = FutureProvider<HomePayload>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchHome();
});
