import 'package:flutter/material.dart';

class GameDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget Function() builder;
  final String scoreLabel;
  final bool lowerIsBetter;
  final bool Function(Map<String, String>? settings)? isLowerBetterFn;

  const GameDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.builder,
    this.scoreLabel = 'Punkte',
    this.lowerIsBetter = false,
    this.isLowerBetterFn,
  });

  bool isLowerBetterFor(Map<String, String>? settings) {
    if (isLowerBetterFn != null) return isLowerBetterFn!(settings);
    return lowerIsBetter;
  }
}
