import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum MathDifficulty { easy, medium, hard }

enum MathMode { classic, chain }

enum MathPhase { start, playing, result }

enum MathFeedback { none, correct, incorrect }

class Question {
  final String text;
  final int answer;
  const Question({required this.text, required this.answer});
}

class MathGameState extends ChangeNotifier {
  final _random = Random();

  MathDifficulty difficulty = MathDifficulty.easy;
  MathMode mode = MathMode.classic;
  MathPhase phase = MathPhase.start;
  MathFeedback feedback = MathFeedback.none;

  int timeLeft = 60;
  int score = 0;
  Question currentQuestion = const Question(text: 'Bereit?', answer: 0);
  String userAnswer = '';

  int _chainValue = 0;
  Timer? _timer;

  String get instructions {
    if (mode == MathMode.chain) {
      switch (difficulty) {
        case MathDifficulty.easy:
          return 'Kettenrechnen: +/− kleine Zahlen';
        case MathDifficulty.medium:
          return 'Kettenrechnen: +/− mittlere Zahlen';
        case MathDifficulty.hard:
          return 'Kettenrechnen: +/−/× gemischt';
      }
    }
    switch (difficulty) {
      case MathDifficulty.easy:
        return 'Addition & Subtraktion bis 20';
      case MathDifficulty.medium:
        return 'Add/Sub bis 100, kleines Einmaleins';
      case MathDifficulty.hard:
        return 'Mult/Div bis 100, zweistellige Addition';
    }
  }

  int _rand(int min, int max) =>
      min + _random.nextInt(max - min + 1);

  void setDifficulty(MathDifficulty d) {
    difficulty = d;
    notifyListeners();
  }

  void setMode(MathMode m) {
    mode = m;
    notifyListeners();
  }

  void startGame() {
    score = 0;
    timeLeft = 60;
    userAnswer = '';
    feedback = MathFeedback.none;
    phase = MathPhase.playing;

    if (mode == MathMode.chain) {
      _chainValue = difficulty == MathDifficulty.easy
          ? _rand(5, 15)
          : _rand(10, 30);
    }

    _generateQuestion();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeLeft--;
      if (timeLeft <= 0) {
        _endGame();
      } else {
        notifyListeners();
      }
    });
  }

  void returnToStart() {
    _stopTimer();
    phase = MathPhase.start;
    notifyListeners();
  }

  void appendNumber(int num) {
    if (feedback == MathFeedback.incorrect) {
      feedback = MathFeedback.none;
      userAnswer = num.toString();
    } else {
      userAnswer += num.toString();
    }
    notifyListeners();
  }

  void backspace() {
    feedback = MathFeedback.none;
    if (userAnswer.isNotEmpty) {
      userAnswer = userAnswer.substring(0, userAnswer.length - 1);
    }
    notifyListeners();
  }

  void submitAnswer() {
    final input = int.tryParse(userAnswer);
    if (input == null) return;

    if (input == currentQuestion.answer) {
      feedback = MathFeedback.correct;
      score++;
      userAnswer = '';

      if (mode == MathMode.chain) {
        _chainValue = input;
      }

      notifyListeners();

      Future.delayed(const Duration(milliseconds: 150), () {
        feedback = MathFeedback.none;
        _generateQuestion();
        notifyListeners();
      });
    } else {
      feedback = MathFeedback.incorrect;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () {
        feedback = MathFeedback.none;
        notifyListeners();
      });
    }
  }

  void _generateQuestion() {
    if (mode == MathMode.chain) {
      _generateChainQuestion();
    } else {
      _generateClassicQuestion();
    }
  }

  void _generateChainQuestion() {
    final cv = _chainValue;
    Question q;

    switch (difficulty) {
      case MathDifficulty.easy:
        if (cv > 5 && _random.nextDouble() > 0.4) {
          final b = _rand(1, min(cv - 1, 10));
          q = Question(text: '$cv − $b', answer: cv - b);
        } else {
          final b = _rand(1, min(10, 30 - cv));
          q = Question(text: '$cv + $b', answer: cv + b);
        }
      case MathDifficulty.medium:
        if (cv > 10 && _random.nextDouble() > 0.4) {
          final b = _rand(2, min(cv - 2, 25));
          q = Question(text: '$cv − $b', answer: cv - b);
        } else {
          final b = _rand(2, min(25, 100 - cv));
          q = Question(text: '$cv + $b', answer: cv + b);
        }
      case MathDifficulty.hard:
        final type = _random.nextDouble();
        if (type < 0.35 && cv > 5) {
          final b = _rand(3, min(cv - 2, 30));
          q = Question(text: '$cv − $b', answer: cv - b);
        } else if (type < 0.7) {
          final b = _rand(3, min(30, 150 - cv));
          q = Question(text: '$cv + $b', answer: cv + b);
        } else if (cv <= 15 && cv >= 2) {
          final b = _rand(2, 6);
          q = Question(text: '$cv × $b', answer: cv * b);
        } else {
          if (cv > 10) {
            final b = _rand(3, min(cv - 2, 20));
            q = Question(text: '$cv − $b', answer: cv - b);
          } else {
            final b = _rand(3, 20);
            q = Question(text: '$cv + $b', answer: cv + b);
          }
        }
    }

    currentQuestion = q;
  }

  void _generateClassicQuestion() {
    Question q;

    switch (difficulty) {
      case MathDifficulty.easy:
        if (_random.nextDouble() > 0.5) {
          final a = _rand(1, 10);
          final b = _rand(1, 10);
          q = Question(text: '$a + $b', answer: a + b);
        } else {
          final a = _rand(2, 20);
          final b = _rand(1, a);
          q = Question(text: '$a − $b', answer: a - b);
        }
      case MathDifficulty.medium:
        final type = _random.nextDouble();
        if (type < 0.4) {
          final a = _rand(10, 80);
          final b = _rand(5, 100 - a);
          q = Question(text: '$a + $b', answer: a + b);
        } else if (type < 0.8) {
          final a = _rand(20, 100);
          final b = _rand(5, a - 5);
          q = Question(text: '$a − $b', answer: a - b);
        } else {
          final a = _rand(2, 9);
          final b = _rand(2, 9);
          q = Question(text: '$a × $b', answer: a * b);
        }
      case MathDifficulty.hard:
        final type = _random.nextDouble();
        if (type < 0.3) {
          final a = _rand(25, 75);
          final b = _rand(25, 75);
          q = Question(text: '$a + $b', answer: a + b);
        } else if (type < 0.6) {
          final a = _rand(3, 12);
          final b = _rand(3, 12);
          q = Question(text: '$a × $b', answer: a * b);
        } else {
          final b = _rand(2, 9);
          final res = _rand(2, 12);
          final a = b * res;
          q = Question(text: '$a : $b', answer: res);
        }
    }

    currentQuestion = q;
  }

  void _endGame() {
    _stopTimer();
    timeLeft = 0;
    phase = MathPhase.result;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'math-trainer',
      score: score,
      date: DateTime.now(),
      difficulty: difficulty.name,
    ));
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
