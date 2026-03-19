import 'package:flutter_tts/flutter_tts.dart';

/// Wraps flutter_tts with Australian English defaults.
/// All speak methods cancel any in-progress speech first.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  int _sequence = 0; // Cancellation token for multi-step speech

  Future<void> init() async {
    await _tts.setLanguage('en-AU');
    await _tts.setSpeechRate(0.4); // Slow for kids
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  /// Stop any current speech and speak new text.
  Future<void> speak(String text) async {
    if (!_ready) await init();
    _sequence++; // Invalidate any pending speakThenWord
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stop current speech, speak an instruction, pause, then speak a word.
  /// If another speak/speakThenWord is called during the pause,
  /// the second part is cancelled.
  Future<void> speakThenWord(String instruction, String word) async {
    if (!_ready) await init();
    final token = ++_sequence;
    await _tts.stop();
    await _tts.speak(instruction);
    if (_sequence != token) return; // Cancelled
    await Future.delayed(const Duration(milliseconds: 400));
    if (_sequence != token) return; // Cancelled
    await _tts.speak(word);
  }

  Future<void> stop() async {
    _sequence++;
    await _tts.stop();
  }
}
