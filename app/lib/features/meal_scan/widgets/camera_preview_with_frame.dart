import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import 'scan_frame_painter.dart';

/// Kamera preview'ı (veya çekilmiş fotoğrafı) gösterir + üstüne scan frame
/// overlay'i çizer. Aspect ratio 1:1 (square).
class CameraPreviewWithFrame extends StatelessWidget {
  final CameraController? controller;

  /// Sonuç görünümünde çekilen fotoğrafı göstermek için.
  final XFile? previewImage;

  const CameraPreviewWithFrame({
    super.key,
    this.controller,
    this.previewImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Alt katman: kamera veya çekilmiş fotoğraf
              _buildPreviewLayer(),

              // Hafif vignette (kamera viewfinder hissi)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.25),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Üst katman: scan frame overlay
              IgnorePointer(
                child: CustomPaint(
                  painter: const ScanFramePainter(),
                  size: Size.infinite,
                ),
              ),

              // Cyan border (yumuşak)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewLayer() {
    // Önce sonuç görünümü (çekilmiş foto)
    if (previewImage != null) {
      return Image.file(
        File(previewImage!.path),
        fit: BoxFit.cover,
      );
    }

    // Sonra canlı kamera
    final c = controller;
    if (c != null && c.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.previewSize?.height ?? 1,
          height: c.value.previewSize?.width ?? 1,
          child: CameraPreview(c),
        ),
      );
    }

    // Fallback: koyu yer tutucu
    return Container(
      color: const Color(0xFF0B1A3D),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryCyan,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
