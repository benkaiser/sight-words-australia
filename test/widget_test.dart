import 'package:flutter_test/flutter_test.dart';
import 'package:sight_words_australia/models/word_bank.dart';

void main() {
  test('WordBank has 12 levels (Oxford Wordlist Lists 1-12)', () {
    expect(WordBank.totalLevels, 12);
  });

  test('Each level has 24-25 words', () {
    for (var i = 1; i <= WordBank.totalLevels; i++) {
      final count = WordBank.getWordsForLevel(i).length;
      expect(count, inInclusiveRange(24, 25),
          reason: 'Level $i has $count words');
    }
  });

  test('Total words are roughly 300 (Oxford Wordlist)', () {
    expect(WordBank.totalWords, inInclusiveRange(295, 310));
  });

  test('All words are unique', () {
    final all = WordBank.getAllWords().map((w) => w.word.toLowerCase()).toList();
    final seen = <String>{};
    final dupes = <String>[];
    for (final w in all) {
      if (!seen.add(w)) dupes.add(w);
    }
    expect(dupes, isEmpty, reason: 'Duplicate words found: $dupes');
  });

  test('Level names match school structure', () {
    expect(WordBank.levelName(1), 'Prep List 1');
    expect(WordBank.levelName(4), 'Prep List 4');
    expect(WordBank.levelName(5), 'Year 1 List 1');
    expect(WordBank.levelName(8), 'Year 1 List 4');
    expect(WordBank.levelName(9), 'Year 2 List 1');
    expect(WordBank.levelName(12), 'Year 2 List 4');
  });
}
