import 'package:flutter/material.dart';

import 'anagram_game_state.dart';
import 'anagram_start_view.dart';
import 'anagram_playing_view.dart';
import 'anagram_result_view.dart';

class AnagramSolverScreen extends StatefulWidget {
  const AnagramSolverScreen({super.key});

  @override
  State<AnagramSolverScreen> createState() => _AnagramSolverScreenState();
}

class _AnagramSolverScreenState extends State<AnagramSolverScreen> {
  final _state = AnagramGameState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state.phase) {
      case GamePhase.start:
        return AnagramStartView(state: _state);
      case GamePhase.playing:
        return AnagramPlayingView(state: _state);
      case GamePhase.result:
        return AnagramResultView(state: _state);
    }
  }
}
