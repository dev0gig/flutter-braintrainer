import 'package:flutter/material.dart';

import 'pattern_game_state.dart';
import 'pattern_start_view.dart';
import 'pattern_playing_view.dart';

class PatternMemoryScreen extends StatefulWidget {
  const PatternMemoryScreen({super.key});

  @override
  State<PatternMemoryScreen> createState() => _PatternMemoryScreenState();
}

class _PatternMemoryScreenState extends State<PatternMemoryScreen> {
  final _state = PatternGameState();

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
    switch (_state.gamePhase) {
      case PatternGamePhase.start:
        return PatternStartView(state: _state);
      case PatternGamePhase.playing:
        return PatternPlayingView(state: _state);
      case PatternGamePhase.gameover:
        return PatternGameoverView(state: _state);
    }
  }
}
