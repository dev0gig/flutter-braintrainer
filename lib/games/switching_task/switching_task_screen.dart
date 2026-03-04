import 'package:flutter/material.dart';

import 'switching_game_state.dart';
import 'switching_start_view.dart';
import 'switching_playing_view.dart';

class SwitchingTaskScreen extends StatefulWidget {
  const SwitchingTaskScreen({super.key});

  @override
  State<SwitchingTaskScreen> createState() => _SwitchingTaskScreenState();
}

class _SwitchingTaskScreenState extends State<SwitchingTaskScreen> {
  final _state = SwitchingGameState();

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
      case SwitchPhase.start:
        return SwitchingStartView(state: _state);
      case SwitchPhase.playing:
        return SwitchingPlayingView(state: _state);
      case SwitchPhase.result:
        return SwitchingResultView(state: _state);
    }
  }
}
