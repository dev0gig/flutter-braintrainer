# BrainTrainer — Datenmodelle

## GameDefinition

```dart
class GameDefinition {
    final String id;                        // Eindeutige Spiel-ID
    final String name;                      // Anzeigename
    final String description;               // Kurzbeschreibung
    final IconData icon;                    // Material Icon
    final Widget Function() builder;        // Screen-Builder
    final String scoreLabel;                // Score-Label (default: 'Punkte')
}
```

## ScoreEntry

```dart
class ScoreEntry {
    final String gameId;                    // Spiel-ID
    final int score;                        // Punktzahl
    final DateTime date;                    // Zeitstempel
    final String? difficulty;               // Schwierigkeit (legacy)
    final Map<String, String>? settings;    // Spielspezifische Einstellungen

    String get settingsKey;                 // Gruppierungsschlüssel
    Map<String, dynamic> toMap();
    factory ScoreEntry.fromMap(Map<String, dynamic>);
}
```

> `settingsKey` gruppiert Scores nach Einstellungen (z.B. "difficulty:hard|mode:chain"). Wird für die Statistik-Ansicht genutzt.

## Hive-Struktur

```
Box 'scores':
  [
    { gameId, score, date (ISO), difficulty?, settings? },
    ...
  ]

Box 'game_state':
  {
    "sudoku": { grid, solution, notes, difficulty, ... },
    "chess": { fen, moves, difficulty, ... },
  }
```

## Spiel-IDs & Score-Typen

| Spiel-ID | Score-Typ | Bedeutung |
|---|---|---|
| `math-trainer` | Punkte | Richtige Antworten (60s) |
| `sudoku` | Punkte | 1 pro gelöstem Rätsel |
| `memory-cards` | Versuche | Weniger = besser (invers) |
| `n-back` | Prozent | Genauigkeit (Hits + Correct Rejections) |
| `pattern-memory` | Level | Erreichtes Level |
| `schulte-table` | Sekunden | Benötigte Zeit |
| `stroop-test` | Punkte | Richtige Antworten |
| `switching-task` | Score | Accuracy × Speed Factor |
| `wcst` | Prozent | Genauigkeit |
| `chess` | Punkte | Gelöste Puzzles |
| `anagram-solver` | Punkte | Richtige Wörter (von 10) |

## Spiel-Schwierigkeiten

| Spiel | Leicht | Mittel | Schwer |
|---|---|---|---|
| Math Trainer | +/- bis 20 | ×/÷ bis 100 | Alle Ops, große Zahlen |
| Sudoku | 39 entfernt | 49 entfernt | 57 entfernt |
| Memory | 4×3 Grid | 4×4 Grid | 5×6 Grid |
| N-Back | N=1-4, Speed 1.5-3.5s | - | - |
| Pattern Memory | Vorschau 0.5-2s | - | - |
| Schulte | 3×3 bis 7×7 | - | - |
| Stroop | Nur Farbe | - | Farbe oder Wortbedeutung |
| Anagram | 4-5 Buchstaben | 5-8 Buchstaben | 7-13 Buchstaben |
| Chess | Tiefe 1 | Tiefe 2 | Tiefe 3 |
