import 'package:flutter/material.dart';

import 'stroop_game_state.dart';
import 'stroop_start_view.dart';
import 'stroop_playing_view.dart';

class StroopTestScreen extends StatefulWidget {
  const StroopTestScreen({super.key});

  @override
  State<StroopTestScreen> createState() => _StroopTestScreenState();
}

class _StroopTestScreenState extends State<StroopTestScreen> {
  final _state = StroopGameState();

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
      case StroopPhase.start:
        return StroopStartView(state: _state);
      case StroopPhase.playing:
        return StroopPlayingView(state: _state);
      case StroopPhase.gameover:
        return StroopGameoverView(state: _state);
    }
  }
}
