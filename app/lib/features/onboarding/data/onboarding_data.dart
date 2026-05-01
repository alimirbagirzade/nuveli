/// Onboarding boyunca toplanan kullanıcı verileri.
/// Immutable — her adımda copyWith ile güncellenir.
class OnboardingData {
  const OnboardingData({
    this.displayName,
    this.goal,
    this.birthYear,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.specialConditions = const [],
    this.coachPersona,
    this.notifMealReminders = true,
    this.notifCoachNudges = true,
    this.notifWeeklySummary = true,
    // Sprint 2.1: yeni alanlar
    this.sensitivityLevel,
    this.foodRelationship,
    this.allergies = const [],
    this.dietaryPreference = 'none',
  });

  final String? displayName;
  final String? goal; // 'lose' | 'maintain' | 'gain'
  final int? birthYear;
  final String? gender; // 'male' | 'female' | 'other'
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel; // 'sedentary' | 'light' | 'moderate' | 'active'
  final List<String> specialConditions;
  final String? coachPersona; // 'gentle' | 'funny' | 'direct' | 'calm' (PRD)
  final bool notifMealReminders;
  final bool notifCoachNudges;
  final bool notifWeeklySummary;
  // Sprint 2.1: yeni alanlar
  final String? sensitivityLevel; // 'normal' | 'sensitive' | 'high_risk'
  final Map<String, dynamic>? foodRelationship;
  final List<String> allergies;
  final String dietaryPreference;

  OnboardingData copyWith({
    String? displayName,
    String? goal,
    int? birthYear,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    List<String>? specialConditions,
    String? coachPersona,
    bool? notifMealReminders,
    bool? notifCoachNudges,
    bool? notifWeeklySummary,
    String? sensitivityLevel,
    Map<String, dynamic>? foodRelationship,
    List<String>? allergies,
    String? dietaryPreference,
  }) {
    return OnboardingData(
      displayName: displayName ?? this.displayName,
      goal: goal ?? this.goal,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      specialConditions: specialConditions ?? this.specialConditions,
      coachPersona: coachPersona ?? this.coachPersona,
      notifMealReminders: notifMealReminders ?? this.notifMealReminders,
      notifCoachNudges: notifCoachNudges ?? this.notifCoachNudges,
      notifWeeklySummary: notifWeeklySummary ?? this.notifWeeklySummary,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
      foodRelationship: foodRelationship ?? this.foodRelationship,
      allergies: allergies ?? this.allergies,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
    );
  }

  /// Backend'e gönderilecek onboarding payload.
  Map<String, dynamic> toOnboardingPayload() {
    return {
      'display_name': displayName,
      'birth_year': birthYear,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'goal': goal,
      'activity_level': activityLevel,
      'special_conditions': specialConditions,
      // Sprint 2.1
      'food_relationship': foodRelationship,
      'allergies': allergies,
      'dietary_preference': dietaryPreference,
    };
  }

  /// Notification preferences payload.
  Map<String, dynamic> toNotifPayload() {
    return {
      'meal_reminders': notifMealReminders,
      'coach_nudges': notifCoachNudges,
      'weekly_summary': notifWeeklySummary,
      'quiet_start': '22:00',
      'quiet_end': '08:00',
    };
  }

  /// Profil adımı tamamlandı mı? (kaydet butonu aktif olsun mu)
  bool get isProfileComplete {
    return birthYear != null &&
        gender != null &&
        heightCm != null &&
        weightKg != null &&
        activityLevel != null;
  }

  /// Tüm onboarding tamamlandı mı?
  bool get isComplete {
    return goal != null && isProfileComplete && coachPersona != null;
  }
}
