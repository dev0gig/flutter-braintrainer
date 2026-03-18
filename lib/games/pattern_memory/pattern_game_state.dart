import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum PatternPhase { preview, recall, result }
enum PatternGamePhase { start, playing, gameover }

class PatternGameState extends ChangeNotifier {
  final _random = Random();

  // Settings
  int gridCols = 5;
  int gridRows = 5;
  int previewTimeMs = 1500;

  // State
  PatternGamePhase gamePhase = PatternGamePhase.start;
  int level = 1;
  int completedLevels = 0;
  PatternPhase phase = PatternPhase.preview;

  Set<int> targetPattern = {};
  Set<int> userSelection = {};
  int? wrongSelection;

  // Countdown timer
  static const int totalSeconds = 60;
  int remainingSeconds = totalSeconds;
  Timer? _countdownTimer;

  Timer? _timeout;

  int get gridSize => gridCols * gridRows;

  String get timerDisplay {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get squaresCount {
    const base = 4;
    final cap = (gridSize * 0.45).floor();
    return min(cap, base + level);
  }

  String get previewLabel {
    switch (previewTimeMs) {
      case 500:
        return 'Sehr schnell';
      case 1000:
        return 'Schnell';
      case 1500:
        return 'Normal';
      case 2000:
        return 'Langsam';
      default:
        return '';
    }
  }

  void setGridSize(int cols, int rows) {
    gridCols = cols;
    gridRows = rows;
    notifyListeners();
  }

  void setPreviewTime(int ms) {
    previewTimeMs = ms;
    notifyListeners();
  }

  void startGame() {
    gamePhase = PatternGamePhase.playing;
    level = 1;
    completedLevels = 0;
    remainingSeconds = totalSeconds;
    _startLevel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        remainingSeconds = 0;
        _endGame();
      }
      notifyListeners();
    });
  }

  void returnToStart() {
    _timeout?.cancel();
    _countdownTimer?.cancel();
    gamePhase = PatternGamePhase.start;
    notifyListeners();
  }

  void handleCellTap(int index) {
    if (phase != PatternPhase.recall) return;
    if (userSelection.contains(index)) return;

    if (targetPattern.contains(index)) {
      userSelection = {...userSelection, index};
      notifyListeners();

      if (userSelection.length == targetPattern.length) {
        _handleLevelComplete();
      }
    } else {
      _handleMistake(index);
    }
  }

  void _startLevel() {
    _timeout?.cancel();

    phase = PatternPhase.preview;
    userSelection = {};
    wrongSelection = null;

    // Generate pattern
    final pattern = <int>{};
    while (pattern.length < squaresCount) {
      pattern.add(_random.nextInt(gridSize));
    }
    targetPattern = pattern;
    notifyListeners();

    _timeout = Timer(Duration(milliseconds: previewTimeMs), () {
      phase = PatternPhase.recall;
      notifyListeners();
    });
  }

  void _handleLevelComplete() {
    completedLevels++;
    phase = PatternPhase.result;
    notifyListeners();

    _timeout = Timer(const Duration(milliseconds: 1000), () {
      level++;
      _startLevel();
    });
  }

  void _handleMistake(int index) {
    wrongSelection = index;
    phase = PatternPhase.result;
    notifyListeners();

    _timeout = Timer(const Duration(milliseconds: 1500), () {
      level = 1;
      _startLevel();
    });
  }

  void _endGame() {
    _timeout?.cancel();
    _countdownTimer?.cancel();
    gamePhase = PatternGamePhase.gameover;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'pattern-memory',
      score: completedLevels,
      date: DateTime.now(),
      settings: {'grid': '${gridCols}x$gridRows', 'preview': '$previewTimeMs', 'timeLimit': '$totalSeconds'},
    ));
    notifyListeners();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
