import 'package:flutter/material.dart';
import '../models/word_bank.dart';
import '../models/sight_word.dart';
import '../services/progress_service.dart';
import '../theme.dart';

/// Shows detailed progress: per-level breakdown, overall stats, word list.
class ProgressScreen extends StatelessWidget {
  final ProgressService progressService;
  final VoidCallback? onBack;

  const ProgressScreen({super.key, required this.progressService, this.onBack});

  @override
  Widget build(BuildContext context) {
    final levelStats = progressService.getLevelStats();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        leading: onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Overall stats
          _OverallStats(progressService: progressService),
          const SizedBox(height: 24),
          Text('Levels', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          // Per-level cards
          ...List.generate(WordBank.totalLevels, (i) {
            final level = i + 1;
            final stats = levelStats[level]!;
            final unlocked = level <= progressService.currentLevel;
            return _LevelCard(
              level: level,
              stats: stats,
              unlocked: unlocked,
              progressService: progressService,
            );
          }),
        ],
      ),
    );
  }
}

class _OverallStats extends StatelessWidget {
  final ProgressService progressService;
  const _OverallStats({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final total = WordBank.totalWords;
    final mastered = progressService.totalWordsMastered;
    final pct = total > 0 ? (mastered / total * 100).round() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('$mastered of $total words mastered',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total > 0 ? mastered / total : 0,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.starGold,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text('$pct%',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.starGold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MiniStat('Sessions', '${progressService.totalSessions}'),
                _MiniStat('Total ✓', '${progressService.totalCorrect}'),
                _MiniStat('Streak', '${progressService.streakDays} days'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final Map<String, int> stats;
  final bool unlocked;
  final ProgressService progressService;

  const _LevelCard({
    required this.level,
    required this.stats,
    required this.unlocked,
    required this.progressService,
  });

  @override
  Widget build(BuildContext context) {
    final mastered = stats['mastered']!;
    final learning = stats['learning']!;
    final total = stats['total']!;
    final pct = total > 0 ? (mastered / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: unlocked ? AppTheme.surface : Colors.grey.shade100,
        child: ExpansionTile(
          leading: Icon(
            unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: unlocked ? AppTheme.primary : AppTheme.textLight,
          ),
          title: Text(WordBank.levelName(level),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: unlocked ? AppTheme.textDark : AppTheme.textLight)),
          subtitle: Text('$mastered/$total mastered · $learning learning',
              style: const TextStyle(fontSize: 13)),
          trailing: Text('$pct%',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: pct == 100 ? AppTheme.starGold : AppTheme.textLight)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WordBank.getWordsForLevel(level).map((w) {
                  final wp = progressService.getWordProgress(w.word);
                  Color bg;
                  switch (wp.mastery) {
                    case MasteryLevel.mastered:
                      bg = AppTheme.correct.withValues(alpha: 0.2);
                      break;
                    case MasteryLevel.familiar:
                      bg = AppTheme.starGold.withValues(alpha: 0.2);
                      break;
                    case MasteryLevel.learning:
                      bg = AppTheme.secondary.withValues(alpha: 0.2);
                      break;
                    case MasteryLevel.unseen:
                      bg = Colors.grey.shade100;
                      break;
                  }
                  return Chip(
                    label: Text(w.word),
                    backgroundColor: bg,
                    labelStyle: const TextStyle(fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
