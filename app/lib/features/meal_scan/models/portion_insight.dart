/// Porsiyon analizi: 0-100 skor + ana metin + highlight'lar.
class PortionInsight {
  final int score;
  final String mainText;
  final List<String> highlights;

  const PortionInsight({
    required this.score,
    required this.mainText,
    required this.highlights,
  });

  static String mainTextFromScore(int score) {
    if (score >= 90) return 'Excellent portion!';
    if (score >= 75) return 'Great portion!';
    if (score >= 60) return 'Good portion';
    return 'Consider smaller portion';
  }

  factory PortionInsight.fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as num).toInt();
    return PortionInsight(
      score: score,
      mainText: (json['main_text'] as String?) ?? mainTextFromScore(score),
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'main_text': mainText,
        'highlights': highlights,
      };
}
