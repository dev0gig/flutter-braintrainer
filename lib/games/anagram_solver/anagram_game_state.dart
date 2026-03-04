import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import 'anagram_words.dart';

enum Difficulty { easy, medium, hard }

enum GamePhase { start, playing, result }

enum AnswerFeedback { none, correct, incorrect, skipped }

class LetterTile {
  final String letter;
  final int originalIndex;
  bool used;

  LetterTile({
    required this.letter,
    required this.originalIndex,
    this.used = false,
  });
}

class AnagramGameState extends ChangeNotifier {
  final _random = Random();

  Difficulty difficulty = Difficulty.easy;
  GamePhase phase = GamePhase.start;
  AnswerFeedback feedback = AnswerFeedback.none;
  int score = 0;
  int currentRound = 0;
  final int totalRounds = 10;
  AnagramWord currentWord = const AnagramWord(word: '', hint: '');
  List<LetterTile> scrambledTiles = [];
  List<LetterTile?> guessedLetters = [];
  bool showHint = false;
  int timeLeft = 0;

  Timer? _timer;

  String get instructions {
    switch (difficulty) {
      case Difficulty.easy:
        return '4–5 Buchstaben, mit Hinweis';
      case Difficulty.medium:
        return '5–8 Buchstaben, Hinweis optional';
      case Difficulty.hard:
        return '7–13 Buchstaben, ohne Hinweis';
    }
  }

  int get _timeForDifficulty {
    switch (difficulty) {
      case Difficulty.easy:
        return 30;
      case Difficulty.medium:
        return 25;
      case Difficulty.hard:
        return 30;
    }
  }

  List<AnagramWord> get _wordPool {
    switch (difficulty) {
      case Difficulty.easy:
        return easyWords;
      case Difficulty.medium:
        return mediumWords;
      case Difficulty.hard:
        return hardWords;
    }
  }

  void setDifficulty(Difficulty d) {
    difficulty = d;
    notifyListeners();
  }

  void startGame() {
    score = 0;
    currentRound = 0;
    feedback = AnswerFeedback.none;
    showHint = false;
    phase = GamePhase.playing;
    _nextWord();
  }

  void returnToStart() {
    _stopTimer();
    phase = GamePhase.start;
    notifyListeners();
  }

  void selectTile(LetterTile tile) {
    if (feedback != AnswerFeedback.none || tile.used) return;

    final emptyIdx = guessedLetters.indexOf(null);
    if (emptyIdx == -1) return;

    tile.used = true;
    guessedLetters[emptyIdx] = tile;
    notifyListeners();

    if (!guessedLetters.contains(null)) {
      _checkAnswer();
    }
  }

  void removeLetter(int index) {
    if (feedback != AnswerFeedback.none) return;

    final tile = guessedLetters[index];
    if (tile == null) return;

    tile.used = false;
    guessedLetters[index] = null;
    notifyListeners();
  }

  void toggleHint() {
    showHint = !showHint;
    notifyListeners();
  }

  void skipWord() {
    _stopTimer();
    feedback = AnswerFeedback.skipped;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () {
      feedback = AnswerFeedback.none;
      if (currentRound >= totalRounds) {
        _finishGame();
      } else {
        _nextWord();
      }
    });
  }

  void _checkAnswer() {
    final word = guessedLetters.map((t) => t?.letter ?? '').join();

    if (word == currentWord.word) {
      feedback = AnswerFeedback.correct;
      score++;
      _stopTimer();
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 1000), () {
        feedback = AnswerFeedback.none;
        if (currentRound >= totalRounds) {
          _finishGame();
        } else {
          _nextWord();
        }
      });
    } else {
      feedback = AnswerFeedback.incorrect;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 800), () {
        feedback = AnswerFeedback.none;
        _resetCurrentWord();
      });
    }
  }

  void _resetCurrentWord() {
    for (final tile in scrambledTiles) {
      tile.used = false;
    }
    guessedLetters = List.filled(currentWord.word.length, null);
    notifyListeners();
  }

  void _nextWord() {
    _stopTimer();
    currentRound++;
    showHint = false;

    final pool = _wordPool;
    currentWord = pool[_random.nextInt(pool.length)];

    final tiles = <LetterTile>[];
    for (var i = 0; i < currentWord.word.length; i++) {
      tiles.add(LetterTile(letter: currentWord.word[i], originalIndex: i));
    }

    // Fisher-Yates shuffle
    for (var i = tiles.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = tiles[i];
      tiles[i] = tiles[j];
      tiles[j] = temp;
    }

    scrambledTiles = tiles;
    guessedLetters = List.filled(currentWord.word.length, null);

    timeLeft = _timeForDifficulty;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeLeft--;
      if (timeLeft <= 0) {
        _onTimeUp();
      } else {
        notifyListeners();
      }
    });
  }

  void _onTimeUp() {
    _stopTimer();
    feedback = AnswerFeedback.skipped;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () {
      feedback = AnswerFeedback.none;
      if (currentRound >= totalRounds) {
        _finishGame();
      } else {
        _nextWord();
      }
    });
  }

  void _finishGame() {
    _stopTimer();
    phase = GamePhase.result;
    ScoreService.saveScore(ScoreEntry(
      gameId: 'anagram-solver',
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
