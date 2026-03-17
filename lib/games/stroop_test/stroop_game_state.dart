import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum StroopPhase { start, playing, gameover }

enum StroopDifficulty { normal, hard }

class StroopColor {
  final String label;
  final Color color;
  const StroopColor({required this.label, required this.color});
}

const stroopColors = [
  StroopColor(label: 'ROT', color: Colors.red),
  StroopColor(label: 'BLAU', color: Colors.blue),
  StroopColor(label: 'GRÜN', color: Colors.green),
  StroopColor(label: 'GELB', color: Color(0xFFDAA520)),
  StroopColor(label: 'LILA', color: Colors.purple),
  StroopColor(label: 'GRAU', color: Colors.grey),
];

class StroopRound {
  final String wordText;
  final Color wordColor;
  final int correctIndex;
  final List<StroopColor> options;
  final bool askForColor; // true = ask color, false = ask word text

  const StroopRound({
    required this.wordText,
    required this.wordColor,
    required this.correctIndex,
    required this.options,
    required this.askForColor,
  });
}

class StroopGameState extends ChangeNotifier {
  final _random = Random();

  StroopPhase phase = StroopPhase.start;
  StroopDifficulty difficulty = StroopDifficulty.normal;
  int maxRounds = 20;

  int currentRound = 0;
  int correctCount = 0;
  StroopRound? round;

  // Countdown timer
  static const int totalSeconds = 60;
  int remainingSeconds = totalSeconds;
  Timer? _countdownTimer;

  // Feedback state: null = no feedback, true = correct, false = wrong
  bool? feedback;
  int? selectedIndex;

  void setDifficulty(StroopDifficulty d) {
    difficulty = d;
    notifyListeners();
  }

  void setMaxRounds(int r) {
    maxRounds = r;
    notifyListeners();
  }

  String get timerDisplay {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void startGame() {
    currentRound = 0;
    correctCount = 0;
    feedback = null;
    selectedIndex = null;
    remainingSeconds = totalSeconds;
    phase = StroopPhase.playing;
    _generateRound();
    notifyListeners();

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
    _countdownTimer?.cancel();
    phase = StroopPhase.start;
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (feedback != null) return; // already answered

    selectedIndex = index;
    final isCorrect = index == round!.correctIndex;
    if (isCorrect) correctCount++;
    feedback = isCorrect;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      currentRound++;
      if (currentRound >= maxRounds) {
        _endGame();
      } else {
        _generateRound();
        feedback = null;
        selectedIndex = null;
        notifyListeners();
      }
    });
  }

  void _endGame() {
    _countdownTimer?.cancel();
    feedback = null;
    selectedIndex = null;
    phase = StroopPhase.gameover;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'stroop-test',
      score: correctCount,
      date: DateTime.now(),
      difficulty: difficulty.name,
      settings: {'difficulty': difficulty.name, 'rounds': '$maxRounds', 'timeLimit': '$totalSeconds'},
    ));
    notifyListeners();
  }

  void _generateRound() {
    // Determine if asking for color or word text
    final askForColor =
        difficulty == StroopDifficulty.normal ? true : _random.nextBool();

    // Pick the display color
    final colorIdx = _random.nextInt(stroopColors.length);
    final displayColor = stroopColors[colorIdx];

    // Pick the word text (70% mismatch for Stroop effect)
    String wordText;
    int wordTextIdx;
    if (_random.nextDouble() < 0.7) {
      // Mismatch: pick a different color's label
      wordTextIdx = (_random.nextInt(stroopColors.length - 1) + colorIdx + 1) %
          stroopColors.length;
      wordText = stroopColors[wordTextIdx].label;
    } else {
      wordTextIdx = colorIdx;
      wordText = displayColor.label;
    }

    // The correct answer depends on what we're asking
    final correctColorObj =
        askForColor ? displayColor : stroopColors[wordTextIdx];

    // Build 4 options: correct + 3 distractors
    final distractors = <StroopColor>[];
    final used = {stroopColors.indexOf(correctColorObj)};
    while (distractors.length < 3) {
      final idx = _random.nextInt(stroopColors.length);
      if (used.add(idx)) {
        distractors.add(stroopColors[idx]);
      }
    }

    final options = [correctColorObj, ...distractors];
    // Shuffle options
    for (var i = options.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = options[i];
      options[i] = options[j];
      options[j] = tmp;
    }

    final correctIndex = options.indexOf(correctColorObj);

    round = StroopRound(
      wordText: wordText,
      wordColor: displayColor.color,
      correctIndex: correctIndex,
      options: options,
      askForColor: askForColor,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
