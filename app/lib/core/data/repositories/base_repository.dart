import 'package:flutter/foundation.dart';

import '../../network/api_client.dart';

/// Common ancestor for every repository in the app.
///
/// Keeps each concrete repository thin by hosting the small set of
/// formatting / parsing helpers we need on every call:
///
///   - `formatDateOnly`     → `YYYY-MM-DD` for query parameters
///   - `formatDateTimeUtc`  → ISO 8601 UTC for request bodies
///
/// The backend persists every timestamp in UTC; the Flutter layer
/// renders in the device's local timezone. All outgoing values must
/// be converted to UTC here, and all incoming `DateTime` values
/// should be `.toLocal()`-ised inside the relevant model's
/// `fromJson` (NOT here — keeps repositories framework-agnostic).
abstract class BaseRepository {
  BaseRepository(this.apiClient);

  @protected
  final ApiClient apiClient;

  /// Formats a [DateTime] as a backend-friendly date-only string
  /// (`YYYY-MM-DD`). Always interprets `date` as a calendar day in
  /// the device's local timezone — i.e. "today" for the user.
  @protected
  String formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Converts a local [DateTime] to ISO 8601 UTC for JSON request
  /// bodies (e.g. `"2026-05-19T17:42:00.000Z"`).
  @protected
  String formatDateTimeUtc(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Convenience: today's date in local TZ as `YYYY-MM-DD`.
  @protected
  String today() => formatDateOnly(DateTime.now());
}
