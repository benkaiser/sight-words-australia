# AGENTS.md — Guide for LLMs working on this codebase

## What is this app?

**Sight Words Australia** is a Flutter mobile app that teaches Australian Prep/Foundation students (age ~5) to read high-frequency sight words. It uses the Oxford Wordlist (200 words across 10 levels) with spaced repetition and multiple activity types.

## Architecture overview

### State management
- **Provider** with a single `ProgressService` (ChangeNotifier) at the root
- All word progress, session stats, and level tracking live in `ProgressService`
- Persisted to `shared_preferences` as JSON

### Navigation
- Simple enum-based screen switching in `AppShell` (lib/main.dart)
- No router package — screens are swapped via `_goto(AppScreen.xxx)`
- Flow: Placement (first launch, optional) → Home → Session or Progress

### Data model
- `SightWord` — a word + its level (1-10)
- `WordProgress` — per-word tracking: correct/incorrect counts, streak, mastery level, next review time
- `MasteryLevel` enum: unseen → learning → familiar → mastered
- `WordBank` — static data class holding all 200 words and example sentences

### Spaced repetition
- Lives in `ProgressService.recordCorrect()` / `recordIncorrect()`
- Mastered words reviewed in 7 days, familiar in 2 days, learning in 4 hours, incorrect in 10 minutes
- Sessions mix review words (due for repetition) with new words from the current level
- Level unlocks when 80% of current level words are mastered

### Activity types (in SessionScreen)
1. **Flash Card** — show word, kid reads aloud, self-reports correct/incorrect
2. **Word Match** — hear word via TTS, tap correct word from 4 options
3. **Spell Tap** — hear word, tap letters in correct order to spell it
4. **Sentence Fill** — show sentence with blank, pick the missing word from 3 options

Activity type is randomly selected per word, with availability depending on word length and sentence data.

### Text-to-speech
- `TtsService` wraps `flutter_tts` with `en-AU` locale and slow speech rate (0.4)
- Used in placement test, word match, spell tap, and sentence fill activities

### Theming
- `AppTheme` in lib/theme.dart — warm cream background, soft green primary, peach secondary
- Large rounded cards, big text for young readers
- Nunito font family specified (falls back to system sans-serif)

## Key files to modify

| Task | File(s) |
|------|---------|
| Add/change words | `lib/models/word_bank.dart` |
| Change spaced repetition timing | `lib/services/progress_service.dart` (recordCorrect/recordIncorrect) |
| Add new activity type | `lib/screens/session_screen.dart` — add to `ActivityType` enum, create widget, add to `_pickActivity()` and `_buildActivity()` |
| Change colours/styling | `lib/theme.dart` |
| Add a new screen | Create in `lib/screens/`, add to `AppScreen` enum in `lib/main.dart` |
| Add example sentences for words | `WordBank.sentences` map in `lib/models/word_bank.dart` |

## Testing

```bash
flutter test          # Unit tests
flutter analyze       # Static analysis
```

## Conventions
- Australian English spelling throughout (colour, not color; licence, not license)
- No external asset dependencies — all data is in-code
- Keep the UI minimal — no unnecessary animations or decorations
- Target audience is 5-year-olds — all text should be simple and encouraging
