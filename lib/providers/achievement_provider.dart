import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/hive_datasource.dart';
import '../data/models/achievement_state.dart';
import 'initialization_provider.dart';

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<AchievementState>>((ref) {
  final ds = ref.watch(hiveDatasourceProvider);
  return AchievementNotifier(ds);
});

class AchievementNotifier extends StateNotifier<List<AchievementState>> {
  final HiveDatasource? _ds;

  AchievementNotifier(this._ds) : super([]) {
    _load();
  }

  @visibleForTesting
  AchievementNotifier.forTesting({
    required List<AchievementState> initialAchievements,
  })  : _ds = null,
        super(initialAchievements);

  void _load() {
    final ds = _ds;
    if (ds == null) return;

    final raw = ds.gameStateBox.get('achievements');
    if (raw != null) {
      final list = jsonDecode(raw as String) as List;
      state = list
          .map((e) => AchievementState.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      state = AchievementCatalog.defaults();
      _save();
    }
  }

  void _save() {
    final ds = _ds;
    if (ds == null) return;

    try {
      final json = jsonEncode(state.map((a) => a.toJson()).toList());
      ds.gameStateBox.put('achievements', json);
    } catch (e) {
      debugPrint('[AchievementNotifier] Failed to save achievements: $e');
    }
  }

  void unlock(String id) {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx >= 0 && !state[idx].unlocked) {
      final prev = state;
      state = [...state]..[idx] = state[idx].copyUnlocked();
      try {
        _save();
      } catch (e) {
        debugPrint(
            '[AchievementNotifier] Failed to save unlock, reverting: $e');
        state = prev;
      }
    }
  }

  bool isUnlocked(String id) => state.any((a) => a.id == id && a.unlocked);
  int get unlockedCount => state.where((a) => a.unlocked).length;
}
