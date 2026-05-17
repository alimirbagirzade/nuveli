import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/features/analytics/data/mock_analytics_data.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';

/// Analytics ekranı veri provider'ı.
///
/// Şimdilik mock data döndürüyor (600ms gecikme ile loading state simüle ediliyor).
/// Chat 14/15'te gerçek backend bağlanacak.
final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return mockAnalyticsData;
});
