import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

/// Cold start (sunucu uyanıyor) state widget'ı.
/// Render free tier'da backend uyandıktan sonra 30-60sn sürebilir.
/// 5 saniye sonra otomatik retry tetikler, kullanıcı manuel de basabilir.
class ColdStartView extends StatefulWidget {
  const ColdStartView({
    super.key,
    required this.onRetry,
    this.title = 'Sunucu uyanıyor',
    this.message = 'Bir saniye, kahve almaya gitmiş gibi yapacağız...',
    this.retryLabel = 'Şimdi Tekrar Dene',
    this.autoRetryAfter = const Duration(seconds: 5),
  });

  final VoidCallback onRetry;
  final String title;
  final String message;
  final String retryLabel;
  final Duration autoRetryAfter;

  @override
  State<ColdStartView> createState() => _ColdStartViewState();
}

class _ColdStartViewState extends State<ColdStartView> {
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    // Otomatik retry — backend bu sırada uyanmış olur muhtemelen
    _retryTimer = Timer(widget.autoRetryAfter, () {
      if (mounted) widget.onRetry();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: widget.retryLabel,
              onPressed: () {
                _retryTimer?.cancel();
                widget.onRetry();
              },
              width: 200,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
