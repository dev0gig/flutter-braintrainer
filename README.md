# BrainTrainer — Kognitives Training

Eine Gehirntraining-App mit 11 Spielen für Arbeitsgedächtnis, Aufmerksamkeit, kognitive Flexibilität und Verarbeitungsgeschwindigkeit. Gebaut mit Flutter, vollständig offline.

> Entwickelt durch Vibe Coding mit [Claude Code](https://claude.com/claude-code).

## Was kann BrainTrainer?

### Spiele (11)

- **Mathe Trainer** — Kopfrechnen unter Zeitdruck (60s). Modi: Klassisch, Kette (Ergebnis = nächster Operand), Sequenz (Reihe fortsetzen). 3 Schwierigkeitsstufen.
- **Sudoku** — Prozedural generiert mit garantiert eindeutiger Lösung. Notiz-Modus, Fehlerhervorhebung. Spielstand wird gespeichert.
- **Paare Finden** — Memory mit 4×3 bis 5×6 Grid. Weniger Versuche = besser.
- **N-Back** — Arbeitsgedächtnistest. Position erkennen, die N Schritte zurückliegt. N=1-4, einstellbare Geschwindigkeit.
- **Muster Merken** — Visuelles Muster einprägen und nachtippen. Komplexität steigt pro Level. Ein Fehler = Game Over.
- **Schulte-Tabelle** — Zahlen 1-N in Reihenfolge antippen. 3×3 bis 7×7 Grid. Gewertet wird die Zeit.
- **Stroop-Test** — Farbwort in falscher Farbe — richtige Farbe auswählen. Schwerer Modus fragt zufällig nach Farbe oder Wortbedeutung.
- **Task Switching** — Oben: Gerade/Ungerade. Unten: Größer/Kleiner 5. Position wechselt zufällig.
- **WCST** — Karten nach unbekannter Regel sortieren. Regel wechselt ohne Vorwarnung nach einigen richtigen Antworten.
- **Schach** — Puzzles lösen (Lichess) oder gegen KI spielen (Minimax mit Alpha-Beta-Pruning). 3 Schwierigkeitsgrade.
- **Anagramme** — Buchstaben in richtige Reihenfolge bringen. 10 Wörter pro Runde, Zeitlimit. 4-13 Buchstaben je nach Schwierigkeit.

### Statistik & Fortschritt

- Alle Ergebnisse lokal gespeichert (Hive)
- Zeitfilter: Letzte Woche, Letzter Monat, Gesamt
- Verlaufsgraphen pro Spiel (CustomPaint)
- Gruppierung nach Einstellungen/Schwierigkeit
- Best, Durchschnitt, Anzahl pro Kombination
- JSON Export/Import mit Duplikat-Erkennung

## Tech-Stack

| Technologie | Zweck |
|---|---|
| Flutter + Dart | Framework |
| Material Design 3 | UI mit Dynamic Colors (Material You) |
| Hive CE | Lokale Datenspeicherung |
| chess.dart | Schach-Logik |

## Build

```bash
flutter build apk --release
```

Responsive: Smartphone (Drawer) und Tablet (Sidebar).
Komplett in Deutsch. Kein Internet nötig.
