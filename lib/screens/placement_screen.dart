import 'package:flutter/material.dart';
import '../models/word_bank.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Optional placement test shown on first launch.
/// Shows words level by level; kid taps "I know this" or "Not yet".
/// Can be skipped entirely to start from level 1.
class PlacementScreen extends StatefulWidget {
  final ProgressService progressService;
  final VoidCallback onComplete;

  const PlacementScreen({
    super.key,
    required this.progressService,
    required this.onComplete,
  });

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  final TtsService _tts = TtsService();
  int _currentLevel = 1;
  int _wordIndex = 0;
  int _knownInLevel = 0;
  int _totalKnown = 0;
  bool _showIntro = true;
  late List<String> _currentWords;

  @override
  void initState() {
    super.initState();
    _loadLevel();
    // Speak the intro for the kid
    Future.delayed(const Duration(milliseconds: 500), () {
      _tts.speak("Let's see what you know! We'll show you some words. Tap the tick if you know it, or the cross if not.");
    });
  }

  void _loadLevel() {
    final words = WordBank.getWordsForLevel(_currentLevel);
    // Test a sample of 8 words per level (or all if fewer)
    words.shuffle();
    _currentWords = words.take(8).map((w) => w.word).toList();
    _wordIndex = 0;
    _knownInLevel = 0;
  }

  void _onKnow() {
    widget.progressService.markAsKnown(_currentWords[_wordIndex]);
    _knownInLevel++;
    _totalKnown++;
    _advance();
  }

  void _onDontKnow() {
    _advance();
  }

  void _advance() {
    if (_wordIndex + 1 < _currentWords.length) {
      setState(() => _wordIndex++);
      _speakCurrentPrompt();
    } else {
      // Finished this level
      if (_knownInLevel >= (_currentWords.length * 0.6).ceil() &&
          _currentLevel < WordBank.totalLevels) {
        // Knew most words — try next level
        setState(() {
          _currentLevel++;
          _loadLevel();
        });
      } else {
        // Start from this level (or level 1 if they failed level 1)
        final startLevel = _knownInLevel < (_currentWords.length * 0.6).ceil()
            ? _currentLevel
            : _currentLevel;
        _finish(startLevel);
      }
    }
  }

  void _skipPlacement() {
    _finish(1);
  }

  void _speakCurrentPrompt() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _tts.speak('Do you know this word?');
    });
  }

  void _finish(int startLevel) {
    widget.progressService.completePlacement(startLevel);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return _buildIntro();
    }
    return _buildTest();
  }

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined,
                    size: 64, color: AppTheme.starGold),
                const SizedBox(height: 24),
                Text(
                  'Let\'s see what you know!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ll show you some words.\nTap the tick if you know it,\nor the cross if not.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _showIntro = false);
                    _speakCurrentPrompt();
                  },
                  child: const Text('Let\'s Go!'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _skipPlacement,
                  child: const Text(
                    'Start from the beginning',
                    style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTest() {
    final word = _currentWords[_wordIndex];
    final progress = (_wordIndex + 1) / _currentWords.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress
              Row(
                children: [
                  Text('Level $_currentLevel',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Text('$_totalKnown words known',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const Spacer(),
              // Word card
              GestureDetector(
                onTap: () => _tts.speak(word),
                child: Card(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Text(
                          word,
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volume_up,
                                color: AppTheme.textLight, size: 20),
                            SizedBox(width: 4),
                            Text('Tap to hear',
                                style: TextStyle(
                                    color: AppTheme.textLight, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Do you know this word?',
                  style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton.icon(
                        onPressed: _onDontKnow,
                        icon: const Icon(Icons.close, size: 28),
                        label: const Text('No'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.incorrect,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton.icon(
                        onPressed: _onKnow,
                        icon: const Icon(Icons.check, size: 28),
                        label: const Text('Yes!'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.correct,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _skipPlacement,
                child: const Text('Skip — start from the beginning'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
