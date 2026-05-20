// ============================================================================
// onboarding_data.dart
// Onboarding'in 5 step'i boyunca toplanan tüm verinin tek modeli.
// - Immutable, copyWith pattern
// - JSON serialization (backend /me/onboarding endpoint'i için)
// - SharedPreferences persistence (uygulama kapanırsa kaldığı yerden devam)
// Hazırlık dosyası: nuveli_chat15_hazirlik.md → models/onboarding_data.dart
// ============================================================================

import 'dart:convert';

// ============================================================================
// ENUMS — Step 2, 3, 4'te kullanılır
// ============================================================================

enum Gender {
  male,
  female,
  other;

  String toJson() => name;
  static Gender? tryFromJson(Object? v) =>
      v == null ? null : Gender.values.firstWhere(
            (e) => e.name == v,
            orElse: () => Gender.other,
          );

  /// UI label
  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };
}

enum ActivityLevel {
  sedentary, // 1.2 — masa başı, az hareket
  light, // 1.375 — haftada 1-3 gün hafif egzersiz
  moderate, // 1.55 — haftada 3-5 gün orta tempo
  active, // 1.725 — haftada 6-7 gün
  veryActive; // 1.9 — günde 2 antrenman / fiziksel iş

  /// Backend wire value (snake_case for very_active).
  String toJson() => switch (this) {
        ActivityLevel.veryActive => 'very_active',
        _ => name,
      };

  /// Reverse of [toJson]. Accepts both wire form (e.g. 'very_active')
  /// and Dart name form ('veryActive') so cached/legacy payloads still
  /// parse.
  static ActivityLevel? tryFromJson(Object? v) {
    if (v == null) return null;
    return switch (v) {
      'very_active' || 'veryActive' => ActivityLevel.veryActive,
      'sedentary' => ActivityLevel.sedentary,
      'light' => ActivityLevel.light,
      'moderate' => ActivityLevel.moderate,
      'active' => ActivityLevel.active,
      _ => ActivityLevel.sedentary,
    };
  }

  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentary',
        ActivityLevel.light => 'Lightly active',
        ActivityLevel.moderate => 'Moderately active',
        ActivityLevel.active => 'Very active',
        ActivityLevel.veryActive => 'Extra active',
      };

  String get description => switch (this) {
        ActivityLevel.sedentary => 'Desk job, little or no exercise',
        ActivityLevel.light => 'Light exercise 1–3 days/week',
        ActivityLevel.moderate => 'Moderate exercise 3–5 days/week',
        ActivityLevel.active => 'Hard exercise 6–7 days/week',
        ActivityLevel.veryActive => 'Athlete or physical job',
      };

  double get multiplier => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.veryActive => 1.9,
      };
}

enum GoalType {
  loseWeight,
  maintain,
  gainWeight,
  buildMuscle;

  /// Backend wire value (matches WeightGoalDirection: lose | maintain | gain).
  /// buildMuscle maps to "gain" since it implies caloric surplus.
  String toJson() => switch (this) {
        GoalType.loseWeight => 'lose',
        GoalType.maintain => 'maintain',
        GoalType.gainWeight => 'gain',
        GoalType.buildMuscle => 'gain',
      };

  /// Reverse of [toJson]. Accepts both backend wire form (lose / gain
  /// / maintain) and the Dart enum names (loseWeight / gainWeight /
  /// buildMuscle). Backend has no notion of buildMuscle so it can only
  /// arrive from a locally persisted draft.
  static GoalType? tryFromJson(Object? v) {
    if (v == null) return null;
    return switch (v) {
      'lose' || 'loseWeight' || 'lose_weight' => GoalType.loseWeight,
      'gain' || 'gainWeight' || 'gain_weight' => GoalType.gainWeight,
      'buildMuscle' || 'build_muscle' => GoalType.buildMuscle,
      'maintain' => GoalType.maintain,
      _ => GoalType.maintain,
    };
  }

  String get label => switch (this) {
        GoalType.loseWeight => 'Lose weight',
        GoalType.maintain => 'Maintain weight',
        GoalType.gainWeight => 'Gain weight',
        GoalType.buildMuscle => 'Build muscle',
      };
}

// ============================================================================
// MODEL
// ============================================================================

class OnboardingData {
  // Step 2: Personal Info
  final String? displayName;
  final DateTime? dateOfBirth;
  final Gender? gender;

  // Step 3: Body Metrics
  final double? heightCm;
  final double? currentWeightKg;

  // Step 4: Goals
  final ActivityLevel? activityLevel;
  final GoalType? goalType;
  final double? targetWeightKg;
  final DateTime? targetDate;

