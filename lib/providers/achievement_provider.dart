import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/hive_datasource.dart';
import '../data/models/achievement_state.dart';
import 'initialization_provider.dart';

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<AchievementState>>((ref) {
  return AchievementNotifier(
    ref.watch(hiveDatasourceProvider),
    now: ref.read(clockProvider).now,
  );
});

class AchievementNotifier extends StateNotifier<List<AchievementState>> {
  final HiveDatasource? _datasource;
  final DateTime Function() _now;

  AchievementNotifier(
    this._datasource, {
    required DateTime Function() now,
  })  : _now = now,
        super([]) {
    _load();
  }

  AchievementNotifier.forTesting({
    required List<AchievementState> initialAchievements,
    DateTime Function()? now,
  })  : _datasource = null,
        _now = now ?? DateTime.now,
        super(initialAchievements);

  void _load() {
    final datasource = _datasource;
    if (datasource == null) return;
    final raw = datasource.gameStateBox.get('achievements_v2');
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw) as List;
        state = decoded
            .map(
              (entry) => AchievementState.fromJson(
                Map<String, dynamic>.from(entry as Map),
              ),
            )
            .toList();
        return;
      } on FormatException {
        // Fall through to a clean catalog if local JSON is malformed.
      }
    }
    state = AchievementCatalog.defaults();
  }

  Future<Set<String>> unlockAll(Iterable<String> ids) async {
    final requested = ids.toSet();
    final unlockedNow = <String>{};
    final previous = state;
    final updated = state.map((achievement) {
      if (!requested.contains(achievement.id) || achievement.unlocked) {
        return achievement;
      }
      unlockedNow.add(achievement.id);
      return achievement.copyUnlocked(at: _now());
    }).toList();
    if (unlockedNow.isEmpty) return const {};

    state = updated;
    try {
      await _save();
      return unlockedNow;
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<bool> unlock(String id) async => (await unlockAll([id])).contains(id);

  Future<void> _save() async {
    final datasource = _datasource;
    if (datasource == null) return;
    final encoded =
        jsonEncode(state.map((achievement) => achievement.toJson()).toList());
    await datasource.gameStateBox.put('achievements_v2', encoded);
  }

  bool isUnlocked(String id) =>
      state.any((achievement) => achievement.id == id && achievement.unlocked);

  int get unlockedCount =>
      state.where((achievement) => achievement.unlocked).length;
}
