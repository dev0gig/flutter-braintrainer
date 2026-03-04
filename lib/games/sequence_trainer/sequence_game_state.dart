import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum SeqDifficulty { easy, medium, hard }

enum SeqPhase { start, memorize, input, gameover }

class SequenceRule {
  final String operation; // '+' or '-'
  final int value;
  const SequenceRule({required this.operation, required this.value});

  @override
  String toString() => '$operation$value';
}

class SequenceGameState extends ChangeNotifier {
  final _random = Random();

  SeqDifficulty difficulty = SeqDifficulty.medium;
  int maxRounds = 10;
  SeqPhase phase = SeqPhase.start;

  int startNumber = 0;
  SequenceRule rule = const SequenceRule(operation: '+', value: 0);
  List<int> currentSequence = [];
  String userInput = '';
  int score = 0;

  Timer? _timer;

  void setDifficulty(SeqDifficulty d) {
    difficulty = d;
    notifyListeners();
  }

  void adjustRounds(int delta) {
    maxRounds = (maxRounds + delta).clamp(10, 30);
    notifyListeners();
  }

  void startGame() {
    score = 0;
    userInput = '';
    currentSequence = [];
    _generateLevelData();
    phase = SeqPhase.memorize;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      phase = SeqPhase.input;
      notifyListeners();
    });
  }

  void returnToStart() {
    _timer?.cancel();
    phase = SeqPhase.start;
    notifyListeners();
  }

  void appendNumber(int num) {
    if (userInput.length < 6) {
      userInput += num.toString();
      notifyListeners();
    }
  }

  void backspace() {
    if (userInput.isNotEmpty) {
      userInput = userInput.substring(0, userInput.length - 1);
      notifyListeners();
    }
  }

  void confirmInput() {
    if (userInput.isEmpty) return;

    final inputVal = int.tryParse(userInput);
    if (inputVal == null) return;

    final lastVal = currentSequence.last;
    final expected = rule.operation == '+'
        ? lastVal + rule.value
        : lastVal - rule.value;

    if (inputVal == expected) {
      currentSequence.add(inputVal);
      score++;
      userInput = '';
      notifyListeners();

      if (score >= maxRounds) {
        phase = SeqPhase.gameover;
        ScoreService.saveScore(ScoreEntry(
          gameId: 'sequence',
          score: score,
          date: DateTime.now(),
          difficulty: difficulty.name,
        ));
        notifyListeners();
      }
    } else {
      phase = SeqPhase.gameover;
      ScoreService.saveScore(ScoreEntry(
        gameId: 'sequence',
        score: score,
        date: DateTime.now(),
        difficulty: difficulty.name,
      ));
      notifyListeners();
    }
  }

  void _generateLevelData() {
    int startVal;
    int ruleVal;
    String op;

    switch (difficulty) {
      case SeqDifficulty.easy:
        startVal = _random.nextInt(20) + 1;
        ruleVal = _random.nextInt(9) + 1;
        op = '+';
      case SeqDifficulty.medium:
        startVal = _random.nextInt(51) + 20;
        ruleVal = _random.nextInt(90) + 10;
        op = _random.nextBool() ? '+' : '-';
      case SeqDifficulty.hard:
        startVal = _random.nextInt(101) + 50;
        const candidates = [13, 17, 19, 23, 29, 31, 37, 43, 47];
        ruleVal = candidates[_random.nextInt(candidates.length)];
        op = _random.nextBool() ? '+' : '-';
    }

    startNumber = startVal;
    currentSequence = [startVal];
    rule = SequenceRule(operation: op, value: ruleVal);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
