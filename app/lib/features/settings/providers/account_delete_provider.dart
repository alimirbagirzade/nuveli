import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/account_delete_service.dart';

/// Tracks the in-flight `DELETE /me` request state for the settings UI.
///
/// `AsyncValue.loading()` → spinner on confirm button
/// `AsyncValue.error(...)` → inline error message
/// `AsyncValue.data(null)`  → deletion finished; AuthGate will swap to welcome
class AccountDeleteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Idle state — nothing in flight until user taps confirm.
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountDeleteServiceProvider).deleteAccount();
    });
  }
}

final accountDeleteProvider =
    AsyncNotifierProvider<AccountDeleteNotifier, void>(
  AccountDeleteNotifier.new,
);
