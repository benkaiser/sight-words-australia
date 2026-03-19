# Sight Words Australia

A bare-bones, efficient sight words learning app for Australian kids in Prep/Foundation (age ~5). Built with Flutter for iOS and Android.

## What it does

- Teaches the **Oxford Wordlist** — 200 high-frequency sight words across 10 progressive levels
- **Optional placement test** on first launch so kids who already know some words can skip ahead
- **Spaced repetition** ensures words are reviewed at the right time to build long-term memory
- **Four activity types** keep learning varied: flash cards, word matching, spell-by-tapping, and fill-in-the-sentence
- **Progress tracking** with per-level breakdowns, mastery counts, session streaks, and accuracy stats
- **Text-to-speech** using Australian English (`en-AU`) via `flutter_tts`
- **Local persistence** via `shared_preferences` — progress saves between sessions, no account needed

## Design philosophy

- **Bare-bones but effective** — no mascots, no flashy animations, no gamification gimmicks
- **Warm & gentle** visual style — soft colours, rounded shapes, large readable text
- **Progress is the reward** — kids see their mastery grow through stats and level unlocks

## Getting started

```bash
# Prerequisites: Flutter SDK installed
flutter pub get
flutter run
```

## Project structure

```
lib/
├── main.dart                    # App entry point and navigation shell
├── theme.dart                   # Warm & gentle theme (colours, typography)
├── models/
│   ├── sight_word.dart          # SightWord model, WordProgress, MasteryLevel
│   └── word_bank.dart           # Oxford Wordlist data (200 words, 10 levels)
├── screens/
│   ├── home_screen.dart         # Home with stats summary and session launcher
│   ├── placement_screen.dart    # Optional initial assessment
│   ├── session_screen.dart      # Learning session with 4 activity types
│   └── progress_screen.dart     # Detailed per-level progress view
├── services/
│   ├── progress_service.dart    # Spaced repetition engine, persistence, stats
│   └── tts_service.dart         # Text-to-speech wrapper (Australian English)
```

## Tech stack

- **Flutter** (iOS + Android)
- **provider** for state management
- **shared_preferences** for local persistence
- **flutter_tts** for text-to-speech

## Word levels

| Level | Description |
|-------|-------------|
| 1-2   | Most common words (I, a, the, and, is, she, you...) |
| 3-4   | Common words (they, this, with, into, just, some...) |
| 5-6   | Expanding vocabulary (play, school, because, people...) |
| 7-8   | Building fluency (before, another, children, brother...) |
| 9-10  | Extended words (always, thought, different, important...) |

Levels unlock when 80% of the current level's words are mastered.

## Licence

MIT
