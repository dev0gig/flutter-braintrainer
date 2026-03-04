import 'package:flutter/material.dart';

import 'sudoku_game_state.dart';
import 'sudoku_start_view.dart';
import 'sudoku_playing_view.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final _state = SudokuGameState();

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
      case SudokuPhase.start:
        return SudokuStartView(state: _state);
      case SudokuPhase.playing:
        return SudokuPlayingView(state: _state);
    }
  }
}
