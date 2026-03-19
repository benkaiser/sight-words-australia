import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sight_word.dart';
import '../models/word_bank.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Tappable instruction row — shows text with a speaker icon to re-hear it.
class _SpeakableInstruction extends StatelessWidget {
  final String text;
  final TtsService tts;

  const _SpeakableInstruction({required this.text, required this.tts});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tts.speak(text),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.volume_up_rounded, size: 22, color: AppTheme.accent),
        ],
      ),
    );
  }
}

enum ActivityType { flashCard, wordMatch, spellTap, sentenceFill, missingLetter }

/// Main learning session — cycles through different activity types.
class SessionScreen extends StatefulWidget {
  final ProgressService progressService;
  final VoidCallback onComplete;

  const SessionScreen({
    super.key,
    required this.progressService,
    required this.onComplete,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final TtsService _tts = TtsService();
  late List<SightWord> _words;
  int _currentIndex = 0;
  int _correctThisSession = 0;
  int _totalThisSession = 0;
  late ActivityType _currentActivity;
  bool _sessionComplete = false;

  final _random = Random();
  bool _summarySpoken = false;

  @override
  void initState() {
    super.initState();
    _words = widget.progressService.buildSession(size: 10);
    _pickActivity();
    // Defer startSession to avoid notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.progressService.startSession();
    });
  }

  void _pickActivity() {
    if (_words.isEmpty) {
      setState(() => _sessionComplete = true);
      return;
    }

    final word = _words[_currentIndex];
    final available = <ActivityType>[ActivityType.flashCard];

    // Word match always available
    available.add(ActivityType.wordMatch);

    // Spell tap for words with 2+ letters
    if (word.word.length >= 2) {
      available.add(ActivityType.spellTap);
    }

    // Missing letter for words with 3+ letters
    if (word.word.length >= 3) {
      available.add(ActivityType.missingLetter);
    }

    // Sentence fill if we have a sentence
    if (WordBank.getSentence(word.word) != null) {
      available.add(ActivityType.sentenceFill);
    }

    _currentActivity = available[_random.nextInt(available.length)];
  }

  void _onCorrect() {
    widget.progressService.recordCorrect(_words[_currentIndex].word);
    _correctThisSession++;
    _totalThisSession++;
    _next();
  }

  void _onIncorrect() {
    widget.progressService.recordIncorrect(_words[_currentIndex].word);
    _totalThisSession++;
    // Re-add the word later in the session for another try
    if (_currentIndex + 2 < _words.length) {
      _words.insert(
          _currentIndex + 3 > _words.length
              ? _words.length
              : _currentIndex + 3,
          _words[_currentIndex]);
    } else {
      _words.add(_words[_currentIndex]);
    }
    _next();
  }

