import 'package:flutter/material.dart';

import 'memory_game_state.dart';
import 'memory_start_view.dart';
import 'memory_playing_view.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final _state = MemoryGameState();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state.phase) {
      case MemoryPhase.start:
        return MemoryStartView(state: _state);
      case MemoryPhase.playing:
        return MemoryPlayingView(state: _state);
    }
  }
}
