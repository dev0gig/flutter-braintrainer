import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum SwitchPhase { start, playing, result }

enum Position { top, bottom }

enum SwitchAnswer { even, odd, less, greater }

class TrialResult {
  final int number;
  final Position position;
  final bool correct;
  final int reactionTimeMs;
  final bool wasSwitchTrial;

  const TrialResult({
    required this.number,
    required this.position,
    required this.correct,
    required this.reactionTimeMs,
    required this.wasSwitchTrial,
  });
}

class SwitchingGameState extends ChangeNotifier {
  final _random = Random();

  // Settings
  int totalTrials = 30;

  // Game state
  SwitchPhase phase = SwitchPhase.start;
  int currentNumber = 1;
  Position currentPosition = Position.top;
  int currentTrial = 0;
  bool showNumber = false;
  bool waitingForInput = false;

  // Feedback: null = none
  bool? feedback;

  // Results
  final List<TrialResult> _results = [];
  Position? _previousPosition;
  DateTime? _trialStartTime;
  Timer? _feedbackTimer;
  Timer? _nextTrialTimer;

  // Computed stats
  int get correctCount => _results.where((r) => r.correct).length;

  int get accuracy {
    if (_results.isEmpty) return 0;
    return (_results.where((r) => r.correct).length * 100 / _results.length).round();
  }

  int get avgReactionTime {
    final correct = _results.where((r) => r.correct).toList();
    if (correct.isEmpty) return 0;
    return (correct.fold<int>(0, (s, r) => s + r.reactionTimeMs) / correct.length).round();
  }

  int get avgSwitchTime {
    final sw = _results.where((r) => r.correct && r.wasSwitchTrial).toList();
    if (sw.isEmpty) return 0;
    return (sw.fold<int>(0, (s, r) => s + r.reactionTimeMs) / sw.length).round();
  }

  int get avgNonSwitchTime {
    final ns = _results.where((r) => r.correct && !r.wasSwitchTrial).toList();
    if (ns.isEmpty) return 0;
    return (ns.fold<int>(0, (s, r) => s + r.reactionTimeMs) / ns.length).round();
  }

  int get switchCost {
    final sw = avgSwitchTime;
    final ns = avgNonSwitchTime;
    if (sw == 0 || ns == 0) return 0;
    return sw - ns;
  }

  int get score {
    final speedFactor = avgReactionTime > 0
        ? max(0, 2000 - avgReactionTime) / 20
        : 0.0;
    return (accuracy * speedFactor).round();
  }

  String get scoreRating {
    final acc = accuracy;
    final avg = avgReactionTime;
    if (acc >= 95 && avg < 600) return 'Exzellent';
    if (acc >= 90 && avg < 800) return 'Sehr gut';
    if (acc >= 80 && avg < 1000) return 'Gut';
    if (acc >= 70) return 'Befriedigend';
    return 'Weiter üben';
  }

  void setTrials(int delta) {
    totalTrials = (totalTrials + delta).clamp(10, 60);
    notifyListeners();
  }

  void startGame() {
    _results.clear();
    _previousPosition = null;
    currentTrial = 0;
    feedback = null;
    showNumber = false;
    waitingForInput = false;
    phase = SwitchPhase.playing;
    notifyListeners();

    _nextTrialTimer = Timer(const Duration(milliseconds: 600), _nextTrial);
  }

  void returnToStart() {
    _cleanup();
    phase = SwitchPhase.start;
    notifyListeners();
  }

  void handleResponse(SwitchAnswer answer) {
    if (phase != SwitchPhase.playing || !waitingForInput) return;

    final reactionTime = DateTime.now().difference(_trialStartTime!).inMilliseconds;
    waitingForInput = false;

    bool correct = false;
    if (currentPosition == Position.top) {
      // Top: even/odd rule
      final isEven = currentNumber % 2 == 0;
      correct = (answer == SwitchAnswer.even && isEven) ||
          (answer == SwitchAnswer.odd && !isEven);
    } else {
      // Bottom: greater/less than 5
      final isGreater = currentNumber > 5;
      correct = (answer == SwitchAnswer.less && !isGreater) ||
          (answer == SwitchAnswer.greater && isGreater);
    }

    final wasSwitchTrial =
        _previousPosition != null && _previousPosition != currentPosition;

    _results.add(TrialResult(
      number: currentNumber,
      position: currentPosition,
      correct: correct,
      reactionTimeMs: reactionTime,
      wasSwitchTrial: wasSwitchTrial,
    ));

    feedback = correct;
    notifyListeners();

    _feedbackTimer = Timer(const Duration(milliseconds: 400), () {
      feedback = null;
      showNumber = false;
      notifyListeners();

      if (currentTrial >= totalTrials) {
        _endGame();
      } else {
        _nextTrialTimer = Timer(const Duration(milliseconds: 300), _nextTrial);
      }
    });
  }

  void _nextTrial() {
    currentTrial++;
    _previousPosition = currentPosition;

    // Random number 1-9 excluding 5
    const numbers = [1, 2, 3, 4, 6, 7, 8, 9];
    currentNumber = numbers[_random.nextInt(numbers.length)];

    // Random position ~50/50
    currentPosition = _random.nextBool() ? Position.top : Position.bottom;

    showNumber = true;
    waitingForInput = true;
    _trialStartTime = DateTime.now();
    notifyListeners();
  }

  void _endGame() {
    _cleanup();
    phase = SwitchPhase.result;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'switching-task',
      score: score,
      date: DateTime.now(),
      settings: {'trials': '$totalTrials'},
    ));
    notifyListeners();
  }

  void _cleanup() {
    _feedbackTimer?.cancel();
    _nextTrialTimer?.cancel();
    showNumber = false;
    waitingForInput = false;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
