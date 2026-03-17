import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/game_state_service.dart';
import '../../services/score_service.dart';

enum SudokuDifficulty { easy, medium, hard }

enum SudokuPhase { start, playing }

// Top-level functions for compute() isolate

Map<String, List<int>> _generatePuzzleIsolate(SudokuDifficulty difficulty) {
  final random = Random();
  final grid = List.filled(81, 0);
  _fillGrid(grid, random);
  final solution = List<int>.from(grid);

  final cellsToRemove = switch (difficulty) {
    SudokuDifficulty.easy => 39,
    SudokuDifficulty.medium => 49,
    SudokuDifficulty.hard => 57,
  };

  final indices = List.generate(81, (i) => i)..shuffle(random);
  var removed = 0;
  for (final index in indices) {
    if (removed >= cellsToRemove) break;
    final backup = grid[index];
    grid[index] = 0;
    if (_countSolutions(List.from(grid)) == 1) {
      removed++;
    } else {
      grid[index] = backup;
    }
  }

  return {'grid': grid, 'solution': solution};
}

bool _fillGrid(List<int> board, Random random) {
  final emptyIndex = board.indexOf(0);
  if (emptyIndex == -1) return true;

  final numbers = List.generate(9, (i) => i + 1)..shuffle(random);
  for (final num in numbers) {
    if (_isValid(board, emptyIndex, num)) {
      board[emptyIndex] = num;
      if (_fillGrid(board, random)) return true;
      board[emptyIndex] = 0;
    }
  }
  return false;
}

int _countSolutions(List<int> board) {
  final emptyIndex = board.indexOf(0);
  if (emptyIndex == -1) return 1;

  var count = 0;
  for (var num = 1; num <= 9; num++) {
    if (_isValid(board, emptyIndex, num)) {
      board[emptyIndex] = num;
      count += _countSolutions(board);
      if (count > 1) {
        board[emptyIndex] = 0;
        return count;
      }
      board[emptyIndex] = 0;
    }
  }
  return count;
}

bool _isValid(List<int> board, int index, int number) {
  final row = index ~/ 9;
  final col = index % 9;

  for (var c = 0; c < 9; c++) {
    if (board[row * 9 + c] == number) return false;
  }
  for (var r = 0; r < 9; r++) {
    if (board[r * 9 + col] == number) return false;
  }

  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;
  for (var r = boxRow; r < boxRow + 3; r++) {
    for (var c = boxCol; c < boxCol + 3; c++) {
      if (board[r * 9 + c] == number) return false;
    }
  }
  return true;
}

class SudokuGameState extends ChangeNotifier {
  SudokuPhase phase = SudokuPhase.start;
  SudokuDifficulty difficulty = SudokuDifficulty.easy;

  List<int> grid = List.filled(81, 0);
  List<bool> initialGrid = List.filled(81, false);
  List<int> solution = List.filled(81, 0);
  List<List<int>> notes = List.generate(81, (_) => []);

  int? selectedCell;
  bool isNoteMode = false;
  bool isComplete = false;

  // Stopwatch
  int elapsedSeconds = 0;
  Timer? _stopwatchTimer;

  String get elapsedFormatted {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;
  }

