/// Represents a single sight word and its learning state.
class SightWord {
  final String word;
  final int level; // 1-10, grouped by difficulty/frequency

  SightWord({required this.word, required this.level});
}

/// Tracks a user's progress on a specific word.
class WordProgress {
  final String word;
  int correctCount;
  int incorrectCount;
  int streak;
  DateTime? lastSeen;
  DateTime? nextReview;
  MasteryLevel mastery;

  WordProgress({
    required this.word,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.streak = 0,
    this.lastSeen,
    this.nextReview,
    this.mastery = MasteryLevel.unseen,
  });

  double get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0;
    return correctCount / total;
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'streak': streak,
    'lastSeen': lastSeen?.toIso8601String(),
    'nextReview': nextReview?.toIso8601String(),
    'mastery': mastery.index,
  };

  factory WordProgress.fromJson(Map<String, dynamic> json) => WordProgress(
    word: json['word'] as String,
    correctCount: json['correctCount'] as int? ?? 0,
    incorrectCount: json['incorrectCount'] as int? ?? 0,
    streak: json['streak'] as int? ?? 0,
    lastSeen: json['lastSeen'] != null
        ? DateTime.parse(json['lastSeen'] as String)
        : null,
    nextReview: json['nextReview'] != null
        ? DateTime.parse(json['nextReview'] as String)
        : null,
    mastery: MasteryLevel.values[json['mastery'] as int? ?? 0],
  );
}

enum MasteryLevel {
  unseen,     // Never attempted
  learning,   // Seen but < 3 streak
  familiar,   // 3-5 streak
  mastered,   // 6+ streak with high accuracy
}
