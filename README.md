# BrainTrainer

Eine Gehirntraining-App mit Fokus auf kognitive Fähigkeiten wie Arbeitsgedächtnis, Aufmerksamkeit, kognitive Flexibilität und Verarbeitungsgeschwindigkeit.

> **Hinweis:** Diese App wurde ausschließlich durch Vibe Coding mit [Claude Code](https://claude.com/claude-code) entwickelt. Der Entwickler selbst kann nicht programmieren — sämtlicher Code wurde vollständig von KI geschrieben.

## Spiele

### Mathe Trainer
Kopfrechnen unter Zeitdruck (60 Sekunden). Zwei Modi: **Klassisch** (zufällige Aufgaben) und **Kette** (Ergebnis wird nächster Operand). Drei Schwierigkeitsstufen von einfacher Addition bis Division mit großen Zahlen.

### Sudoku
Klassisches 9x9 Logikrätsel. Prozedural generierte Rätsel mit garantiert eindeutiger Lösung. Notiz-Modus für Kandidaten, Fehlerhervorhebung bei leichteren Stufen. Drei Schwierigkeitsgrade.

### Paare Finden (Memory)
Karten aufdecken und Paare finden. Raster von 4x3 (leicht) bis 5x6 (schwer). Gewertet wird die Anzahl der Versuche — weniger ist besser.

### N-Back
Standardisierter Arbeitsgedächtnistest. Eine Position wird auf einem Raster angezeigt — reagieren, wenn sie mit der Position von N Schritten zuvor übereinstimmt. N-Level 1–4, einstellbare Geschwindigkeit und Anzahl der Durchgänge.

### Muster Merken (Pattern Memory)
Visuelles Muster kurz einprägen, dann aus dem Gedächtnis nachtippen. Die Muster werden mit jedem Level komplexer. Ein Fehler beendet das Spiel.

### Schulte-Tabelle
Zahlen 1 bis N in einem Raster so schnell wie möglich der Reihe nach antippen. Rastergröße von 3x3 bis 7x7 einstellbar. Gewertet wird die benötigte Zeit.

### Sequenz
Eine Startzahl und eine Rechenregel merken, dann die nächsten Werte der Reihe eingeben. Drei Schwierigkeitsgrade mit unterschiedlichen Zahlenräumen und Regeln (inkl. Primzahlen auf Stufe Schwer).

### Stroop-Test
Klassischer neuropsychologischer Test. Ein Farbwort wird in einer anderen Farbe angezeigt — die richtige Farbe (nicht das Wort) auswählen. Im schweren Modus wird zufällig nach Farbe oder Wortbedeutung gefragt.

### Task Switching
Kognitive Flexibilität trainieren. Oben: Gerade/Ungerade beurteilen. Unten: Größer/Kleiner als 5 beurteilen. Die Zahl wechselt zufällig die Position — schnelles Umschalten zwischen den Regeln ist gefragt.

### WCST (Wisconsin Card Sorting Test)
Karten nach einer unbekannten Regel sortieren (Farbe, Form oder Anzahl). Die Regel wechselt nach einigen richtigen Antworten ohne Vorwarnung. Misst kognitive Flexibilität und die Fähigkeit, aus Feedback zu lernen.

### Schach
Schachpuzzles lösen oder gegen den Computer spielen. KI basiert auf Minimax mit Alpha-Beta-Pruning. Drei Schwierigkeitsstufen.

### Anagramme
Buchstaben eines durcheinander gewürfelten Wortes in die richtige Reihenfolge bringen. Zeitlimit pro Wort. Wortlänge von 4 bis 13 Buchstaben je nach Schwierigkeit.

## Statistik & Fortschritt

- Alle Spielergebnisse werden lokal gespeichert
- Statistik-Übersicht mit Filtermöglichkeit: Letzte Woche, Letzter Monat, Gesamtzeitraum
- Verlaufsgraphen pro Spiel zeigen den Fortschritt über Zeit
- Export und Import der Ergebnisse als JSON
- Alle Daten zurücksetzen möglich

## Technologie

- Flutter mit Material Design 3 und Dynamic Colors (Material You)
- Lokale Datenspeicherung mit Hive
- Responsive Layouts für Smartphones und Tablets
- Komplett in Deutsch
