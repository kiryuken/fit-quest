import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/workout_plan_catalog.dart';
import '../core/enums/exercise_tracking_metric.dart';
import '../data/datasources/hive_datasource.dart';
import '../data/models/daily_quest_model.dart';
import '../data/models/workout_model.dart';
import '../data/models/workout_plan_model.dart';
import '../data/repositories/implementations/workout_plan_repository_impl.dart';
import 'initialization_provider.dart';
import 'user_provider.dart';

typedef QuestRewardCallback = Future<void> Function(
  String questId,
  int amount,
);

final questProvider =
    StateNotifierProvider<QuestNotifier, List<DailyQuestModel>>((ref) {
  final datasource = ref.watch(hiveDatasourceProvider);
  final storedPlan =
      datasource.gameStateBox.get(WorkoutPlanRepositoryImpl.planKey);
  final now = ref.read(clockProvider).now();
  final plan = storedPlan is WorkoutPlanModel
      ? storedPlan
      : WorkoutPlanCatalog.create(now: now);
  return QuestNotifier(
    datasource,
    plan: plan,
    now: now,
    onExpReward: (questId, amount) async {
      await ref.read(userProvider.notifier).awardQuestXp(
            amount: amount,
            questId: questId,
          );
    },
  );
});

class QuestNotifier extends StateNotifier<List<DailyQuestModel>> {
  final HiveDatasource? _datasource;
  final QuestRewardCallback _onExpReward;
  final DateTime _date;

  QuestNotifier(
    HiveDatasource datasource, {
    required WorkoutPlanModel plan,
    required DateTime now,
    required QuestRewardCallback onExpReward,
  })  : _datasource = datasource,
        _onExpReward = onExpReward,
        _date = DateTime(now.year, now.month, now.day),
        super([]) {
    _load(plan);
  }

  @visibleForTesting
  QuestNotifier.forTesting({
    required List<DailyQuestModel> initialQuests,
    required QuestRewardCallback onExpReward,
  })  : _datasource = null,
        _onExpReward = onExpReward,
        _date =
            initialQuests.isEmpty ? DateTime(2026) : initialQuests.first.date,
        super(initialQuests);

  void _load(WorkoutPlanModel plan) {
    final datasource = _datasource;
    if (datasource == null) return;
    final raw = datasource.gameStateBox.get(_storageKey);
    if (raw is String) {
      final decoded = jsonDecode(raw) as List;
      state = decoded
          .map(
            (entry) => DailyQuestModel.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
    } else {
      state = QuestCatalog.forDay(plan: plan, date: _date);
      unawaited(_save());
    }
    unawaited(_cleanupStaleKeys());
  }

  Future<void> addProgress(
    String questId,
    int amount, {
    String? eventId,
  }) async {
    final index = state.indexWhere((quest) => quest.id == questId);
    if (index < 0 || state[index].isCompleted || amount <= 0) return;
    final previousState = state;
    final previous = state[index];
    final updated = previous.addProgress(amount, eventId: eventId);
    if (identical(updated, previous)) return;

    if (!previous.isCompleted && updated.isCompleted) {
      await _onExpReward(updated.id, updated.expReward);
    }

    state = [...state]..[index] = updated;
    try {
      await _save();
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> applyWorkout(WorkoutModel workout) async {
    final workoutDate = DateTime(
      workout.date.year,
      workout.date.month,
      workout.date.day,
    );
    if (workoutDate != _date) return;
    for (final quest in state) {
      final amount = _progressForQuest(quest, workout);
      if (amount <= 0) continue;
      await addProgress(
        quest.id,
        amount,
        eventId: workout.eventId,
      );
    }
  }

  int _progressForQuest(
    DailyQuestModel quest,
    WorkoutModel workout,
  ) {
    if (quest.metricSlug == 'workout_count') return 1;
    final matching = workout.exercises.where(
      (exercise) => exercise.movementId == quest.metricSlug,
    );
    var total = 0.0;
    for (final exercise in matching) {
      for (final variation in exercise.variations) {
        for (final set in variation.sets) {
          if (!set.isValid(exercise.trackingMetric)) continue;
          total += switch (exercise.trackingMetric) {
            ExerciseTrackingMetric.repetitions => set.reps,
            ExerciseTrackingMetric.durationSeconds => set.durationSeconds,
            ExerciseTrackingMetric.distanceMeters => set.distanceMeters,
          };
        }
      }
    }
    return total.round();
  }

  Future<void> _save() async {
    final datasource = _datasource;
    if (datasource == null) return;
    final encoded = jsonEncode(state.map((quest) => quest.toJson()).toList());
    await datasource.gameStateBox.put(_storageKey, encoded);
  }

  Future<void> _cleanupStaleKeys() async {
    final datasource = _datasource;
    if (datasource == null) return;
    final cutoff = _date.subtract(const Duration(days: 7));
    final keys = datasource.gameStateBox.keys
        .whereType<String>()
        .where((key) => key.startsWith('quests_v2_'))
        .toList();
    for (final key in keys) {
      final date = DateTime.tryParse(key.replaceFirst('quests_v2_', ''));
      if (date != null && date.isBefore(cutoff)) {
        await datasource.gameStateBox.delete(key);
      }
    }
  }

  String get _storageKey =>
      'quests_v2_${_date.year.toString().padLeft(4, '0')}-'
      '${_date.month.toString().padLeft(2, '0')}-'
      '${_date.day.toString().padLeft(2, '0')}';

  int get completedCount => state.where((quest) => quest.isCompleted).length;
}
