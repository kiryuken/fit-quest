import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/workout_plan_catalog.dart';
import '../data/models/workout_plan_model.dart';
import '../domain/services/weekly_plan_service.dart';
import 'initialization_provider.dart';
import 'user_provider.dart';

final weeklyPlanProvider =
    AsyncNotifierProvider<WeeklyPlanNotifier, WorkoutPlanModel>(
  WeeklyPlanNotifier.new,
);

class WeeklyPlanNotifier extends AsyncNotifier<WorkoutPlanModel> {
  @override
  Future<WorkoutPlanModel> build() async {
    final repository = ref.read(workoutPlanRepositoryProvider);
    final stored = await repository.getPlan();
    if (stored != null) return stored;

    final user = ref.read(userProvider).valueOrNull;
    final plan = WorkoutPlanCatalog.create(
      fitnessLevel: user?.fitnessLevel ?? 'Beginner',
      now: ref.read(clockProvider).now(),
    );
    await repository.savePlan(plan);
    return plan;
  }

  Future<WorkoutPlanModel> selectPreset(
    String presetId, {
    String? fitnessLevel,
  }) async {
    final now = ref.read(clockProvider).now();
    final user = ref.read(userProvider).valueOrNull;
    final plan = WorkoutPlanCatalog.create(
      presetId: presetId,
      fitnessLevel: fitnessLevel ?? user?.fitnessLevel ?? 'Beginner',
      now: now,
    );
    await ref.read(workoutPlanRepositoryProvider).savePlan(plan);
    state = AsyncData(plan);
    return plan;
  }

  Future<WorkoutPlanModel> updateVariation({
    required DateTime targetDate,
    required String dayId,
    required String exerciseId,
    required String variationId,
    int? targetSets,
    int? targetValue,
    double? targetLoadKg,
  }) async {
    final current = state.requireValue;
    final now = ref.read(clockProvider).now();
    if (!WeeklyPlanService.canEditDate(
      targetDate: targetDate,
      now: now,
    )) {
      throw StateError('Only future training days can be edited.');
    }
    if (targetSets != null && (targetSets < 1 || targetSets > 20)) {
      throw RangeError.range(targetSets, 1, 20, 'targetSets');
    }
    if (targetValue != null && (targetValue < 1 || targetValue > 10000)) {
      throw RangeError.range(targetValue, 1, 10000, 'targetValue');
    }
    if (targetLoadKg != null && (targetLoadKg < 0 || targetLoadKg > 500)) {
      throw RangeError.range(targetLoadKg, 0, 500, 'targetLoadKg');
    }

    var found = false;
    final days = current.days.map((day) {
      if (day.id != dayId || day.weekday != targetDate.weekday) return day;
      final exercises = day.exercises.map((exercise) {
        if (exercise.id != exerciseId) return exercise;
        final variations = exercise.variations.map((variation) {
          if (variation.id != variationId) return variation;
          found = true;
          return variation.copyWith(
            targetSets: targetSets,
            targetValue: targetValue,
            targetLoadKg: targetLoadKg,
          );
        }).toList();
        return exercise.copyWith(variations: variations);
      }).toList();
      return day.copyWith(exercises: exercises);
    }).toList();
    if (!found) {
      throw StateError('The planned variation no longer exists.');
    }

    final updated = current.copyWith(days: days, updatedAt: now);
    await ref.read(workoutPlanRepositoryProvider).savePlan(updated);
    state = AsyncData(updated);
    return updated;
  }
}

final todayPlanProvider = Provider<PlannedDayModel?>((ref) {
  final plan = ref.watch(weeklyPlanProvider).valueOrNull;
  if (plan == null) return null;
  return plan.dayFor(ref.watch(clockProvider).now());
});
