import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Öğün fotoğrafı çekme + optimizasyon.
///
/// OpenAI Vision token maliyeti image byte'ına bağlıdır. Büyük fotoğraf:
/// - Yavaş upload (3G/4G kullanıcısı için kötü UX)
/// - Yüksek API maliyeti
/// - Faydasız detay (yemek tanıma için 1024px yeter)
///
/// Bu sınıf 1024px max + quality 75 ile ~150-300KB base64 üretir.
class MealImageCapture {
  MealImageCapture._();

  static final _picker = ImagePicker();

  /// Kamera veya galeri için optimal parametreler.
  ///
  /// - maxWidth 1024: OpenAI Vision "low detail" mode için yeterli (512×512 tile)
  /// - imageQuality 75: görsel kaliteyi koruyan agresif JPEG sıkıştırma
  /// - preferredCameraDevice: rear (yemek fotoğrafı için)
  static const double _maxDim = 1024;
  static const int _jpegQuality = 75;

  /// True if app is running on iOS Simulator (which has no camera HW).
  /// Cached after first call so we don't keep checking.
  ///
  /// Detection: iOS Simulator sets the "SIMULATOR_DEVICE_NAME" env var.
  /// We can't read env from Dart at runtime, so we use a different signal:
  /// Platform.environment is empty on iOS Simulator AND on real iOS, but
  /// `Platform.operatingSystemVersion` on simulator contains "Simulator".
  static bool? _isSimulatorCache;
  static bool get isIosSimulator {
    if (_isSimulatorCache != null) return _isSimulatorCache!;
    if (!Platform.isIOS) {
      _isSimulatorCache = false;
      return false;
    }
    // On iOS Simulator the version string looks like:
    //   "Version 17.2 (Build 21C62)" — but really the give-away is that
    //   the device is an x86_64/arm64 simulator runtime. The simplest
    //   reliable signal exposed to Dart is Platform.environment, which
    //   is empty on real devices but contains SIMULATOR_* keys on sim.
    final env = Platform.environment;
    _isSimulatorCache = env.containsKey('SIMULATOR_DEVICE_NAME') ||
        env.containsKey('SIMULATOR_HOST_HOME');
    return _isSimulatorCache!;
  }

  /// Kameradan çek. Kullanıcı iptal ederse null.
  ///
  /// On iOS Simulator the camera tool is not available. Rather than letting
  /// image_picker throw "Camera not available." which surfaces as a system
  /// alert, we throw a typed CameraUnavailableException so the UI can show
  /// a friendly message and offer the gallery instead.
  static Future<String?> fromCamera() async {
    if (isIosSimulator) {
      throw const CameraUnavailableException(
        'Simulator\'de kamera yok. Galeri\'den seç.',
      );
    }
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxDim,
        maxHeight: _maxDim,
        imageQuality: _jpegQuality,
        preferredCameraDevice: CameraDevice.rear,
      );
      return x?.path;
    } on PlatformException catch (e) {
      // Real-device camera failure (denied permission, hw fault, etc).
      // Re-throw as our typed exception so the UI handles it uniformly.
      if (e.code == 'camera_access_denied') {
        throw const CameraUnavailableException(
          'Kamera izni verilmedi. Ayarlardan açabilirsin.',
        );
      }
      throw CameraUnavailableException(e.message ?? 'Kamera kullanılamıyor.');
    }
  }

  /// Galeriden seç.
  static Future<String?> fromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxDim,
      maxHeight: _maxDim,
      imageQuality: _jpegQuality,
    );
    return x?.path;
  }

  /// Dosyayı base64 string'e çevir (backend'e göndermek için).
  /// Dosya yoksa veya okunamıyorsa null döner.
  static Future<String?> toBase64(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Dosya boyutunu KB cinsinden döner (debug/log için).
  static Future<int> fileSizeKb(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return 0;
      final bytes = await file.length();
      return (bytes / 1024).round();
    } catch (_) {
      return 0;
    }
  }
}

/// Thrown when the camera can't be used: simulator, denied permission,
/// or hardware error. Carries a user-facing message in Turkish that the
/// UI can show directly in a snackbar.
class CameraUnavailableException implements Exception {
  const CameraUnavailableException(this.message);
  final String message;
  @override
  String toString() => 'CameraUnavailableException: $message';
}

