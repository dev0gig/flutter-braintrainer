import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';

class ScoreEntry {
  final String gameId;
  final int score;
  final DateTime date;
  final String? difficulty;

  ScoreEntry({
    required this.gameId,
    required this.score,
    required this.date,
    this.difficulty,
  });

  Map<String, dynamic> toMap() => {
        'gameId': gameId,
        'score': score,
        'date': date.toIso8601String(),
        'difficulty': difficulty,
      };

  factory ScoreEntry.fromMap(Map<dynamic, dynamic> map) => ScoreEntry(
        gameId: map['gameId'] as String,
        score: map['score'] as int,
        date: DateTime.parse(map['date'] as String),
        difficulty: map['difficulty'] as String?,
      );
}

class ScoreService {
  static const _boxName = 'scores';

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  static Future<void> saveScore(ScoreEntry entry) async {
    final box = await _openBox();
    await box.add(entry.toMap());
  }

  static Future<List<ScoreEntry>> getScores(String gameId) async {
    final box = await _openBox();
    return box.values
        .cast<Map>()
        .where((m) => m['gameId'] == gameId)
        .map((m) => ScoreEntry.fromMap(m))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<Map<String, List<ScoreEntry>>> getAllScores() async {
    final box = await _openBox();
    final map = <String, List<ScoreEntry>>{};
    for (final m in box.values.cast<Map>()) {
      final entry = ScoreEntry.fromMap(m);
      (map[entry.gameId] ??= []).add(entry);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.date.compareTo(b.date));
    }
    return map;
  }

  static Future<ScoreEntry?> getLatestScore(String gameId) async {
    final scores = await getScores(gameId);
    return scores.isEmpty ? null : scores.first;
  }

  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }

  static Future<String> exportJson() async {
    final box = await _openBox();
    final entries = box.values.cast<Map>().map((m) => ScoreEntry.fromMap(m).toMap()).toList();
    return jsonEncode(entries);
  }

  static Future<int> importJson(String jsonString) async {
    final box = await _openBox();
    final List<dynamic> imported = jsonDecode(jsonString) as List<dynamic>;

    // Build set of existing entries for duplicate detection
    final existing = <String>{};
    for (final m in box.values.cast<Map>()) {
      final e = ScoreEntry.fromMap(m);
      existing.add('${e.gameId}|${e.date.toIso8601String()}|${e.score}');
    }

    var count = 0;
    for (final item in imported) {
      final map = item as Map<String, dynamic>;
      final entry = ScoreEntry.fromMap(map);
      final key = '${entry.gameId}|${entry.date.toIso8601String()}|${entry.score}';
      if (!existing.contains(key)) {
        await box.add(entry.toMap());
        existing.add(key);
        count++;
      }
    }
    return count;
  }
}
