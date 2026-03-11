# BrainTrainer — Technical Stack

## Kern-Technologien

| Technologie | Version | Zweck |
|---|---|---|
| Flutter | SDK ^3.11.0 | Framework |
| Dart | ^3.11.0 | Sprache |
| Material Design 3 | - | UI mit Dynamic Colors (Material You) |
| dynamic_color | ^1.7.0 | System-Farbschema |
| hive_ce | ^2.10.0 | Lokale NoSQL-Datenbank |
| hive_ce_flutter | ^2.2.0 | Hive Flutter-Integration |
| chess | ^0.8.0 | Schach-Logik & Zugvalidierung |
| share_plus | ^11.0.0 | Daten-Export (JSON teilen) |
| file_picker | ^9.0.0 | Daten-Import |
| path_provider | ^2.1.0 | Dateisystem-Zugriff |
| material_symbols_icons | ^4.2815.0 | Icon-Set |

## Architektur

- **State Management:** `ChangeNotifier` (kein Provider/Bloc/Riverpod)
- **Persistenz:** Hive NoSQL (2 Boxes: `scores`, `game_state`)
- **Kein Backend** — Vollständig offline
- **Sprache:** Deutsch (hardcoded)

## State Management Pattern

```dart
class GameScreen extends StatefulWidget {
    final _state = GameState();  // ChangeNotifier

    void initState() {
        _state.addListener(_onStateChanged);
    }

    Widget build(context) {
        switch (_state.phase) {
            case Phase.start: return StartView(state: _state);
            case Phase.playing: return PlayingView(state: _state);
            case Phase.result: return ResultView(state: _state);
        }
    }
}
```

## Datenpersistenz

| Hive Box | Inhalt |
|---|---|
| `scores` | Liste von ScoreEntry-Maps (alle Spielergebnisse) |
| `game_state` | Spielstand pro Game-ID (Sudoku, Schach) |

## Export/Import

- **Export:** `ScoreService.exportJson()` → JSON → Temp-File → `share_plus`
- **Import:** `file_picker` → JSON → `ScoreService.importJson()` mit Duplikat-Erkennung

## Theming

- Material Design 3 mit `DynamicColorBuilder`
- Fallback Seed Color: `#2196F3` (Blau)
- System Light/Dark Mode
