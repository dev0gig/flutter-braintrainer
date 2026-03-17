import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';

enum MemoryDifficulty {
  easy,   // 4x3 = 6 pairs
  medium, // 4x4 = 8 pairs
  hard,   // 5x6 = 15 pairs
}

enum MemoryPhase { start, playing, gameover }

class MemoryCard {
  final int id;
  final String symbol;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.symbol,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGameState extends ChangeNotifier {
  static const _symbolPool = [
    '▲', '■', '★', '●', '✖', '◆', '❖', '✚',
    '✷', '☀', '☾', '♥', '♦', '♠', '♣', '♫',
  ];

  final _random = Random();

  MemoryDifficulty difficulty = MemoryDifficulty.medium;
  MemoryPhase phase = MemoryPhase.start;

  List<MemoryCard> cards = [];
  List<int> _flippedIndices = [];
  int matchedCount = 0;
  int attempts = 0;
  bool _isChecking = false;

  // Stopwatch timer (counts up)
  int elapsedSeconds = 0;
  Timer? _countdownTimer;

  int get totalPairs {
    switch (difficulty) {
      case MemoryDifficulty.easy:
        return 6;
      case MemoryDifficulty.medium:
        return 8;
      case MemoryDifficulty.hard:
        return 15;
    }
  }

  int get gridCols {
    switch (difficulty) {
      case MemoryDifficulty.easy:
        return 4;  // 4x3
      case MemoryDifficulty.medium:
        return 4;  // 4x4
      case MemoryDifficulty.hard:
        return 5;  // 5x6
    }
  }

  bool get isWon => matchedCount == totalPairs;

  void setDifficulty(MemoryDifficulty d) {
    difficulty = d;
    notifyListeners();
  }

  String get timerDisplay {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void startGame() {
    attempts = 0;
    matchedCount = 0;
    _flippedIndices = [];
    _isChecking = false;
    elapsedSeconds = 0;
    _generateCards();
    phase = MemoryPhase.playing;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void returnToStart() {
    _countdownTimer?.cancel();
    phase = MemoryPhase.start;
    notifyListeners();
  }

  void onCardTap(int index) {
    if (phase != MemoryPhase.playing ||
        _isChecking ||
        _flippedIndices.length >= 2 ||
        cards[index].isFlipped ||
        cards[index].isMatched) {
      return;
    }

    cards[index].isFlipped = true;
    _flippedIndices.add(index);
    notifyListeners();

    if (_flippedIndices.length == 2) {
      attempts++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isChecking = true;
    final i1 = _flippedIndices[0];
    final i2 = _flippedIndices[1];

    if (cards[i1].symbol == cards[i2].symbol) {
      // Match
      Future.delayed(const Duration(milliseconds: 300), () {
        cards[i1].isMatched = true;
        cards[i2].isMatched = true;
        matchedCount++;
        _flippedIndices = [];
        _isChecking = false;
        if (isWon) {
          _endGame();
        }
        notifyListeners();
      });
    } else {
      // No match
      Future.delayed(const Duration(milliseconds: 1000), () {
        cards[i1].isFlipped = false;
        cards[i2].isFlipped = false;
        _flippedIndices = [];
        _isChecking = false;
        notifyListeners();
      });
    }
  }

  void _endGame() {
    _countdownTimer?.cancel();
    _isChecking = false;
    phase = MemoryPhase.gameover;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'memory-cards',
      score: elapsedSeconds,
      date: DateTime.now(),
      difficulty: difficulty.name,
      settings: {
        'difficulty': difficulty.name,
      },
    ));
    notifyListeners();
  }

  void _generateCards() {
    final symbols = _symbolPool.sublist(0, totalPairs);
    final gameCards = <MemoryCard>[];

    for (var i = 0; i < symbols.length; i++) {
      gameCards.add(MemoryCard(id: i * 2, symbol: symbols[i]));
      gameCards.add(MemoryCard(id: i * 2 + 1, symbol: symbols[i]));
    }

    // Fisher-Yates shuffle
    for (var i = gameCards.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = gameCards[i];
      gameCards[i] = gameCards[j];
      gameCards[j] = temp;
    }

    cards = gameCards;
  }
}
