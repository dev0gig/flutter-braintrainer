import 'dart:convert';

import 'package:flutter/services.dart';

enum PuzzleCategory { mateIn1, mateIn2, tactic }

const puzzleCategoryLabels = {
  PuzzleCategory.mateIn1: 'Matt in 1',
  PuzzleCategory.mateIn2: 'Matt in 2',
  PuzzleCategory.tactic: 'Taktik',
};

class ChessPuzzle {
  final String id;
  final String fen;
  final List<String> moves;
  final int rating;

  const ChessPuzzle({
    required this.id,
    required this.fen,
    required this.moves,
    required this.rating,
  });

  factory ChessPuzzle.fromJson(Map<String, dynamic> json) {
    return ChessPuzzle(
      id: json['id'] as String,
      fen: json['fen'] as String,
      moves: (json['moves'] as String).split(' '),
      rating: json['rating'] as int,
    );
  }
}

Map<PuzzleCategory, List<ChessPuzzle>>? _cachedPuzzles;

Future<Map<PuzzleCategory, List<ChessPuzzle>>> loadPuzzles() async {
  if (_cachedPuzzles != null) return _cachedPuzzles!;

  final jsonStr = await rootBundle.loadString('assets/puzzles.json');
  final data = json.decode(jsonStr) as Map<String, dynamic>;

  _cachedPuzzles = {
    for (final cat in PuzzleCategory.values)
      cat: (data[cat.name] as List<dynamic>)
          .map((e) => ChessPuzzle.fromJson(e as Map<String, dynamic>))
          .toList(),
  };
  return _cachedPuzzles!;
}
