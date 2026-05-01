// app/lib/features/empty_day/utils/empty_day_trigger.dart
//
// Empty Day Trigger.
// PRD §6.4 — Kullanıcı 24 saat hiç meal log'lamamışsa, home'a girince
// hafif bir "buradayız, baskı yok" ekranına yönlendir.
//
// Çağrı yeri: home_screen.dart initState postFrameCallback.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nuveli/core/network/api_client.dart';

class EmptyDayTrigger {
  // Aynı session'da iki kez tetiklememek
  static bool _shownThisSession = false;

  /// Home init'de çağır.
  /// Backend'den /checkins/empty-day-status sorar, gerekirse route'lar.
  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (_shownThisSession) return;

    final api = ref.read(apiClientProvider);

    bool shouldShow = false;
    try {
      final res = await api.get('/checkins/empty-day-status');
      shouldShow = (res.data?['should_show_screen'] as bool?) ?? false;
    } catch (e) {
      // Sessizce devam — endpoint hata verirse rahatsız etme
      debugPrint('EmptyDayTrigger: status check failed: $e');
      return;
    }

    if (!shouldShow) return;
    if (!context.mounted) return;

    _shownThisSession = true;

    // Akışı bozmamak için kısa gecikme
    await Future.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;

    // Empty day screen'in route'u; uygulamanın router config'inde tanımlı olmalı
    context.push('/empty-day');
  }

  /// Test/debug için.
  static void resetForTesting() {
    _shownThisSession = false;
  }
}
