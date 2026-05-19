// lib/features/meal_scan/providers/meal_scan_provider.dart
//
// Chat 5b güncellemesi: real-mode artık gerçek backend'e Dio ile gidiyor.
// Mock mode hâlâ çalışır — --dart-define=MOCK=true ile aç.
//
// Build flags:
//   MOCK=true               → mock fixture döner (Chat 5a davranışı, offline)
//   MOCK=false (default)    → POST nuveli-api/meals/scan
//   API_BASE_URL=...        → backend URL override (staging vs prod)
//
// Çalıştırma:
//   flutter run --dart-define=MOCK=false              (gerçek API, prod URL)
//   flutter run --dart-define=MOCK=true               (offline UI testi)
//   flutter run --dart-define=API_BASE_URL=http://localhost:8000  (lokal backend)

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/mock_scan_result.dart';
import '../models/detected_food.dart';
import '../models/portion_insight.dart';
import '../models/scan_result.dart';

// ---------------------------------------------------------------------------
// Build-time flags
// ---------------------------------------------------------------------------
const bool kMockMode = bool.fromEnvironment('MOCK', defaultValue: false);

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://nuveli-api.onrender.com',
);

// ---------------------------------------------------------------------------
// Dio singleton — Vision sometimes takes 5-20s, so timeouts are generous.
// ---------------------------------------------------------------------------
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kApiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 45),
    headers: {'Content-Type': 'application/json'},
  ));
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: false, // base64 too long to log
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }
  return dio;
});

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final mealScanProvider =
    AsyncNotifierProvider<MealScanNotifier, ScanResult?>(MealScanNotifier.new);

class MealScanNotifier extends AsyncNotifier<ScanResult?> {
  @override
  Future<ScanResult?> build() async => null;
  void reset() {
    state = const AsyncValue.data(null);
  }

  Future<ScanResult> analyzeImage(XFile image) async {
    state = const AsyncValue.loading();

    try {
      final ScanResult result =
          kMockMode ? await _analyzeMock() : await _analyzeReal(image);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ─── Mock path (Chat 5a behaviour) ───────────────────────────────────────
  Future<ScanResult> _analyzeMock() async {
    await Future.delayed(const Duration(seconds: 2));
    return buildMockScanResult();
  }

  // ─── Real path (Chat 5b) ─────────────────────────────────────────────────
  Future<ScanResult> _analyzeReal(XFile image) async {
    // 1. Auth
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw const MealScanException(
        'You need to be signed in to scan meals.',
        code: 'unauthenticated',
      );
    }

    // 2. Read + size guard (backend also enforces, but fail fast saves bandwidth)
    final bytes = await File(image.path).readAsBytes();
    if (bytes.length > 4 * 1024 * 1024) {
      throw const MealScanException(
        'Photo is too large. Try a different angle or lower resolution.',
        code: 'image_too_large',
      );
    }
    final imageB64 = base64Encode(bytes);

    // 3. POST
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/meals/scan',
        data: {'image_base64': imageB64},
        options: Options(
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const MealScanException('Empty response from server.');
      }
      return _parseResponse(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ─── Response parsing ────────────────────────────────────────────────────
  ScanResult _parseResponse(Map<String, dynamic> data) {
    final foodsJson =
        (data['foods'] as List? ?? const []).cast<Map<String, dynamic>>();

    final insightJson =
        data['portion_insight'] as Map<String, dynamic>? ?? const {};

    return ScanResult(
      foods: foodsJson
          .map((f) => DetectedFood(
                name: f['name'] as String,
                portion: f['portion'] as String,
                calories: (f['calories'] as num).toInt(),
                proteinG: (f['protein_g'] as num).toDouble(),
                carbsG: (f['carbs_g'] as num).toDouble(),
                fatG: (f['fat_g'] as num).toDouble(),
                // Backend doesn't send icons — pick one locally by food name.
                icon: _iconForFood(f['name'] as String),
              ))
          .toList(),
      totalCalories: (data['total_calories'] as num).toInt(),
      portionInsight: PortionInsight(
        score: (insightJson['score'] as num).toInt(),
        mainText: insightJson['main_text'] as String,
        highlights: (insightJson['highlights'] as List? ?? const [])
            .map((h) => h.toString())
            .toList(),
      ),
      scannedAt: DateTime.now(),
      // Server-assigned id, used later to navigate to /meals/:id.
      // ScanResult model'inde `mealId` alanı yoksa ekle (nullable string).
    );
  }

  // ─── Error mapping — Dio → MealScanException ─────────────────────────────
  MealScanException _mapDioError(DioException e) {
    // Connection / timeout (no response from server).
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const MealScanException(
        'The scan took too long. Check your connection and try again.',
        code: 'timeout',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const MealScanException(
        'Cannot reach the Nuveli server. Check your connection.',
        code: 'offline',
      );
    }

    // Server returned an error response.
    final status = e.response?.statusCode;
    final detail = _extractDetail(e.response?.data);

    switch (status) {
      case 400:
        return MealScanException(
          detail ?? 'Couldn’t read the photo. Try another angle.',
          code: 'bad_image',
        );
      case 401:
        return const MealScanException(
          'Your session expired. Please sign in again.',
          code: 'unauthorized',
        );
      case 422:
        return MealScanException(
          detail ?? 'The image didn’t meet our requirements.',
          code: 'validation',
        );
      case 429:
        return const MealScanException(
          'Too many scans right now. Wait a moment and try again.',
          code: 'rate_limited',
        );
      case 504:
        return const MealScanException(
          'The AI took too long. Try again.',
          code: 'timeout',
        );
      case 502:
      case 503:
        return const MealScanException(
          'The AI service is unavailable. Please retry shortly.',
          code: 'upstream',
        );
      default:
        return MealScanException(
          detail ?? 'Scan failed. Please try again.',
          code: 'unknown',
        );
    }
  }

  String? _extractDetail(dynamic body) {
    if (body is Map<String, dynamic>) {
      final d = body['detail'];
      if (d is String) return d;
      if (d is List && d.isNotEmpty) return d.first.toString();
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Custom exception so the UI can show friendly messages per error code.
// ---------------------------------------------------------------------------
class MealScanException implements Exception {
  final String message;
  final String code;
  const MealScanException(this.message, {this.code = 'unknown'});

  @override
  String toString() => 'MealScanException($code): $message';
}

// ---------------------------------------------------------------------------
// Heuristic icon picker. Backend stays icon-agnostic.
// Replace with a proper icon mapping or remove if not needed.
// ---------------------------------------------------------------------------
IconData _iconForFood(String name) {
  final n = name.toLowerCase();
  if (n.contains('chicken') ||
      n.contains('beef') ||
      n.contains('pork') ||
      n.contains('lamb') ||
      n.contains('turkey') ||
      n.contains('fish') ||
      n.contains('salmon') ||
      n.contains('tuna')) {
    return Icons.set_meal;
  }
  if (n.contains('rice') ||
      n.contains('quinoa') ||
      n.contains('pasta') ||
      n.contains('bread') ||
      n.contains('oat')) {
    return Icons.grain;
  }
  if (n.contains('vegetable') ||
      n.contains('salad') ||
      n.contains('broccoli') ||
      n.contains('spinach') ||
      n.contains('greens')) {
    return Icons.eco;
  }
  if (n.contains('fruit') ||
      n.contains('apple') ||
      n.contains('banana') ||
      n.contains('berry')) {
    return Icons.local_florist;
  }
  return Icons.restaurant;
}
