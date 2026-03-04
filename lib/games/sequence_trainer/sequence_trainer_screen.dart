import 'package:flutter/material.dart';

import 'sequence_game_state.dart';
import 'sequence_start_view.dart';
import 'sequence_playing_view.dart';

class SequenceTrainerScreen extends StatefulWidget {
  const SequenceTrainerScreen({super.key});

  @override
  State<SequenceTrainerScreen> createState() => _SequenceTrainerScreenState();
}

class _SequenceTrainerScreenState extends State<SequenceTrainerScreen> {
  final _state = SequenceGameState();

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
      case SeqPhase.start:
        return SequenceStartView(state: _state);
      case SeqPhase.memorize:
        return SequenceMemorizeView(state: _state);
      case SeqPhase.input:
        return SequenceInputView(state: _state);
      case SeqPhase.gameover:
        return SequenceGameoverView(state: _state);
    }
  }
}