  void _next() {
    if (_currentIndex + 1 >= _words.length) {
      setState(() => _sessionComplete = true);
    } else {
      setState(() {
        _currentIndex++;
        _pickActivity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionComplete) {
      return _buildSummary();
    }

    final word = _words[_currentIndex];
    final progress = (_currentIndex + 1) / _words.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _confirmExit(context),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_correctThisSession ★',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.starGold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Activity
              Expanded(
                child: _buildActivity(word),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivity(SightWord word) {
    // Use a unique key per question so Flutter creates fresh state
    // even when the same activity type appears consecutively.
    final key = ValueKey('activity_$_currentIndex');
    switch (_currentActivity) {
      case ActivityType.flashCard:
        return _FlashCardActivity(
          key: key,
          word: word,
          tts: _tts,
          onCorrect: _onCorrect,
          onIncorrect: _onIncorrect,
        );
      case ActivityType.wordMatch:
        return _WordMatchActivity(
          key: key,
          word: word,
          allWords: _words,
          tts: _tts,
          onCorrect: _onCorrect,
          onIncorrect: _onIncorrect,
        );
      case ActivityType.spellTap:
        return _SpellTapActivity(
          key: key,
          word: word,
          tts: _tts,
          onCorrect: _onCorrect,
          onIncorrect: _onIncorrect,
        );
      case ActivityType.sentenceFill:
        final sentence = WordBank.getSentence(word.word);
        if (sentence == null) {
          // Fallback to flash card
          return _FlashCardActivity(
            key: key,
            word: word,
            tts: _tts,
            onCorrect: _onCorrect,
            onIncorrect: _onIncorrect,
          );
        }
        return _SentenceFillActivity(
          key: key,
          word: word,
          sentence: sentence,
          allWords: _words,
          tts: _tts,
          onCorrect: _onCorrect,
          onIncorrect: _onIncorrect,
        );
      case ActivityType.missingLetter:
        return _MissingLetterActivity(
          key: key,
          word: word,
          tts: _tts,
          onCorrect: _onCorrect,
          onIncorrect: _onIncorrect,
        );
    }
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop?'),
        content: const Text('Your work is saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onComplete();
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final pct = _totalThisSession > 0
        ? (_correctThisSession / _totalThisSession * 100).round()
        : 0;

    // Speak the summary aloud (once)
    if (!_summarySpoken) {
      _summarySpoken = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        _tts.speak('Well done! You got $_correctThisSession right.');
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration_rounded,
                    size: 72, color: AppTheme.starGold),
                const SizedBox(height: 24),
                Text('Well done!',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 16),
                Text('$_correctThisSession out of $_totalThisSession right',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('$pct% accuracy',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                // Stars display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: pct >= (i + 1) * 30
                          ? AppTheme.starGold
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Words mastered: ${widget.progressService.totalWordsMastered}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: widget.onComplete,
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ACTIVITY WIDGETS ====================

/// Flash card — shows word, kid reads it aloud, self-reports.
class _FlashCardActivity extends StatefulWidget {
  final SightWord word;
  final TtsService tts;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const _FlashCardActivity({
    super.key,
    required this.word,
    required this.tts,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<_FlashCardActivity> createState() => _FlashCardActivityState();
}

class _FlashCardActivityState extends State<_FlashCardActivity> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.tts.speak('Say this word out loud');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SpeakableInstruction(text: 'Say this word out loud', tts: widget.tts),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _revealed ? () => widget.tts.speak(widget.word.word) : null,
          child: Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                widget.word.word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (!_revealed)
          ElevatedButton(
            onPressed: () {
              widget.tts.speak(widget.word.word);
              setState(() => _revealed = true);
              Future.delayed(const Duration(milliseconds: 1500), () {
                widget.tts.speak('Did you get it right?');
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Hear it'),
          ),
        if (_revealed) ...[
          _SpeakableInstruction(text: 'Did you get it right?', tts: widget.tts),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: widget.onIncorrect,
                    icon: const Icon(Icons.close),
                    label: const Text('No'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.incorrect),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: widget.onCorrect,
                    icon: const Icon(Icons.check),
                    label: const Text('Yes'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.correct),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Word match — hear the word, tap the correct one from 4 options.
class _WordMatchActivity extends StatefulWidget {
  final SightWord word;
  final List<SightWord> allWords;
  final TtsService tts;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const _WordMatchActivity({
    super.key,
    required this.word,
    required this.allWords,
    required this.tts,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<_WordMatchActivity> createState() => _WordMatchActivityState();
}

class _WordMatchActivityState extends State<_WordMatchActivity> {
  late List<String> _options;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildOptions();
    // Speak instruction, pause, then the word
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.tts.speakThenWord('Find the word you hear', widget.word.word);
    });
  }

  void _buildOptions() {
    final others = widget.allWords
        .where((w) => w.word != widget.word.word)
        .map((w) => w.word)
        .toSet()
        .toList();
    others.shuffle();
    _options = [widget.word.word, ...others.take(3)];
    _options.shuffle();
  }

  void _onTap(String word) {
    if (_answered) return;
    setState(() {
      _selected = word;
      _answered = true;
    });

    final isCorrect = word == widget.word.word;
    if (!isCorrect) {
      // Say the correct word so the child hears it
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.tts.speak(widget.word.word);
      });
    }
    Future.delayed(
      Duration(milliseconds: isCorrect ? 1000 : 2000),
      isCorrect ? widget.onCorrect : widget.onIncorrect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SpeakableInstruction(text: 'Find the word you hear', tts: widget.tts),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 48),
            color: AppTheme.accent,
            onPressed: () => widget.tts.speak(widget.word.word),
          ),
          const SizedBox(height: 24),
          ...List.generate(_options.length, (i) {
          final opt = _options[i];
          final isCorrectWord = opt == widget.word.word;
          final isSelectedWrong = opt == _selected && !isCorrectWord;

          // Determine styling based on answer state
          Color bg = AppTheme.surface;
          Border? border;
          if (_answered) {
            if (isCorrectWord) {
              bg = AppTheme.correct.withValues(alpha: 0.15);
              border = Border.all(color: AppTheme.correct, width: 3);
            } else if (isSelectedWrong) {
              bg = AppTheme.incorrect.withValues(alpha: 0.1);
              border = Border.all(color: AppTheme.incorrect, width: 3);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: border,
              ),
              child: ElevatedButton(
                onPressed: _answered ? null : () => _onTap(opt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppTheme.textDark,
                  disabledForegroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(opt, style: const TextStyle(fontSize: 28)),
                ),
              ),
            ),
          );
        }),
      ],
      ),
    );
  }
}

/// Spell tap — hear word, then tap letters in correct order.
class _SpellTapActivity extends StatefulWidget {
  final SightWord word;
  final TtsService tts;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const _SpellTapActivity({
    super.key,
    required this.word,
    required this.tts,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<_SpellTapActivity> createState() => _SpellTapActivityState();
}

class _SpellTapActivityState extends State<_SpellTapActivity> {
  late List<String> _shuffledLetters;
  final List<String> _tapped = [];
  bool _answered = false;
  bool _correct = false;

  @override
  void initState() {
    super.initState();
    _shuffledLetters = widget.word.word.split('');
    // Add distractors — prioritise phonetically similar letters
    final distractors = _buildDistractors(widget.word.word);
    // Always add 2-4 distractors depending on word length
    final count = widget.word.word.length <= 3 ? 3 : 2;
    _shuffledLetters.addAll(distractors.take(count));
    _shuffledLetters.shuffle();
    // Speak instruction, pause, then the word
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.tts.speakThenWord('Spell what you hear', widget.word.word);
    });
  }

  void _onLetterTap(int index) {
    if (_answered) return;
    setState(() {
      _tapped.add(_shuffledLetters[index]);
    });

    if (_tapped.length == widget.word.word.length) {
      final spelled = _tapped.join();
      _correct = spelled == widget.word.word;
      _answered = true;
      setState(() {});

      if (_correct) {
        Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
      } else {
        // Speak the correct word so they hear it
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.tts.speak(widget.word.word);
        });
        Future.delayed(const Duration(milliseconds: 2000), widget.onIncorrect);
      }
    }
  }

  void _onUndo() {
    if (_tapped.isEmpty || _answered) return;
    setState(() => _tapped.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SpeakableInstruction(text: 'Spell what you hear', tts: widget.tts),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.volume_up_rounded, size: 48),
          color: AppTheme.accent,
          onPressed: () => widget.tts.speak(widget.word.word),
        ),
        const SizedBox(height: 16),
        // Typed so far
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(widget.word.word.length, (i) {
              final letter = i < _tapped.length ? _tapped[i] : '_';
              Color color = AppTheme.textDark;
              if (_answered) {
                color = _correct ? AppTheme.correct : AppTheme.incorrect;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  letter,
                  style: TextStyle(
                      fontSize: 40, fontWeight: FontWeight.w800, color: color),
                ),
              );
            }),
            if (_tapped.isNotEmpty && !_answered)
              IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onUndo,
                color: AppTheme.textLight,
              ),
          ],
        ),
        if (_answered && !_correct) ...[
          const SizedBox(height: 8),
          Text(
            'The word is: ${widget.word.word}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.correct),
          ),
        ],
        const SizedBox(height: 24),
        // Letter buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(_shuffledLetters.length, (i) {
            final used = _countUsed(_shuffledLetters[i]) >=
                _countAvailable(_shuffledLetters[i]);
            return SizedBox(
              width: 56,
              height: 56,
              child: ElevatedButton(
                onPressed: (used || _answered) ? null : () => _onLetterTap(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surface,
                  foregroundColor: AppTheme.textDark,
                  disabledBackgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_shuffledLetters[i],
                    style: const TextStyle(fontSize: 24)),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build distractor letters that sound like they could be in the word.
  /// Prioritises phonetically confusing letters, then falls back to random.
  static List<String> _buildDistractors(String word) {
    // Letters that sound similar or are commonly confused by early readers
    const confusables = {
      'a': ['e', 'u'],
      'b': ['d', 'p'],
      'c': ['k', 's'],
      'd': ['b', 'p'],
      'e': ['a', 'i'],
      'f': ['v', 'ph'],
      'g': ['j'],
      'h': ['a'],  // silent h confusion
      'i': ['e', 'y'],
      'j': ['g'],
      'k': ['c'],
      'l': ['r'],
      'm': ['n'],
      'n': ['m'],
      'o': ['u', 'a'],
      'p': ['b', 'd'],
      'q': ['k'],
      'r': ['l', 'w'],
      's': ['c', 'z'],
      't': ['d'],
      'u': ['o', 'a'],
      'v': ['f', 'w'],
      'w': ['v', 'r'],
      'x': ['z', 's'],
      'y': ['i', 'e'],
      'z': ['s'],
    };

    final wordLetters = word.toLowerCase().split('').toSet();
    final candidates = <String>[];

    // First: gather phonetically similar letters not already in the word
    for (final letter in wordLetters) {
      final similar = confusables[letter];
      if (similar != null) {
        for (final s in similar) {
          if (s.length == 1 && !wordLetters.contains(s)) {
            candidates.add(s);
          }
        }
      }
    }

    // Remove duplicates and shuffle
    final unique = candidates.toSet().toList();
    unique.shuffle(Random());

    // Fill remaining with random letters not in the word
    final allLetters = 'abcdefghijklmnopqrstuvwxyz'
        .split('')
        .where((l) => !wordLetters.contains(l) && !unique.contains(l))
        .toList();
    allLetters.shuffle(Random());

    return [...unique, ...allLetters];
  }

  int _countUsed(String letter) =>
      _tapped.where((l) => l == letter).length;

  int _countAvailable(String letter) =>
      _shuffledLetters.where((l) => l == letter).length;
}

/// Sentence fill — show sentence with blank, pick the right word.
class _SentenceFillActivity extends StatefulWidget {
  final SightWord word;
  final String sentence;
  final List<SightWord> allWords;
  final TtsService tts;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const _SentenceFillActivity({
    super.key,
    required this.word,
    required this.sentence,
    required this.allWords,
    required this.tts,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<_SentenceFillActivity> createState() => _SentenceFillActivityState();
}

class _SentenceFillActivityState extends State<_SentenceFillActivity> {
  late String _displaySentence;
  late List<String> _options;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    // Replace _word_ with ___
    _displaySentence =
        widget.sentence.replaceAll('_${widget.word.word}_', '______');

    final others = widget.allWords
        .where((w) => w.word != widget.word.word)
        .map((w) => w.word)
        .toSet()
        .toList();
    others.shuffle();
    _options = [widget.word.word, ...others.take(2)];
    _options.shuffle();

    // Speak instruction, pause, then the sentence
    Future.delayed(const Duration(milliseconds: 400), () {
      final spoken = widget.sentence.replaceAll('_', '');
      widget.tts.speakThenWord('Pick the missing word', spoken);
    });
  }

  void _onTap(String word) {
    if (_answered) return;
    setState(() {
      _selected = word;
      _answered = true;
    });

    final isCorrect = word == widget.word.word;
    if (!isCorrect) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.tts.speak(widget.word.word);
      });
    }
    Future.delayed(
      Duration(milliseconds: isCorrect ? 1000 : 2000),
      isCorrect ? widget.onCorrect : widget.onIncorrect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SpeakableInstruction(text: 'Pick the missing word', tts: widget.tts),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.volume_up_rounded, size: 36),
          color: AppTheme.accent,
          onPressed: () {
            final spoken = widget.sentence.replaceAll('_', '');
            widget.tts.speak(spoken);
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _answered
                  ? widget.sentence.replaceAll('_${widget.word.word}_', widget.word.word).replaceAll('_', '')
                  : _displaySentence,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, color: AppTheme.textDark),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ...List.generate(_options.length, (i) {
          final opt = _options[i];
          final isCorrectWord = opt == widget.word.word;
          final isSelectedWrong = opt == _selected && !isCorrectWord;

          Color bg = AppTheme.surface;
          Border? border;
          if (_answered) {
            if (isCorrectWord) {
              bg = AppTheme.correct.withValues(alpha: 0.15);
              border = Border.all(color: AppTheme.correct, width: 3);
            } else if (isSelectedWrong) {
              bg = AppTheme.incorrect.withValues(alpha: 0.1);
              border = Border.all(color: AppTheme.incorrect, width: 3);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: border,
              ),
              child: ElevatedButton(
                onPressed: _answered ? null : () => _onTap(opt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppTheme.textDark,
                  disabledForegroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(opt, style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          );
        }),
      ],
      ),
    );
  }
}

/// Missing letter — show word with one letter blanked, pick the right letter.
class _MissingLetterActivity extends StatefulWidget {
  final SightWord word;
  final TtsService tts;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const _MissingLetterActivity({
    super.key,
    required this.word,
    required this.tts,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<_MissingLetterActivity> createState() => _MissingLetterActivityState();
}

class _MissingLetterActivityState extends State<_MissingLetterActivity> {
  late int _missingIndex;
  late String _missingLetter;
  late List<String> _options;
  String? _selected;
  bool _answered = false;

  // Letters that sound similar — used for distractors
  static const _confusables = {
    'a': ['e', 'u', 'o'],
    'b': ['d', 'p', 'g'],
    'c': ['k', 's', 'g'],
    'd': ['b', 'p', 't'],
    'e': ['a', 'i', 'u'],
    'f': ['v', 'p'],
    'g': ['j', 'c', 'k'],
    'h': ['n', 'b'],
    'i': ['e', 'y', 'a'],
    'j': ['g', 'y'],
    'k': ['c', 'g', 'q'],
    'l': ['r', 'i'],
    'm': ['n', 'w'],
    'n': ['m', 'r'],
    'o': ['u', 'a', 'e'],
    'p': ['b', 'd', 'q'],
    'q': ['g', 'p'],
    'r': ['l', 'w', 'n'],
    's': ['c', 'z', 'x'],
    't': ['d', 'p'],
    'u': ['o', 'a', 'v'],
    'v': ['w', 'f', 'u'],
    'w': ['v', 'm', 'u'],
    'x': ['z', 's'],
    'y': ['i', 'e', 'j'],
    'z': ['s', 'x'],
  };

  @override
  void initState() {
    super.initState();
    final letters = widget.word.word.toLowerCase().split('');

    // Pick a random letter to blank out
    _missingIndex = Random().nextInt(letters.length);
    _missingLetter = letters[_missingIndex];

    // Build options: correct letter + confusable distractors
    final distractors = <String>[];
    final similar = _confusables[_missingLetter];
    if (similar != null) {
      for (final s in similar) {
        if (s != _missingLetter) {
          distractors.add(s);
        }
      }
    }
    // Fill with random letters if needed
    final allLetters = 'abcdefghijklmnopqrstuvwxyz'
        .split('')
        .where((l) => l != _missingLetter && !distractors.contains(l))
        .toList();
    allLetters.shuffle(Random());
    distractors.addAll(allLetters);

    _options = [_missingLetter, ...distractors.take(3)];
    _options.shuffle(Random());

    // Speak instruction then the word
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.tts.speakThenWord('Pick the missing letter', widget.word.word);
    });
  }

