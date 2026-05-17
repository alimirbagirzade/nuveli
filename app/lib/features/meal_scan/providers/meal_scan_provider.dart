import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_scan_result.dart';
import '../models/scan_result.dart';

/// Mock mode toggle. Chat 5a'da default `true`.
/// Chat 5b'de backend hazır olduğunda `--dart-define=MOCK=false` ile kapatılır.
const bool kMockMode = bool.fromEnvironment('MOCK', defaultValue: true);

/// Backend endpoint — Chat 5b'de aktif olacak.
const String _kScanEndpoint = 'https://nuveli-api.onrender.com/meals/scan';

/// Meal scan async state notifier.
///
/// State değerleri:
/// - `null`              → ekran henüz açıldı, sonuç yok
/// - `AsyncLoading`      → analiz devam ediyor (overlay göster)
/// - `AsyncData(result)` → analiz tamam
/// - `AsyncError`        → hata
class MealScanNotifier extends AsyncNotifier<ScanResult?> {
  @override
  Future<ScanResult?> build() async => null;

  /// Bir kamera fotoğrafını analiz et. Mock mode'da 2 saniye gecikme + sahte sonuç,
  /// real mode'da backend'e base64 image gönderir.
  Future<ScanResult> analyzeImage(XFile image) async {
    state = const AsyncValue.loading();

    try {
      if (kMockMode) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final result = buildMockScanResult();
        state = AsyncValue.data(result);
        return result;
      }

      // ============ Real mode (Chat 5b) ============
      // NOT: Bu blok Chat 5b'de Dio + Supabase auth ile değiştirilecek.
      // Şu an placeholder olarak HttpClient kullanıyoruz; gerçek
      // implementasyon Chat 5b'de gelir.
      final bytes = await image.readAsBytes();
      final base64 = base64Encode(bytes);

      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(_kScanEndpoint));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      // Auth header burada eklenecek (Supabase session JWT) — Chat 5b
      request.add(utf8.encode(jsonEncode({'image_base64': base64})));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('Scan failed: ${response.statusCode} — $body');
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final result = ScanResult.fromJson(json);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('MealScan error: $e');
      }
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Sonucu temizle ve initial state'e dön ("Analyze Another Meal" için).
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final mealScanProvider =
    AsyncNotifierProvider<MealScanNotifier, ScanResult?>(MealScanNotifier.new);
