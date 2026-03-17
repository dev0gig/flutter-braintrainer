import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum WcstPhase { start, playing, result }

enum SortRule { color, shape, number }

enum CardColor { red, green, blue, yellow }

enum CardShape { circle, triangle, star, cross }

class WcstCard {
  final CardColor color;
  final CardShape shape;
  final int count;

  const WcstCard({required this.color, required this.shape, required this.count});
}

const referenceCards = [
  WcstCard(color: CardColor.red, shape: CardShape.triangle, count: 1),
  WcstCard(color: CardColor.green, shape: CardShape.star, count: 2),
  WcstCard(color: CardColor.blue, shape: CardShape.cross, count: 3),
  WcstCard(color: CardColor.yellow, shape: CardShape.circle, count: 4),
];

Color wcstColorValue(CardColor c) {
  switch (c) {
    case CardColor.red: return const Color(0xFFEF4444);
    case CardColor.green: return const Color(0xFF22C55E);
    case CardColor.blue: return const Color(0xFF3B82F6);
    case CardColor.yellow: return const Color(0xFFEAB308);
  }
}

class WcstGameState extends ChangeNotifier {
  final _random = Random();
  static const totalCards = 64;

  WcstPhase phase = WcstPhase.start;
  WcstCard currentCard = const WcstCard(color: CardColor.red, shape: CardShape.circle, count: 1);

  // null = none, true = correct, false = incorrect
  bool? feedback;

  // Countdown timer
  static const int totalSeconds = 120;
  int remainingSeconds = totalSeconds;
  Timer? _countdownTimer;

  int cardsPlayed = 0;
  int correctCount = 0;
  int errorCount = 0;
  int perseverativeErrors = 0;
  int categoriesCompleted = 0;
  int _currentStreak = 0;

  SortRule _currentRule = SortRule.color;
  SortRule? _previousRule;
  late List<SortRule> _ruleOrder;
  int _ruleIndex = 0;
  int _correctToSwitch = 10;

  Timer? _feedbackTimer;

  int get accuracy {
    if (cardsPlayed == 0) return 0;
    return (correctCount * 100 / cardsPlayed).round();
  }

  String get flexibilityRating {
    final cats = categoriesCompleted;
    if (cats >= 6) return 'Exzellent';
    if (cats >= 4) return 'Sehr gut';
    if (cats >= 2) return 'Gut';
    if (cats >= 1) return 'Befriedigend';
    return 'Weiter üben';
  }

  String get timerDisplay {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void startGame() {
    cardsPlayed = 0;
    correctCount = 0;
    errorCount = 0;
    perseverativeErrors = 0;
    categoriesCompleted = 0;
    _currentStreak = 0;
    feedback = null;
    _previousRule = null;
    remainingSeconds = totalSeconds;

    _ruleOrder = _generateRuleOrder();
    _ruleIndex = 0;
    _currentRule = _ruleOrder[0];
    _correctToSwitch = _nextThreshold();

    phase = WcstPhase.playing;
    _generateCard();
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
    _feedbackTimer?.cancel();
    phase = WcstPhase.start;
    notifyListeners();
  }

  void selectReference(int refIndex) {
    if (phase != WcstPhase.playing || feedback != null) return;

    final ref = referenceCards[refIndex];
    final card = currentCard;

    final matchedColor = ref.color == card.color;
    final matchedShape = ref.shape == card.shape;
    final matchedCount = ref.count == card.count;

    bool isCorrect;
    switch (_currentRule) {
      case SortRule.color: isCorrect = matchedColor;
      case SortRule.shape: isCorrect = matchedShape;
      case SortRule.number: isCorrect = matchedCount;
    }

    cardsPlayed++;

    if (isCorrect) {
      feedback = true;
      correctCount++;
      _currentStreak++;

      if (_currentStreak >= _correctToSwitch) {
        categoriesCompleted++;
        _currentStreak = 0;
        _switchRule();
        _correctToSwitch = _nextThreshold();
      }
    } else {
      feedback = false;
      errorCount++;
      _currentStreak = 0;

      // Check for perseverative error
      if (_previousRule != null) {
        bool matchedOldRule;
        switch (_previousRule!) {
          case SortRule.color: matchedOldRule = matchedColor;
          case SortRule.shape: matchedOldRule = matchedShape;
          case SortRule.number: matchedOldRule = matchedCount;
        }
        if (matchedOldRule) perseverativeErrors++;
      }
    }
    notifyListeners();

    _feedbackTimer = Timer(const Duration(milliseconds: 600), () {
      feedback = null;
      if (cardsPlayed >= totalCards) {
        _endGame();
      } else {
        _generateCard();
      }
      notifyListeners();
    });
  }

  void _generateCard() {
    const colors = CardColor.values;
    const shapes = CardShape.values;
    const counts = [1, 2, 3, 4];

    WcstCard card;
    var attempts = 0;
    do {
      card = WcstCard(
        color: colors[_random.nextInt(4)],
        shape: shapes[_random.nextInt(4)],
        count: counts[_random.nextInt(4)],
      );
      attempts++;
    } while (attempts < 50 && !_isValidCard(card));

    currentCard = card;
  }

  bool _isValidCard(WcstCard card) {
    final colorMatch = referenceCards.indexWhere((r) => r.color == card.color);
    final shapeMatch = referenceCards.indexWhere((r) => r.shape == card.shape);
    final countMatch = referenceCards.indexWhere((r) => r.count == card.count);

    if (colorMatch == -1 || shapeMatch == -1 || countMatch == -1) return false;

    // At least 2 dimensions should point to different reference cards
    return {colorMatch, shapeMatch, countMatch}.length >= 2;
  }

  void _switchRule() {
    _previousRule = _currentRule;
    _ruleIndex++;
    if (_ruleIndex < _ruleOrder.length) {
      _currentRule = _ruleOrder[_ruleIndex];
    }
  }

  List<SortRule> _generateRuleOrder() {
    const base = [SortRule.color, SortRule.shape, SortRule.number];
    return [for (var i = 0; i < 4; i++) ...base];
  }

  int _nextThreshold() => _random.nextInt(3) + 4;

  void _endGame() {
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    phase = WcstPhase.result;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'wcst',
      score: accuracy,
      date: DateTime.now(),
      settings: {'timeLimit': '$totalSeconds'},
    ));
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