  void _onTap(String letter) {
    if (_answered) return;
    setState(() {
      _selected = letter;
      _answered = true;
    });

    final isCorrect = letter == _missingLetter;
    if (!isCorrect) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.tts.speak(widget.word.word);
      });
    }
    Future.delayed(
      Duration(milliseconds: isCorrect ? 1000 : 2000),
      isCorrect ? widget.onCorrect : widget.onIncorrect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = widget.word.word.split('');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SpeakableInstruction(text: 'Pick the missing letter', tts: widget.tts),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.volume_up_rounded, size: 48),
          color: AppTheme.accent,
          onPressed: () => widget.tts.speak(widget.word.word),
        ),
        const SizedBox(height: 24),
        // Word with blank
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(letters.length, (i) {
                final isBlank = i == _missingIndex;
                String display;
                Color color;

                if (!isBlank) {
                  display = letters[i];
                  color = AppTheme.textDark;
                } else if (_answered) {
                  display = _missingLetter;
                  color = (_selected == _missingLetter)
                      ? AppTheme.correct
                      : AppTheme.incorrect;
                } else {
                  display = '_';
                  color = AppTheme.accent;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Letter options
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _options.map((letter) {
            final isCorrectLetter = letter == _missingLetter;
            final isSelectedWrong = letter == _selected && !isCorrectLetter;

            Color bg = AppTheme.surface;
            Border? border;
            if (_answered) {
              if (isCorrectLetter) {
                bg = AppTheme.correct.withValues(alpha: 0.15);
                border = Border.all(color: AppTheme.correct, width: 3);
              } else if (isSelectedWrong) {
                bg = AppTheme.incorrect.withValues(alpha: 0.1);
                border = Border.all(color: AppTheme.incorrect, width: 3);
              }
            }

            return Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: border,
              ),
              child: ElevatedButton(
                onPressed: _answered ? null : () => _onTap(letter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppTheme.textDark,
                  disabledForegroundColor: AppTheme.textDark,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(letter, style: const TextStyle(fontSize: 28)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}