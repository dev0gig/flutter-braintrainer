import 'package:flutter/material.dart';

import 'n_back_game_state.dart';
import 'n_back_start_view.dart';
import 'n_back_playing_view.dart';
import 'n_back_result_view.dart';

class NBackScreen extends StatefulWidget {
  const NBackScreen({super.key});

  @override
  State<NBackScreen> createState() => _NBackScreenState();
}

class _NBackScreenState extends State<NBackScreen> {
  final _state = NBackGameState();

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
      case NBackPhase.start:
        return NBackStartView(state: _state);
      case NBackPhase.playing:
        return NBackPlayingView(state: _state);
      case NBackPhase.result:
        return NBackResultView(state: _state);
    }
  }
}
