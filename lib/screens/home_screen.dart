import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme.dart';

/// Home screen — entry point after placement. Shows stats and session options.
class HomeScreen extends StatelessWidget {
  final ProgressService progressService;
  final VoidCallback onStartSession;
  final VoidCallback onViewProgress;

  const HomeScreen({
    super.key,
    required this.progressService,
    required this.onStartSession,
    required this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Sight Words',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Australia',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Quick stats row
              _StatsRow(progressService: progressService),
              const SizedBox(height: 32),
              // Streak
              if (progressService.streakDays > 0)
                _StreakBanner(days: progressService.streakDays),
              const Spacer(),
              // Main action
              SizedBox(
                height: 72,
                child: ElevatedButton.icon(
                  onPressed: onStartSession,
                  icon: const Icon(Icons.play_arrow_rounded, size: 32),
                  label: const Text('Start Learning'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: onViewProgress,
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text('My Progress'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ProgressService progressService;
  const _StatsRow({required this.progressService});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.star_rounded,
          value: '${progressService.totalWordsMastered}',
          label: 'Mastered',
          color: AppTheme.starGold,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.auto_stories_rounded,
          value: '${progressService.totalWordsSeen}',
          label: 'Seen',
          color: AppTheme.accent,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.emoji_events_rounded,
          value: 'Lv ${progressService.currentLevel}',
          label: 'Level',
          color: AppTheme.secondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int days;
  const _StreakBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.starGold.withValues(alpha: 0.15),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              '$days day streak!',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
