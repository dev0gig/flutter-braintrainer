import 'package:flutter/material.dart';

import 'chess_game_state.dart';
import 'chess_start_view.dart';
import 'chess_playing_view.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  final _state = ChessGameState();

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
    if (_state.phase == ChessPhase.start) {
      return ChessStartView(state: _state);
    }
    return ChessPlayingView(state: _state);
  }
}
