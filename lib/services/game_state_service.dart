import 'package:hive_ce/hive_ce.dart';

class GameStateService {
  static const _boxName = 'game_state';

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  static Future<void> saveState(String gameId, Map<String, dynamic> state) async {
    final box = await _openBox();
    await box.put(gameId, state);
  }

  static Future<Map<String, dynamic>?> loadState(String gameId) async {
    final box = await _openBox();
    final data = box.get(gameId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<void> clearState(String gameId) async {
    final box = await _openBox();
    await box.delete(gameId);
  }

  static Future<bool> hasState(String gameId) async {
    final box = await _openBox();
    return box.containsKey(gameId);
  }
}
