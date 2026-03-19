import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sight_word.dart';
import '../models/word_bank.dart';

/// Manages all word progress, spaced repetition, and persistence.
class ProgressService extends ChangeNotifier {
  static const _storageKey = 'word_progress';
  static const _placementDoneKey = 'placement_done';
  static const _currentLevelKey = 'current_level';
  static const _totalSessionsKey = 'total_sessions';
  static const _totalCorrectKey = 'total_correct';
  static const _streakDaysKey = 'streak_days';
  static const _lastSessionDateKey = 'last_session_date';

  final Map<String, WordProgress> _progress = {};
  late SharedPreferences _prefs;
  bool _placementDone = false;
  int _currentLevel = 1;
  int _totalSessions = 0;
  int _totalCorrect = 0;
  int _streakDays = 0;

  bool get placementDone => _placementDone;
  int get currentLevel => _currentLevel;
  int get totalSessions => _totalSessions;
  int get totalCorrect => _totalCorrect;
  int get streakDays => _streakDays;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _placementDone = _prefs.getBool(_placementDoneKey) ?? false;
    _currentLevel = _prefs.getInt(_currentLevelKey) ?? 1;
    _totalSessions = _prefs.getInt(_totalSessionsKey) ?? 0;
    _totalCorrect = _prefs.getInt(_totalCorrectKey) ?? 0;
    _streakDays = _prefs.getInt(_streakDaysKey) ?? 0;
    _updateStreak();
    _loadProgress();
  }

  void _loadProgress() {
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      for (final entry in decoded.entries) {
        _progress[entry.key] =
            WordProgress.fromJson(entry.value as Map<String, dynamic>);
      }
    }
  }

  Future<void> _save() async {
    final data = _progress.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_storageKey, jsonEncode(data));
    await _prefs.setInt(_currentLevelKey, _currentLevel);
    await _prefs.setInt(_totalSessionsKey, _totalSessions);
    await _prefs.setInt(_totalCorrectKey, _totalCorrect);
    await _prefs.setInt(_streakDaysKey, _streakDays);
    await _prefs.setString(_lastSessionDateKey, DateTime.now().toIso8601String());
  }

  void _updateStreak() {
    final lastStr = _prefs.getString(_lastSessionDateKey);
    if (lastStr == null) return;
    final last = DateTime.parse(lastStr);
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    if (diff > 1) {
      _streakDays = 0; // streak broken
    }
  }

  /// Record the start of a new session.
  void startSession() {
    _totalSessions++;
    final now = DateTime.now();
    final lastStr = _prefs.getString(_lastSessionDateKey);
    if (lastStr != null) {
      final last = DateTime.parse(lastStr);
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      if (diff >= 1) {
        _streakDays++;
      }
    } else {
      _streakDays = 1;
    }
    _save();
    notifyListeners();
  }

  WordProgress getWordProgress(String word) {
    return _progress.putIfAbsent(word, () => WordProgress(word: word));
  }

  /// Record a correct answer for a word.
  void recordCorrect(String word) {
    final wp = getWordProgress(word);
    wp.correctCount++;
    wp.streak++;
    wp.lastSeen = DateTime.now();
    _totalCorrect++;

    // Update mastery
    if (wp.streak >= 6 && wp.accuracy >= 0.85) {
      wp.mastery = MasteryLevel.mastered;
      wp.nextReview = DateTime.now().add(const Duration(days: 7));
    } else if (wp.streak >= 3) {
      wp.mastery = MasteryLevel.familiar;
      wp.nextReview = DateTime.now().add(const Duration(days: 2));
    } else {
      wp.mastery = MasteryLevel.learning;
      wp.nextReview = DateTime.now().add(const Duration(hours: 4));
    }

    _checkLevelUp();
    _save();
    notifyListeners();
  }

  /// Record an incorrect answer for a word.
  void recordIncorrect(String word) {
    final wp = getWordProgress(word);
    wp.incorrectCount++;
    wp.streak = 0;
    wp.lastSeen = DateTime.now();
    wp.nextReview = DateTime.now().add(const Duration(minutes: 10));

    if (wp.mastery == MasteryLevel.mastered) {
      wp.mastery = MasteryLevel.familiar;
    } else {
      wp.mastery = MasteryLevel.learning;
    }

    _save();
    notifyListeners();
  }

  /// Mark a word as already known (from placement test).
  void markAsKnown(String word) {
    final wp = getWordProgress(word);
    wp.correctCount = 3;
    wp.streak = 6;
    wp.mastery = MasteryLevel.mastered;
    wp.lastSeen = DateTime.now();
    wp.nextReview = DateTime.now().add(const Duration(days: 7));
    _save();
  }

  /// Mark placement test as complete.
  Future<void> completePlacement(int startLevel) async {
    _placementDone = true;
    _currentLevel = startLevel;
    await _prefs.setBool(_placementDoneKey, true);
    await _save();
    notifyListeners();
  }

  void _checkLevelUp() {
    final levelWords = WordBank.getWordsForLevel(_currentLevel);
    final masteredCount = levelWords
        .where((w) => getWordProgress(w.word).mastery == MasteryLevel.mastered)
        .length;
    // Unlock next level when 80% of current level is mastered
    if (masteredCount >= (levelWords.length * 0.8).ceil() &&
        _currentLevel < WordBank.totalLevels) {
      _currentLevel++;
    }
  }

  /// Get words that need review (due for spaced repetition).
  List<SightWord> getWordsForReview() {
    final now = DateTime.now();
    final allWords = WordBank.getAllWords();
    return allWords.where((sw) {
      final wp = _progress[sw.word];
      if (wp == null) return false;
      if (wp.mastery == MasteryLevel.unseen) return false;
      return wp.nextReview != null && wp.nextReview!.isBefore(now);
    }).toList();
  }

  /// Get new words to learn from the current level.
  List<SightWord> getNewWords({int count = 5}) {
    final levelWords = WordBank.getWordsForLevel(_currentLevel);
    final unseen = levelWords
        .where((w) => getWordProgress(w.word).mastery == MasteryLevel.unseen)
        .toList();
    unseen.shuffle(Random());
    return unseen.take(count).toList();
  }

  /// Build a balanced session: mix of review words + new words.
  List<SightWord> buildSession({int size = 10}) {
    final review = getWordsForReview();
    final newWords = getNewWords(count: size);

    final session = <SightWord>[];

    // Prioritise review words (up to half the session)
    review.shuffle(Random());
    session.addAll(review.take((size / 2).ceil()));

    // Fill remaining with new words
    final remaining = size - session.length;
    session.addAll(newWords.take(remaining));

    // If still short, add learning/familiar words from current level
    if (session.length < size) {
      final levelWords = WordBank.getWordsForLevel(_currentLevel);
      final extras = levelWords
          .where((w) =>
              !session.any((s) => s.word == w.word) &&
              getWordProgress(w.word).mastery != MasteryLevel.mastered)
          .toList();
      extras.shuffle(Random());
      session.addAll(extras.take(size - session.length));
    }

    session.shuffle(Random());
    return session;
  }

  // Stats helpers
  int get totalWordsSeen =>
      _progress.values.where((p) => p.mastery != MasteryLevel.unseen).length;

  int get totalWordsMastered =>
      _progress.values.where((p) => p.mastery == MasteryLevel.mastered).length;

  int get totalWordsLearning =>
      _progress.values.where((p) => p.mastery == MasteryLevel.learning).length;

  int get totalWordsFamiliar =>
      _progress.values.where((p) => p.mastery == MasteryLevel.familiar).length;

  Map<int, Map<String, int>> getLevelStats() {
    final stats = <int, Map<String, int>>{};
    for (var level = 1; level <= WordBank.totalLevels; level++) {
      final words = WordBank.getWordsForLevel(level);
      var mastered = 0, learning = 0, unseen = 0;
      for (final w in words) {
        final p = getWordProgress(w.word);
        switch (p.mastery) {
          case MasteryLevel.mastered:
            mastered++;
            break;
          case MasteryLevel.familiar:
          case MasteryLevel.learning:
            learning++;
            break;
          case MasteryLevel.unseen:
            unseen++;
            break;
        }
      }
      stats[level] = {'mastered': mastered, 'learning': learning, 'unseen': unseen, 'total': words.length};
    }
    return stats;
  }
}
