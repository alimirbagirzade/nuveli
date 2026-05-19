import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_bottom_nav.dart';
import 'models/scan_result.dart';
import 'providers/meal_scan_provider.dart';
import 'widgets/analyze_another_button.dart';
import 'widgets/camera_preview_with_frame.dart';
import 'widgets/detected_food_list.dart';
import 'widgets/portion_insights_card.dart';
import 'widgets/scan_complete_banner.dart';
import 'widgets/scan_header.dart';

/// State makinesi:
///   initial   → kamera açık, capture butonu hazır
///   capturing → fotoğraf çekiliyor (kısa süreli)
///   analyzing → analiz devam ediyor (mock'ta 2 sn)
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
    // App background'a giderse kamerayı kapat, geri gelince yeniden aç
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
      // Arka kamera tercih (yemek fotoğrafı)
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
    } catch (e, st) {
      if (kDebugMode) debugPrint('Camera init error: $e\n$st');
      if (mounted) {
        setState(() {
          _cameraReady = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    try {
      final next = !_flashOn;
      await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _flashOn = next);
    } catch (_) {/* sessiz geç */}
  }

  Future<void> _captureAndAnalyze() async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) {
      // Kamera yoksa (örn. simulator) direkt mock analyze
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

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
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
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        bottomNavigationBar: NuveliBottomNav(
          currentIndex: 1, // Meals tab seçili
          onTap: (i) {
            // Chat 12 navigation'da bağlanacak
          },
        ),
      ),
    );
  }

  // ===================== CAMERA VIEW =====================

  Widget _buildCameraView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Stack(
            children: [
              CameraPreviewWithFrame(controller: _cameraController),
              if (_state == ScanState.analyzing)
                Positioned.fill(child: _buildAnalyzingOverlay()),
              if (_state == ScanState.error)
                Positioned.fill(child: _buildErrorOverlay()),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCaptureButton(),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              _captureHint(),
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
            color: AppColors.primaryCyan.withOpacity(busy ? 0.4 : 1.0),
            width: 3,
          ),
          boxShadow: busy
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryCyan,
                  AppColors.primaryCyan.withOpacity(0.7),
                ],
              ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
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
                color: AppColors.primaryCyan,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing meal...',
              style: TextStyle(
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.danger, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _resetToInitial,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryCyan,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          CameraPreviewWithFrame(previewImage: _capturedImage),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScanCompleteBanner(
                  foodsDetected: result.foods.length,
                  totalCalories: result.totalCalories,
                ),
                const SizedBox(height: AppSpacing.md),
                DetectedFoodList(foods: result.foods),
                const SizedBox(height: AppSpacing.md),
                PortionInsightsCard(insight: result.portionInsight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
