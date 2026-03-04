import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum PatternPhase { preview, recall, result }

class PatternGameState extends ChangeNotifier {
  final _random = Random();

  // Settings
  int gridCols = 5;
  int gridRows = 5;
  int previewTimeMs = 1500;

  // State
  bool showStartScreen = true;
  int level = 1;
  PatternPhase phase = PatternPhase.preview;

  Set<int> targetPattern = {};
  Set<int> userSelection = {};
  int? wrongSelection;

  Timer? _timeout;

  int get gridSize => gridCols * gridRows;

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
    showStartScreen = false;
    level = 1;
    _startLevel();
  }

  void returnToStart() {
    _timeout?.cancel();
    showStartScreen = true;
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
    ScoreService.saveScore(ScoreEntry(
      gameId: 'pattern-memory',
      score: level - 1,
      date: DateTime.now(),
    ));
    notifyListeners();

    _timeout = Timer(const Duration(milliseconds: 1500), () {
      level = 1;
      _startLevel();
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }
}
