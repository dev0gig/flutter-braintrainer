import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';

class ScoreEntry {
  final String gameId;
  final int score;
  final DateTime date;
  final String? difficulty;
  final Map<String, String>? settings;

  ScoreEntry({
    required this.gameId,
    required this.score,
    required this.date,
    this.difficulty,
    this.settings,
  });

  /// Key for grouping scores by settings combination.
  String get settingsKey {
    if (settings == null || settings!.isEmpty) {
      // Fall back to difficulty for old entries
      return difficulty ?? '';
    }
    final sorted = settings!.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => '${e.key}=${e.value}').join('|');
  }

  Map<String, dynamic> toMap() => {
        'gameId': gameId,
        'score': score,
        'date': date.toIso8601String(),
        'difficulty': difficulty,
        if (settings != null) 'settings': settings,
      };

  factory ScoreEntry.fromMap(Map<dynamic, dynamic> map) => ScoreEntry(
        gameId: map['gameId'] as String,
        score: map['score'] as int,
        date: DateTime.parse(map['date'] as String),
        difficulty: map['difficulty'] as String?,
        settings: map['settings'] != null
            ? (map['settings'] as Map).cast<String, String>()
            : null,
      );
}

/// Human-readable label for a settings combination.
String settingsLabel(String gameId, Map<String, String>? settings, String? difficulty) {
  if (settings != null && settings.isNotEmpty) {
    return settings.entries.map((e) => _formatValue(gameId, e.key, e.value)).join(' · ');
  }
  if (difficulty != null && difficulty.isNotEmpty) {
    return _translateDifficulty(difficulty);
  }
  return 'Ohne Einstellungen';
}

String _translateDifficulty(String d) {
  return switch (d) {
    'easy' => 'Leicht',
    'medium' => 'Mittel',
    'hard' => 'Schwer',
    'normal' => 'Normal',
    _ => d,
  };
}

String _formatValue(String gameId, String key, String value) {
  return switch (key) {
    'difficulty' => _translateDifficulty(value),
    'mode' => switch (value) {
        'classic' => 'Klassisch',
        'chain' => 'Kette',
        'computer' => 'Computer',
        'puzzle' => 'Puzzle',
        _ => value,
      },
    'grid' => 'Raster $value',
    'preview' => '${value}ms',
    'nLevel' => 'N=$value',
    'speed' => '${value}ms',
    'trials' => '$value Durchgänge',
    'rounds' => '$value Runden',
    'gridSize' => '${value}×$value',
    _ => '$key: $value',
  };
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
