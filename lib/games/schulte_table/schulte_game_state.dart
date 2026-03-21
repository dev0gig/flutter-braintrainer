import 'dart:math';

import 'package:flutter/material.dart';


class SchulteGameState extends ChangeNotifier {
  final _random = Random();
  final Stopwatch _stopwatch = Stopwatch();

  int gridSize = 5;
  List<int> cells = [];
  int nextNumber = 1;
  bool showStartScreen = true;
  bool isGameActive = false;
  bool gameCompleted = false;
  int? lastCorrectCell;
  String timerDisplay = '0.00';

  int get totalNumbers => gridSize * gridSize;

  void setGridSize(int size) {
    gridSize = size.clamp(3, 7);
    notifyListeners();
  }

  void startGame() {
    showStartScreen = false;
    _resetGame();
    isGameActive = true;
    _stopwatch.reset();
    _stopwatch.start();
    _tick();
    notifyListeners();
  }

  void returnToStart() {
    _stopwatch.stop();
    showStartScreen = true;
    isGameActive = false;
    gameCompleted = false;
    notifyListeners();
  }

  void handleCellClick(int number, int index) {
    if (!isGameActive || gameCompleted) return;

    if (number == nextNumber) {
      lastCorrectCell = index;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 200), () {
        lastCorrectCell = null;
        notifyListeners();
      });

      if (number == totalNumbers) {
        _finishGame();
      } else {
        nextNumber++;
        notifyListeners();
      }
    }
  }

  void resetGame() {
    _resetGame();
    isGameActive = true;
    _stopwatch.reset();
    _stopwatch.start();
    _tick();
    notifyListeners();
  }

  void _resetGame() {
    _stopwatch.stop();
    isGameActive = false;
    gameCompleted = false;
    nextNumber = 1;
    timerDisplay = '0.00';
    lastCorrectCell = null;
    _generateGrid();
  }

  void _generateGrid() {
    final numbers = List.generate(totalNumbers, (i) => i + 1);
    // Fisher-Yates shuffle
    for (var i = numbers.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = numbers[i];
      numbers[i] = numbers[j];
      numbers[j] = temp;
    }
    cells = numbers;
  }

  void _tick() {
    if (!_stopwatch.isRunning) return;
    timerDisplay = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 30), _tick);
  }

  void _finishGame() {
    _stopwatch.stop();
    timerDisplay = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
    gameCompleted = true;
    isGameActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}
