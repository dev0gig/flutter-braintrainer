import 'package:flutter/material.dart';

import 'wcst_game_state.dart';
import 'wcst_start_view.dart';
import 'wcst_playing_view.dart';

class WcstScreen extends StatefulWidget {
  const WcstScreen({super.key});

  @override
  State<WcstScreen> createState() => _WcstScreenState();
}

class _WcstScreenState extends State<WcstScreen> {
  final _state = WcstGameState();

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
      case WcstPhase.start:
        return WcstStartView(state: _state);
      case WcstPhase.playing:
        return WcstPlayingView(state: _state);
      case WcstPhase.result:
        return WcstResultView(state: _state);
    }
  }
}