  // Step 5: Calculated (Step 5'te hesaplanıp doldurulur)
  final int? dailyCalorieTarget;
  final int? dailyWaterMl;
  final int? proteinPercent; // default 25
  final int? carbsPercent; // default 45
  final int? fatPercent; // default 30

  const OnboardingData({
    this.displayName,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.activityLevel,
    this.goalType,
    this.targetWeightKg,
    this.targetDate,
    this.dailyCalorieTarget,
    this.dailyWaterMl,
    this.proteinPercent,
    this.carbsPercent,
    this.fatPercent,
  });

  // --------------------------------------------------------------------------
  // copyWith — her step kendi alanını günceller
  // --------------------------------------------------------------------------
  OnboardingData copyWith({
    String? displayName,
    DateTime? dateOfBirth,
    Gender? gender,
    double? heightCm,
    double? currentWeightKg,
    ActivityLevel? activityLevel,
    GoalType? goalType,
    double? targetWeightKg,
    DateTime? targetDate,
    int? dailyCalorieTarget,
    int? dailyWaterMl,
    int? proteinPercent,
    int? carbsPercent,
    int? fatPercent,
  }) =>
      OnboardingData(
        displayName: displayName ?? this.displayName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        currentWeightKg: currentWeightKg ?? this.currentWeightKg,
        activityLevel: activityLevel ?? this.activityLevel,
        goalType: goalType ?? this.goalType,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        targetDate: targetDate ?? this.targetDate,
        dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
        dailyWaterMl: dailyWaterMl ?? this.dailyWaterMl,
        proteinPercent: proteinPercent ?? this.proteinPercent,
        carbsPercent: carbsPercent ?? this.carbsPercent,
        fatPercent: fatPercent ?? this.fatPercent,
      );

  // --------------------------------------------------------------------------
  // Validation — Step 5'e geçmeden önce gerekli alanlar dolu mu?
  // --------------------------------------------------------------------------
  bool get isReadyForCalculation =>
      dateOfBirth != null &&
      gender != null &&
      heightCm != null &&
      currentWeightKg != null &&
      activityLevel != null &&
      goalType != null;

  /// Backend'e gönderebilir miyiz? (Step 5 dahil her şey doluysa)
  bool get isComplete =>
      isReadyForCalculation &&
      dailyCalorieTarget != null &&
      dailyWaterMl != null;

  // --------------------------------------------------------------------------
  // JSON — Backend `POST /me/onboarding` body'si
  // --------------------------------------------------------------------------
  /// Backend formatına serialize eder.
  /// Backend snake_case beklediği için key'leri buna göre yazıyoruz.
  Map<String, dynamic> toJson() => {
        if (displayName != null) 'full_name': displayName,
        if (dateOfBirth != null)
          'date_of_birth': _dateOnlyIso(dateOfBirth!),
        if (gender != null) 'sex': gender!.toJson(),
        if (heightCm != null) 'height_cm': heightCm,
        if (currentWeightKg != null) 'weight_kg': currentWeightKg,
        if (activityLevel != null) 'activity_level': activityLevel!.toJson(),
        if (goalType != null) 'weight_goal_direction': goalType!.toJson(),
        if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
        if (targetDate != null) 'target_date': _dateOnlyIso(targetDate!),
        if (dailyCalorieTarget != null)
          'daily_calorie_target': dailyCalorieTarget,
        if (dailyWaterMl != null) 'daily_water_ml': dailyWaterMl,
        if (proteinPercent != null) 'protein_percent': proteinPercent,
        if (carbsPercent != null) 'carbs_percent': carbsPercent,
        if (fatPercent != null) 'fat_percent': fatPercent,
      };

  factory OnboardingData.fromJson(Map<String, dynamic> json) => OnboardingData(
        displayName: json['display_name'] as String?,
        dateOfBirth: _parseDate(json['date_of_birth']),
        gender: Gender.tryFromJson(json['gender']),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
        activityLevel: ActivityLevel.tryFromJson(json['activity_level']),
        goalType: GoalType.tryFromJson(json['goal_type']),
        targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble(),
        targetDate: _parseDate(json['target_date']),
        dailyCalorieTarget: json['daily_calorie_target'] as int?,
        dailyWaterMl: json['daily_water_ml'] as int?,
        proteinPercent: json['protein_percent'] as int?,
        carbsPercent: json['carbs_percent'] as int?,
        fatPercent: json['fat_percent'] as int?,
      );

  /// SharedPreferences için string serialization
  String encode() => jsonEncode(toJson());
  static OnboardingData decode(String s) =>
      OnboardingData.fromJson(jsonDecode(s) as Map<String, dynamic>);

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------
  static String _dateOnlyIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDate(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v as String);
  }

  /// Yaş hesaplama
  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }
}
