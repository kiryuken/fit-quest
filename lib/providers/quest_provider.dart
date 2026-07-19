import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/hive_datasource.dart';
import '../data/models/daily_quest_model.dart';
import 'initialization_provider.dart';
import 'user_provider.dart';

final questProvider =
    StateNotifierProvider<QuestNotifier, List<DailyQuestModel>>((ref) {
  final ds = ref.watch(hiveDatasourceProvider);
  return QuestNotifier(
    ds,
    onExpReward: (amount) => ref.read(userProvider.notifier).gainXp(amount),
  );
});

class QuestNotifier extends StateNotifier<List<DailyQuestModel>> {
  final HiveDatasource? _ds;
  final Future<void> Function(int amount) _onExpReward;

  QuestNotifier(
    HiveDatasource datasource, {
    required Future<void> Function(int amount) onExpReward,
  })  : _ds = datasource,
        _onExpReward = onExpReward,
        super([]) {
    _loadToday();
  }

  @visibleForTesting
  QuestNotifier.forTesting({
    required List<DailyQuestModel> initialQuests,
    required Future<void> Function(int amount) onExpReward,
  })  : _ds = null,
        _onExpReward = onExpReward,
        super(initialQuests);

  void _loadToday() {
    final ds = _ds;
    if (ds == null) return;

    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    final raw = ds.gameStateBox.get('quests_$d');
    if (raw != null) {
      final list = jsonDecode(raw as String) as List;
      state = list
          .map((e) => DailyQuestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      state = QuestCatalog.today();
      unawaited(_save());
    }
    _cleanupStaleKeys();
  }

  void _cleanupStaleKeys() {
    final ds = _ds;
    if (ds == null) return;

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final d = DateTime(cutoff.year, cutoff.month, cutoff.day);
    final keysToDelete = ds.gameStateBox.keys
        .where((k) => k is String && k.startsWith('quests_'))
        .toList();
    for (final key in keysToDelete) {
      try {
        final dateStr = (key as String).replaceFirst('quests_', '');
        final keyDate = DateTime.parse(dateStr);
        if (keyDate.isBefore(d)) {
          ds.gameStateBox.delete(key);
        }
      } catch (_) {/* skip malformed keys */}
    }
  }

  Future<void> _save() async {
    final ds = _ds;
    if (ds == null) return;

    try {
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);
      final json = jsonEncode(state.map((q) => q.toJson()).toList());
      await ds.gameStateBox.put('quests_$d', json);
    } catch (e) {
      debugPrint('[QuestNotifier] Failed to save quests: $e');
    }
  }

  Future<void> addProgress(String questId, int amount) async {
    final idx = state.indexWhere((q) => q.id == questId);
    if (idx >= 0 && !state[idx].isCompleted) {
      final previous = state[idx];
      final updated = previous.addProgress(amount);
      state = [...state]..[idx] = updated;
      await _save();

      if (!previous.isCompleted && updated.isCompleted) {
        await _onExpReward(updated.expReward);
      }
    }
  }

  int get completedCount => state.where((q) => q.isCompleted).length;
}
