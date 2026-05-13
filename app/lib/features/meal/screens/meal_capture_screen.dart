import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monitoring/analytics_service.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/meal_image_capture.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/meal_repository.dart';
import '../providers/meal_providers.dart';
import '../../../l10n/generated/app_localizations.dart';

class MealCaptureScreen extends ConsumerStatefulWidget {
  const MealCaptureScreen({super.key});
  @override
  ConsumerState<MealCaptureScreen> createState() => _MealCaptureScreenState();
}

class _MealCaptureScreenState extends ConsumerState<MealCaptureScreen> {
  final _descCtrl = TextEditingController();
  String? _imagePath;
  bool _analyzing = false;

  Future<void> _pickFromCamera() async {
    AnalyticsService.mealCaptureStarted(source: 'camera');
    try {
      final path = await MealImageCapture.fromCamera();
      if (path != null) {
        setState(() => _imagePath = path);
        // Breadcrumb: file size log'u (crash olursa büyük dosya şüphesi için)
        final sizeKb = await MealImageCapture.fileSizeKb(path);
        CrashReporter.log('meal_image_captured: ${sizeKb}KB (camera)');
      }
    } on CameraUnavailableException {
      // Simulator'de kamera yok ya da gerçek cihazda izin verilmedi.
      // Hata göster ve tek dokunuşta galeriye yönlendir.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mealCameraNotAvailable),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.mealGallery,
            onPressed: _pickFromGallery,
          ),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    AnalyticsService.mealCaptureStarted(source: 'gallery');
    final path = await MealImageCapture.fromGallery();
    if (path != null) {
      setState(() => _imagePath = path);
      final sizeKb = await MealImageCapture.fileSizeKb(path);
      CrashReporter.log('meal_image_captured: ${sizeKb}KB (gallery)');
    }
  }

  Future<String?> _readAsBase64(String path) => MealImageCapture.toBase64(path);

  Future<void> _analyze() async {
    if (_imagePath == null && _descCtrl.text.trim().isEmpty) return;

    setState(() => _analyzing = true);
    try {
      String? imageB64;
      if (_imagePath != null) {
        imageB64 = await _readAsBase64(_imagePath!);
      }

      final result = await ref.read(mealRepositoryProvider).analyze(
            imageB64: imageB64,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          );

      // Analytics: AI sonucu confidence ile track et
      AnalyticsService.mealAnalyzed(confidence: result.confidence);

      if (!mounted) return;

      // AI başarısız olduysa /meal/result ekranını atla, direkt manuel'e geç.
      // AMA: AI bir öneri döndürdüyse (suggestedName var), result ekranını göster
      // — kullanıcı 'pilav' yazdı, AI tahmin etti, görsün.
      final hasAnySuggestion = result.suggestedName != null ||
          result.suggestedCalories != null;

      if (result.confidence == 'failed' && !hasAnySuggestion) {
        context.pushReplacement(AppRoute.mealManual);
        return;
      }

      // Result'ı provider'a koy (route extra GoRouter codec uyarısı veriyordu)
      ref.read(currentMealAnalysisProvider.notifier).state = result;
      context.pushReplacement(AppRoute.mealResult);
    } catch (e, stack) {
      if (!mounted) return;
      // Günlük analiz limiti aşılmış → paywall'u göster, premium'a yönlendir
      if (e is LimitExceededError) {
        await _showLimitDialog(e.userMessage);
        return;
      }
      // Beklenmeyen hatalar Crashlytics'e — network/expected error'lar değil
      if (e is! AppError) {
        CrashReporter.report(
          e,
          stack,
          feature: 'meal',
          action: 'analyze',
          context: {'has_description': _descCtrl.text.isNotEmpty},
        );
      }
      final msg = e is AppError ? e.userMessage : AppLocalizations.of(context)!.mealAnalyzeFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  /// Free tier günlük limiti aşılınca paywall modali göster.
  Future<void> _showLimitDialog(String reason) async {
    // Analytics: limit dolmasını track et
    AnalyticsService.limitReached(feature: 'meal_analysis');

    final goToPaywall = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_outline,
            size: 48, color: AppColors.primary),
        title: Text(AppLocalizations.of(context)!.mealLimitTitle),
        content: Text(
          '$reason\n\nPremium ile sınırsız fotoğraf analizi yapabilirsin.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Sonra'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Premium\'a bak'),
          ),
        ],
      ),
    );

    if (goToPaywall == true && mounted) {
      AnalyticsService.paywallShown(source: 'meal_limit');
      context.push(AppRoute.paywall);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.mealAddTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.mealPhotoOrDesc, style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            _ImageArea(imagePath: _imagePath),
            const SizedBox(height: 12),
            // Simulator'de kamera çalışmaz — bunu önceden bildir.
            if (MealImageCapture.isIosSimulator) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.mealSimulatorWarn,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(AppLocalizations.of(context)!.mealCamera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(AppLocalizations.of(context)!.mealGalleryBtn),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.mealDescHint,
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: AppLocalizations.of(context)!.mealAnalyze,
              isLoading: _analyzing,
              onPressed: _analyze,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.push(AppRoute.mealManual),
                child: Text(AppLocalizations.of(context)!.mealManualEntry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({this.imagePath});
  final String? imagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: imagePath == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.mealNoPhoto,
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity),
            ),
    );
  }
}
