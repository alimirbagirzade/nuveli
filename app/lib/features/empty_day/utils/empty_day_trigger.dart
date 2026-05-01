// app/lib/features/empty_day/utils/empty_day_trigger.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nuveli/core/network/api_client.dart';

class EmptyDayTrigger {
  static bool _shownThisSession = false;

  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (_shownThisSession) return;

    final dio = ref.read(apiClientProvider);

    bool shouldShow = false;
    try {
      final res = await dio.get('/checkins/empty-day-status');
      shouldShow = (res.data?['should_show_screen'] as bool?) ?? false;
    } catch (e) {
      debugPrint('EmptyDayTrigger: status check failed: $e');
      return;
    }

    if (!shouldShow) return;
    if (!context.mounted) return;

    _shownThisSession = true;

    await Future.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;

    context.push('/empty-day');
  }

  static void resetForTesting() {
    _shownThisSession = false;
  }
}
