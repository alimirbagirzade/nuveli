import 'dart:convert';
import 'dart:io';

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

  /// Kameradan çek. Kullanıcı iptal ederse null.
  static Future<String?> fromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxDim,
      maxHeight: _maxDim,
      imageQuality: _jpegQuality,
      preferredCameraDevice: CameraDevice.rear,
    );
    return x?.path;
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
