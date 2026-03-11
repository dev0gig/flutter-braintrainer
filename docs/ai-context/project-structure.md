# BrainTrainer — Projektstruktur

## Verzeichnisübersicht

```
flutter-braintrainer/
├── lib/
│   ├── main.dart                      # Entry Point, Theme-Setup (Material 3 + Dynamic Colors)
│   ├── models/
│   │   └── game_definition.dart       # Spiel-Metadaten (ID, Name, Icon, Builder)
│   ├── services/
│   │   ├── score_service.dart         # Score-Persistenz (Hive)
│   │   └── game_state_service.dart    # Spielstand-Persistenz (Hive)
│   ├── screens/
│   │   ├── home_screen.dart           # Hauptnavigation & Spielauswahl
│   │   └── scores_screen.dart         # Statistiken & Fortschritt
│   ├── widgets/
│   │   └── game_placeholder.dart      # Platzhalter für kommende Spiele
│   └── games/                         # 11 Spiel-Implementierungen
│       ├── anagram_solver/            # Anagramme lösen
│       ├── chess/                     # Schach (Puzzle + vs. Computer)
│       ├── math_trainer/              # Kopfrechnen (3 Modi)
│       ├── memory_match/              # Paare finden
│       ├── n_back/                    # N-Back Arbeitsgedächtnis
│       ├── pattern_memory/            # Muster merken
│       ├── schulte_table/             # Schulte-Tabelle (Zahlen tippen)
│       ├── stroop_test/               # Stroop-Test (Farbe vs. Wort)
│       ├── sudoku/                    # Sudoku (generiert, eindeutig)
│       ├── switching_task/            # Task Switching
│       └── wcst/                      # Wisconsin Card Sorting Test
├── assets/
│   └── puzzles.json                   # Schach-Puzzles (Lichess)
└── pubspec.yaml
```

## Spiel-Architektur (pro Spiel)

Jedes Spiel folgt demselben Pattern:

```
game_name/
├── game_name_screen.dart          # StatefulWidget (Phase-Switch)
├── game_name_game_state.dart      # ChangeNotifier (Spiellogik)
├── game_name_start_view.dart      # Einstellungen / Schwierigkeit
├── game_name_playing_view.dart    # Spielfeld-UI
└── game_name_result_view.dart     # Ergebnis-Anzeige
```

**Phase-basiertes UI:**
```
Start (Einstellungen) → Playing (Spiel) → Result (Ergebnis)
```

## Navigation

- **HomeScreen** — Spielauswahl (Drawer auf Mobile, Sidebar auf Tablet)
- **ScoresScreen** — Statistiken mit Zeitfilter und Verlaufsgraphen
- **Game Screens** — Jedes Spiel als eigener Screen

## Responsive Layout

- **Mobile (< 600px):** Drawer-Navigation (Hamburger-Menü)
- **Tablet (≥ 600px):** 300px feste Sidebar + Spielbereich
