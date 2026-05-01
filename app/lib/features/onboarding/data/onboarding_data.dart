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
  });

  final String? displayName;
  final String? goal; // 'lose' | 'maintain' | 'gain'
  final int? birthYear;
  final String? gender; // 'male' | 'female' | 'other'
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel; // 'sedentary' | 'light' | 'moderate' | 'active'
  final List<String> specialConditions;
  final String? coachPersona; // 'supportive' | 'analytical' | 'motivational' | 'casual'
  final bool notifMealReminders;
  final bool notifCoachNudges;
  final bool notifWeeklySummary;

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
