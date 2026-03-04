import 'package:flutter/material.dart';

import 'math_game_state.dart';
import 'math_start_view.dart';
import 'math_playing_view.dart';
import 'math_result_view.dart';

class MathTrainerScreen extends StatefulWidget {
  const MathTrainerScreen({super.key});

  @override
  State<MathTrainerScreen> createState() => _MathTrainerScreenState();
}

class _MathTrainerScreenState extends State<MathTrainerScreen> {
  final _state = MathGameState();

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
      case MathPhase.start:
        return MathStartView(state: _state);
      case MathPhase.playing:
        return MathPlayingView(state: _state);
      case MathPhase.result:
        return MathResultView(state: _state);
      case MathPhase.sequenceMemorize:
        return SequenceMemorizeView(state: _state);
      case MathPhase.sequenceInput:
        return SequenceInputView(state: _state);
      case MathPhase.sequenceGameover:
        return SequenceGameoverView(state: _state);
    }
  }
}
