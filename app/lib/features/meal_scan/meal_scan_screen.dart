import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

import 'models/scan_result.dart';
import 'providers/meal_scan_provider.dart';
import 'widgets/analyze_another_button.dart';
import 'widgets/camera_preview_with_frame.dart';
import 'widgets/detected_food_list.dart';
import 'widgets/portion_insights_card.dart';
import 'widgets/scan_complete_banner.dart';
import 'widgets/scan_header.dart';

/// Görsel 2 - AI Meal Scan ekranı.
///
/// State makinesi:
///   initial   → kamera açık, capture butonu hazır
///   capturing → fotoğraf çekiliyor (çok kısa)
///   analyzing → analiz devam ediyor (mock: 2 sn, real: backend cevabı)
///   result    → sonuç gösteriliyor
///   error     → hata mesajı + retry
enum ScanState { initial, capturing, analyzing, result, error }

class MealScanScreen extends ConsumerStatefulWidget {
  const MealScanScreen({super.key});

  @override
  ConsumerState<MealScanScreen> createState() => _MealScanScreenState();
}

class _MealScanScreenState extends ConsumerState<MealScanScreen>
    with WidgetsBindingObserver {
  ScanState _state = ScanState.initial;
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _flashOn = false;
  XFile? _capturedImage;
  ScanResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (kDebugMode) debugPrint('No cameras available');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Camera init error: $e');
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  Future<void> _toggleFlash() async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    try {
      final next = !_flashOn;
      await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _flashOn = next);
    } catch (_) {/* ignore */}
  }

  Future<void> _captureAndAnalyze() async {
    final c = _cameraController;

    // Simulator / no camera fallback
    if (c == null || !c.value.isInitialized) {
      setState(() => _state = ScanState.analyzing);
      try {
        final result =
            await ref.read(mealScanProvider.notifier).analyzeImage(XFile(''));
        if (!mounted) return;
        setState(() {
          _result = result;
          _state = ScanState.result;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString();
          _state = ScanState.error;
        });
      }
      return;
    }

    setState(() => _state = ScanState.capturing);
    try {
      final image = await c.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedImage = image;
        _state = ScanState.analyzing;
      });

      final result = await ref.read(mealScanProvider.notifier).analyzeImage(image);
      if (!mounted) return;
      setState(() {
        _result = result;
        _state = ScanState.result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _state = ScanState.error;
      });
    }
  }

  void _resetToInitial() {
    setState(() {
      _state = ScanState.initial;
      _capturedImage = null;
      _result = null;
      _errorMessage = null;
    });
    ref.read(mealScanProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final showingResult = _state == ScanState.result;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.gradientHero),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScanHeader(
                onClose: () => Navigator.of(context).maybePop(),
                onFlashToggle: showingResult ? null : _toggleFlash,
                flashOn: _flashOn,
              ),
              Expanded(
                child: showingResult ? _buildResultView() : _buildCameraView(),
              ),
              if (showingResult) ...[
                AnalyzeAnotherButton(onPressed: _resetToInitial),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== CAMERA VIEW =====================

  Widget _buildCameraView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              CameraPreviewWithFrame(controller: _cameraController),
              if (_state == ScanState.analyzing)
                Positioned.fill(child: _buildAnalyzingOverlay()),
              if (_state == ScanState.error)
                Positioned.fill(child: _buildErrorOverlay()),
            ],
          ),
          const SizedBox(height: 24),
          _buildCaptureButton(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _captureHint(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _captureHint() {
    switch (_state) {
      case ScanState.capturing:
        return 'Capturing...';
      case ScanState.analyzing:
        return 'Analyzing your meal with AI...';
      case ScanState.error:
        return 'Tap to try again';
      case ScanState.initial:
      case ScanState.result:
        return _cameraReady
            ? 'Center your meal in the frame and tap to scan'
            : 'Tap to analyze (camera unavailable — using demo)';
    }
  }

  Widget _buildCaptureButton() {
    final busy =
        _state == ScanState.capturing || _state == ScanState.analyzing;
    return GestureDetector(
      onTap: busy ? null : _captureAndAnalyze,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: busy ? 0.4 : 1.0),
            width: 3,
          ),
          boxShadow: busy
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientCta,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing meal...',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _resetToInitial,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== RESULT VIEW =====================

  Widget _buildResultView() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          CameraPreviewWithFrame(previewImage: _capturedImage),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScanCompleteBanner(
                  foodsDetected: result.foods.length,
                  totalCalories: result.totalCalories,
                ),
                const SizedBox(height: 16),
                DetectedFoodList(foods: result.foods),
                const SizedBox(height: 16),
                PortionInsightsCard(insight: result.portionInsight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
