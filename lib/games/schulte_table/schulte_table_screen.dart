import 'package:flutter/material.dart';

import 'schulte_game_state.dart';
import 'schulte_start_view.dart';
import 'schulte_playing_view.dart';

class SchulteTableScreen extends StatefulWidget {
  const SchulteTableScreen({super.key});

  @override
  State<SchulteTableScreen> createState() => _SchulteTableScreenState();
}

class _SchulteTableScreenState extends State<SchulteTableScreen> {
  final _state = SchulteGameState();

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
    if (_state.showStartScreen) {
      return SchulteStartView(state: _state);
    }
    return SchultePlayingView(state: _state);
  }
}
