import 'package:flutter/material.dart';

import '../../core/network/app_error.dart';
import '../../core/theme/app_colors.dart';

/// Inline error UI rendered from an [AppError]. Every screen used to
/// hand-roll its own error block (icon + message + Retry button); this
/// is the single place to evolve that look.
///
/// Picks an icon + title based on the AppError subclass so a user
/// hitting a 404 doesn't see the same "cloud off" the network errors
/// use. Falls back to a generic "something went wrong" for [UnknownError].
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  /// The error to surface. Caller is responsible for putting only
  /// recoverable errors here — auth errors should redirect, not show
  /// inline retry.
  final AppError error;

  /// Optional retry callback. Most uses pass `() => ref.invalidate(provider)`.
  /// If null the Retry button is omitted.
  final VoidCallback? onRetry;

  /// Compact mode: smaller padding + icon, suitable for placing inline
  /// inside a list cell or card.
  final bool compact;

  IconData _iconFor(AppError e) => switch (e) {
        NetworkError() => Icons.wifi_off_outlined,
        ColdStartError() => Icons.cloud_outlined,
        AuthError() => Icons.lock_outline,
        ForbiddenError() => Icons.block_outlined,
        NotFoundError() => Icons.search_off_outlined,
        ValidationError() => Icons.warning_amber_outlined,
        LimitExceededError() => Icons.hourglass_bottom_outlined,
        ServerError() => Icons.cloud_off_outlined,
        UnknownError() => Icons.error_outline,
      };

  String _titleFor(AppError e) => switch (e) {
        NetworkError() => 'İnternet yok',
        ColdStartError() => 'Sunucu uyanıyor',
        AuthError() => 'Oturum gerekli',
        ForbiddenError() => 'Yetkin yok',
        NotFoundError() => 'Bulunamadı',
        ValidationError() => 'Bilgileri kontrol et',
        LimitExceededError() => 'Limit aşıldı',
        ServerError() => 'Sunucu hatası',
        UnknownError() => 'Bir şey ters gitti',
      };

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 28.0 : 40.0;
    final padding = compact
        ? const EdgeInsets.all(16)
        : const EdgeInsets.symmetric(horizontal: 28, vertical: 32);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconFor(error),
            color: AppColors.warning,
            size: iconSize,
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            _titleFor(error),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (error.userMessage.isNotEmpty) ...[
            SizedBox(height: compact ? 4 : 8),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: compact ? 12 : 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tekrar dene'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryCyan,
                side: BorderSide(
                  color: AppColors.primaryCyan.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
