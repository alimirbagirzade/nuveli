import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/data_export_service.dart';

/// Tracks the in-flight `GET /me/export` request state for the settings UI.
///
/// `AsyncValue.loading()` → spinner on the row
/// `AsyncValue.error(...)` → snack-bar with the error message
/// `AsyncValue.data(<file path>)` → quiet success; the share sheet has
/// already opened by the time we land here, so the path is mostly for
/// log/debug purposes.
class DataExportNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> exportData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(dataExportServiceProvider).exportToFile();
    });
  }
}

final dataExportProvider =
    AsyncNotifierProvider<DataExportNotifier, String?>(
  DataExportNotifier.new,
);
