import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Boş durum ekranı — ikon + başlık + açıklama + opsiyonel aksiyon butonu.
/// "Henüz öğün eklenmedi", "Hiç koç mesajı yok", vb. durumlar için.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Compact mode — kart içinde küçük empty state için.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 56.0;
    final padding = compact
        ? const EdgeInsets.all(20)
        : const EdgeInsets.symmetric(horizontal: 32, vertical: 40);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize + 20,
            height: iconSize + 20,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          Text(
            title,
            style: compact
                ? AppTextStyles.labelLarge
                : AppTextStyles.headingSmall,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: compact ? 4 : 8),
            Text(
              message!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: compact ? 12 : 20),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
