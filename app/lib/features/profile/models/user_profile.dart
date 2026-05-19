/// User profile model — mirrors backend `GET /me` response.
///
/// Backend endpoint: https://nuveli-api.onrender.com/me
class UserProfile {
  final String id;
  final String userId;
  final String? fullName;
  final String email;
  final String? sex; // "male" | "female" | "other"
  final DateTime? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel; // "sedentary" | "light" | "moderate" | "active" | "very_active"
  final String? dietaryPreference;

  // Calculated targets
  final int dailyCalorieTarget;
  final int dailyWaterTargetMl;
  final int proteinTargetG;
  final int carbsTargetG;
  final int fatTargetG;

  // BMR/TDEE (server-calculated)
  final int? bmr;
  final int? tdee;

  // Flags
  final bool isPremium;
  final bool onboardingCompleted;

  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.sex,
    required this.dateOfBirth,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.dietaryPreference,
    required this.dailyCalorieTarget,
    required this.dailyWaterTargetMl,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
    required this.bmr,
    required this.tdee,
    required this.isPremium,
    required this.onboardingCompleted,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String? ?? '',
      sex: json['sex'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      activityLevel: json['activity_level'] as String?,
      dietaryPreference: json['dietary_preference'] as String?,
      dailyCalorieTarget: (json['daily_calorie_target'] as num?)?.toInt() ?? 2000,
      dailyWaterTargetMl: (json['daily_water_target_ml'] as num?)?.toInt() ?? 2500,
      proteinTargetG: (json['protein_target_g'] as num?)?.toInt() ?? 0,
      carbsTargetG: (json['carbs_target_g'] as num?)?.toInt() ?? 0,
      fatTargetG: (json['fat_target_g'] as num?)?.toInt() ?? 0,
      bmr: (json['bmr'] as num?)?.toInt(),
      tdee: (json['tdee'] as num?)?.toInt(),
      isPremium: json['is_premium'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'sex': sex,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'activity_level': activityLevel,
        'dietary_preference': dietaryPreference,
        'daily_calorie_target': dailyCalorieTarget,
        'daily_water_target_ml': dailyWaterTargetMl,
        'protein_target_g': proteinTargetG,
        'carbs_target_g': carbsTargetG,
        'fat_target_g': fatTargetG,
        'bmr': bmr,
        'tdee': tdee,
        'is_premium': isPremium,
        'onboarding_completed': onboardingCompleted,
        'created_at': createdAt.toIso8601String(),
      };

  /// Years between now and date_of_birth. Returns null if DOB missing.
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  /// Displayable name with fallback to email local-part.
  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!;
    if (email.isNotEmpty) return email.split('@').first;
    return 'You';
  }

  UserProfile copyWith({
    String? fullName,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? dietaryPreference,
    int? dailyCalorieTarget,
    int? dailyWaterTargetMl,
    int? proteinTargetG,
    int? carbsTargetG,
    int? fatTargetG,
    bool? isPremium,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email,
      sex: sex,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyWaterTargetMl: dailyWaterTargetMl ?? this.dailyWaterTargetMl,
      proteinTargetG: proteinTargetG ?? this.proteinTargetG,
      carbsTargetG: carbsTargetG ?? this.carbsTargetG,
      fatTargetG: fatTargetG ?? this.fatTargetG,
      bmr: bmr,
      tdee: tdee,
      isPremium: isPremium ?? this.isPremium,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
    );
  }
}
