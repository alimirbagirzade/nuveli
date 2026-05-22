import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/weekly_analytics.dart';
import '../models/weight_trend.dart';

/// `GET /analytics/weekly` → last 7 days calorie bars + avg macros.
final weeklyAnalyticsProvider = FutureProvider<WeeklyAnalytics>((ref) async {
  final dio = ref.read(apiClientProvider).raw;
  final res = await dio.get<Map<String, dynamic>>('/analytics/weekly');
  return WeeklyAnalytics.fromJson(res.data ?? const {});
});

/// `GET /analytics/weight-trend?period=8w` → daily weight samples +
/// 7-day moving average. Period defaults match the backend default
/// so users see a reasonable window the first time the screen opens.
final weightTrendProvider = FutureProvider.family<WeightTrend, String>(
  (ref, period) async {
    final dio = ref.read(apiClientProvider).raw;
    final res = await dio.get<Map<String, dynamic>>(
      '/analytics/weight-trend',
      queryParameters: {'period': period},
    );
    return WeightTrend.fromJson(res.data ?? const {});
  },
);

/// Default 8-week window used by the analytics screen.
final weightTrend8wProvider = FutureProvider<WeightTrend>(
  (ref) => ref.watch(weightTrendProvider('8w').future),
);
