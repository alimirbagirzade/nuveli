// ============================================================================
// profile_service.dart
// Backend (Render) ile profil iletişimi.
// - GET  /me            → current user profile
// - POST /me/onboarding → onboarding tamamla
// - PATCH /me           → profile update
//
// Dio'yu kullanır. Token Supabase session'ından otomatik alınır.
// Backend yoksa (Chat 14 deploy edilmemişse) hata UI'a anlamlı yansır.
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../models/onboarding_data.dart';

// ============================================================================
// USER PROFILE MODEL — /me endpoint response
// ============================================================================

class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final ActivityLevel? activityLevel;
  final GoalType? goalType;
  final double? targetWeightKg;
  final int? dailyCalorieTarget;
  final int? dailyWaterMl;
  final int? proteinPercent;
  final int? carbsPercent;
  final int? fatPercent;
  final bool onboardingCompleted;
  final bool isPremium;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.onboardingCompleted,
    required this.createdAt,
    this.displayName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.activityLevel,
    this.goalType,
    this.targetWeightKg,
    this.dailyCalorieTarget,
    this.dailyWaterMl,
    this.proteinPercent,
    this.carbsPercent,
    this.fatPercent,
    this.isPremium = false,
  });

  /// Backend payload reader.
  ///
  /// Chat 22 aligned the API to: `full_name`, `sex`, `weight_kg`,
  /// `weight_goal_direction` (lose/maintain/gain), `daily_water_target_ml`,
  /// `protein_target_g`/`carbs_target_g`/`fat_target_g` etc.
  ///
  /// Legacy keys (`display_name`, `gender`, `current_weight_kg`,
  /// `goal_type`, `daily_water_ml`, `protein_percent`/`carbs_percent`/
  /// `fat_percent`) are read as fallbacks so any cached/persisted
  /// payloads or older endpoints still parse.
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName:
            (json['full_name'] ?? json['display_name']) as String?,
        email: json['email'] as String?,
        dateOfBirth: _parseDate(json['date_of_birth']),
        gender: Gender.tryFromJson(json['sex'] ?? json['gender']),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        currentWeightKg:
            ((json['weight_kg'] ?? json['current_weight_kg']) as num?)
                ?.toDouble(),
        activityLevel:
            ActivityLevel.tryFromJson(json['activity_level']),
        goalType: GoalType.tryFromJson(
          json['weight_goal_direction'] ?? json['goal_type'],
        ),
        targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble(),
        dailyCalorieTarget: json['daily_calorie_target'] as int?,
        dailyWaterMl:
            (json['daily_water_target_ml'] ?? json['daily_water_ml']) as int?,
        // Macro keys: prefer new gram-based keys; if absent, fall back
        // to legacy percent keys (different semantics but stored on the
        // same field today — model refactor to split them is a follow-up).
        proteinPercent: _macroNumToInt(
          json['protein_target_g'] ?? json['protein_percent'],
        ),
        carbsPercent: _macroNumToInt(
          json['carbs_target_g'] ?? json['carbs_percent'],
        ),
        fatPercent: _macroNumToInt(
          json['fat_target_g'] ?? json['fat_percent'],
        ),
        onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
        isPremium: json['is_premium'] as bool? ?? false,
        createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      );

  static int? _macroNumToInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return null;
  }

  static DateTime? _parseDate(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v as String);
  }
}

// ============================================================================
// PROFILE SERVICE
// ============================================================================

class ProfileService {
  final Dio _dio;
  final SupabaseClient _supabase;

  ProfileService({Dio? dio, SupabaseClient? client})
      : _dio = dio ?? _buildDio(),
        _supabase = client ?? Supabase.instance.client;

  static Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (msg) => debugPrint('[ProfileService] $msg'),
      ));
    }
    return dio;
  }

  String _token() {
    final t = _supabase.auth.currentSession?.accessToken;
    if (t == null) {
      throw const _NotAuthenticatedException();
    }
    return t;
  }

  Options _authedOptions() =>
      Options(headers: {'Authorization': 'Bearer ${_token()}'});

  // --------------------------------------------------------------------------
  // GET /me — Mevcut profili getir
  // --------------------------------------------------------------------------
  Future<UserProfile> getCurrentProfile() async {
    try {
      final response = await _dio.get('/me', options: _authedOptions());
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _normalizeDioError(e, 'Could not load profile.');
    }
  }

  // --------------------------------------------------------------------------
  // POST /me/onboarding — Onboarding'i tamamla
  // --------------------------------------------------------------------------
  Future<UserProfile> completeOnboarding(OnboardingData data) async {
    try {
      final response = await _dio.post(
        '/me/onboarding',
        data: data.toJson(),
        options: _authedOptions(),
      );
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _normalizeDioError(e, 'Could not save your profile.');
    }
  }

  // --------------------------------------------------------------------------
  // PATCH /me — Profili güncelle (Chat 16'da kullanılır)
  // --------------------------------------------------------------------------
  Future<UserProfile> updateProfile(Map<String, dynamic> patch) async {
    try {
      final response = await _dio.patch(
        '/me',
        data: patch,
        options: _authedOptions(),
      );
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _normalizeDioError(e, 'Could not update profile.');
    }
  }

  // --------------------------------------------------------------------------
  // Error normalization
  // --------------------------------------------------------------------------
  ProfileServiceException _normalizeDioError(
    DioException e,
    String fallback,
  ) {
    final code = e.response?.statusCode;
    final body = e.response?.data;

    String message = fallback;
    if (body is Map && body['detail'] is String) {
      message = body['detail'] as String;
    } else if (body is Map && body['message'] is String) {
      message = body['message'] as String;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      message =
          'Could not reach the server. Check your connection and try again.';
    }

    return ProfileServiceException(
      message: message,
      statusCode: code,
      originalError: e,
    );
  }
}

// ============================================================================
// EXCEPTIONS
// ============================================================================

class ProfileServiceException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalError;

  const ProfileServiceException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'ProfileServiceException($statusCode): $message';
}

class _NotAuthenticatedException implements Exception {
  const _NotAuthenticatedException();
  @override
  String toString() => 'Not authenticated';
}
