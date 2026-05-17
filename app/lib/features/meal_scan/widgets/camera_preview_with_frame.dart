import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

import 'scan_frame_painter.dart';

/// Square (1:1) kamera preview + scan frame overlay.
/// Result mode'da çekilmiş fotoğrafı gösterir.
class CameraPreviewWithFrame extends StatelessWidget {
  final CameraController? controller;
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
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPreviewLayer(),
              // Hafif vignette
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.25),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Scan frame
              const IgnorePointer(
                child: CustomPaint(
                  painter: ScanFramePainter(),
                  size: Size.infinite,
                ),
              ),
              // Cyan border
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
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
    if (previewImage != null) {
      return Image.file(File(previewImage!.path), fit: BoxFit.cover);
    }

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

    return const ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
