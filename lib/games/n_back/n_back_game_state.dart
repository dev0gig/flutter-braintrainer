import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';


enum NBackPhase { start, playing, result }

class Trial {
  final int position; // 0-8 on 3x3 grid
  final bool isTarget;
  const Trial({required this.position, required this.isTarget});
}

class NBackGameState extends ChangeNotifier {
  final _random = Random();

  // Settings
  int nLevel = 2;
  int speed = 2500; // ms
  int totalTrials = 20;

  // Game state
  NBackPhase phase = NBackPhase.start;
  int currentTrial = 0;
  int? activePosition;
  bool showingStimulus = false;

  // Results
  int hits = 0;
  int misses = 0;
  int falseAlarms = 0;
  int correctRejections = 0;

  // Internal
  List<Trial> _trials = [];
  bool _responded = false;
  Timer? _trialTimer;
  Timer? _stimulusTimer;

  String get speedLabel {
    switch (speed) {
      case 1500:
        return 'Schnell';
      case 2500:
        return 'Normal';
      case 3500:
        return 'Langsam';
      default:
        return '';
    }
  }

  int get accuracy {
    final total = hits + misses + falseAlarms + correctRejections;
    if (total == 0) return 0;
    return ((hits + correctRejections) / total * 100).round();
  }

  void setNLevel(int n) {
    nLevel = n.clamp(1, 4);
    notifyListeners();
  }

  void setSpeed(int ms) {
    speed = ms;
    notifyListeners();
  }

  void setTotalTrials(int count) {
    totalTrials = count.clamp(10, 50);
    notifyListeners();
  }

  void startGame() {
    hits = 0;
    misses = 0;
    falseAlarms = 0;
    correctRejections = 0;
    currentTrial = 0;
    _responded = false;

    _generateTrials();
    phase = NBackPhase.playing;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () => _runNextTrial());
  }

  void returnToStart() {
    _cleanup();
    phase = NBackPhase.start;
    notifyListeners();
  }

  void respond() {
    if (phase != NBackPhase.playing || _responded || !showingStimulus) return;
    _responded = true;

    final trial = _trials[currentTrial - 1];
    if (trial.isTarget) {
      hits++;
    } else {
      falseAlarms++;
    }
    notifyListeners();
  }

  void _generateTrials() {
    final n = nLevel;
    _trials = [];
    final positions = <int>[];

    for (var i = 0; i < totalTrials; i++) {
      if (i >= n && _random.nextDouble() < 0.33) {
        // Target: same position as n steps back
        final pos = positions[i - n];
        positions.add(pos);
        _trials.add(Trial(position: pos, isTarget: true));
      } else {
        // Non-target
        int pos;
        do {
          pos = _random.nextInt(9);
        } while (i >= n && pos == positions[i - n]);
        positions.add(pos);
        _trials.add(Trial(position: pos, isTarget: false));
      }
    }
  }

  void _runNextTrial() {
    final idx = currentTrial;
    if (idx >= _trials.length) {
      _endGame();
      return;
    }

    // Evaluate previous trial if unanswered
    if (idx > 0 && !_responded) {
      final prevTrial = _trials[idx - 1];
      if (prevTrial.isTarget) {
        misses++;
      } else {
        correctRejections++;
      }
    }

    _responded = false;
    currentTrial = idx + 1;

    final trial = _trials[idx];
    activePosition = trial.position;
    showingStimulus = true;
    notifyListeners();

    // Show stimulus for 60% of interval
    final stimulusDuration = (speed * 0.6).round();
    _stimulusTimer = Timer(Duration(milliseconds: stimulusDuration), () {
      activePosition = null;
      showingStimulus = false;
      notifyListeners();
    });

    // Next trial after full interval
    _trialTimer = Timer(Duration(milliseconds: speed), () {
      _runNextTrial();
    });
  }

  void _endGame() {
    // Evaluate last trial
    if (!_responded) {
      final lastTrial = _trials.last;
      if (lastTrial.isTarget) {
        misses++;
      } else {
        correctRejections++;
      }
    }

    _cleanup();
    phase = NBackPhase.result;
    notifyListeners();
  }

  void _cleanup() {
    _trialTimer?.cancel();
    _trialTimer = null;
    _stimulusTimer?.cancel();
    _stimulusTimer = null;
    activePosition = null;
    showingStimulus = false;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