  String get difficultyLabel {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return 'Leicht';
      case SudokuDifficulty.medium:
        return 'Mittel';
      case SudokuDifficulty.hard:
        return 'Schwer';
    }
  }

  bool isGenerating = false;

  Future<void> startGame(SudokuDifficulty diff) async {
    difficulty = diff;
    isComplete = false;
    isNoteMode = false;
    selectedCell = null;
    notes = List.generate(81, (_) => []);
    elapsedSeconds = 0;
    _stopStopwatch();
    isGenerating = true;
    notifyListeners();

    final result = await compute(_generatePuzzleIsolate, diff);
    grid = result['grid']!;
    solution = result['solution']!;
    initialGrid = List.generate(81, (i) => grid[i] != 0);

    isGenerating = false;
    phase = SudokuPhase.playing;
    _startStopwatch();
    notifyListeners();
    _saveState();
  }

  void returnToStart() {
    _stopStopwatch();
    phase = SudokuPhase.start;
    notifyListeners();
  }

  Future<bool> tryResume() async {
    final data = await GameStateService.loadState('sudoku');
    if (data == null) return false;

    grid = List<int>.from(data['grid'] as List);
    solution = List<int>.from(data['solution'] as List);
    initialGrid = List<bool>.from(data['initialGrid'] as List);
    notes = (data['notes'] as List)
        .map((e) => List<int>.from(e as List))
        .toList();
    difficulty = SudokuDifficulty.values.byName(data['difficulty'] as String);
    isNoteMode = data['isNoteMode'] as bool;
    elapsedSeconds = (data['elapsedSeconds'] as int?) ?? 0;
    isComplete = false;
    selectedCell = null;
    isGenerating = false;
    phase = SudokuPhase.playing;
    _startStopwatch();
    notifyListeners();
    return true;
  }

  void _saveState() {
    if (phase != SudokuPhase.playing || isComplete) return;
    GameStateService.saveState('sudoku', {
      'grid': grid,
      'solution': solution,
      'initialGrid': initialGrid,
      'notes': notes,
      'difficulty': difficulty.name,
      'isNoteMode': isNoteMode,
      'elapsedSeconds': elapsedSeconds,
    });
  }

  void selectCell(int index) {
    if (isComplete) return;
    selectedCell = index;
    notifyListeners();
  }

  void toggleNoteMode() {
    isNoteMode = !isNoteMode;
    notifyListeners();
  }

  void inputNumber(int number) {
    if (selectedCell == null || isComplete) return;
    if (initialGrid[selectedCell!]) return;

    if (isNoteMode) {
      final cellNotes = List<int>.from(notes[selectedCell!]);
      if (cellNotes.contains(number)) {
        cellNotes.remove(number);
      } else {
        cellNotes.add(number);
        cellNotes.sort();
      }
      notes[selectedCell!] = cellNotes;
      grid[selectedCell!] = 0;
    } else {
      grid[selectedCell!] = number;
      notes[selectedCell!] = [];
      _checkCompletion();
    }
    notifyListeners();
    _saveState();
  }

  void clearCell() {
    if (selectedCell == null || isComplete) return;
    if (initialGrid[selectedCell!]) return;

    grid[selectedCell!] = 0;
    notes[selectedCell!] = [];
    notifyListeners();
    _saveState();
  }

  bool isError(int index) {
    if (difficulty == SudokuDifficulty.hard) return false;
    if (grid[index] == 0) return false;
    if (initialGrid[index]) return false;
    return grid[index] != solution[index];
  }

  int? get highlightNumber {
    if (difficulty == SudokuDifficulty.hard) return null;
    if (selectedCell == null) return null;
    final val = grid[selectedCell!];
    return val > 0 ? val : null;
  }

  bool isHighlighted(int index) {
    final hn = highlightNumber;
    if (hn == null) return false;
    return grid[index] == hn && index != selectedCell;
  }

  bool isValidPlacement(int index, int number) {
    final row = index ~/ 9;
    final col = index % 9;

    // Check row
    for (var c = 0; c < 9; c++) {
      if (c != col && grid[row * 9 + c] == number) return false;
    }
    // Check column
    for (var r = 0; r < 9; r++) {
      if (r != row && grid[r * 9 + col] == number) return false;
    }
    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if (r * 9 + c != index && grid[r * 9 + c] == number) return false;
      }
    }
    return true;
  }

  void _checkCompletion() {
    for (var i = 0; i < 81; i++) {
      if (grid[i] != solution[i]) return;
    }
    isComplete = true;
    _stopStopwatch();
    GameStateService.clearState('sudoku');
    ScoreService.saveScore(ScoreEntry(
      gameId: 'sudoku',
      score: elapsedSeconds,
      date: DateTime.now(),
      difficulty: difficulty.name,
      settings: {
        'difficulty': difficulty.name,
        'elapsedSeconds': '$elapsedSeconds',
      },
    ));
  }

  @override
  void dispose() {
    _stopStopwatch();
    super.dispose();
  }
}
