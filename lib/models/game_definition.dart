import 'package:flutter/material.dart';

class GameDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget Function() builder;
  final String scoreLabel;

  const GameDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.builder,
    this.scoreLabel = 'Punkte',
  });
}
