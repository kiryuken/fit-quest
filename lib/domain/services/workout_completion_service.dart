import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/achievement_provider.dart';
import '../../providers/initialization_provider.dart';
import '../../providers/quest_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/weekly_plan_provider.dart';
import '../../data/models/achievement_state.dart';
import '../../data/models/workout_model.dart';
import 'benchmark_service.dart';
import 'mastery_service.dart';
import 'milestone_service.dart';
import 'weekly_plan_service.dart';
import 'workout_reward_service.dart';

final workoutCompletionServiceProvider = Provider<WorkoutCompletionService>(
  WorkoutCompletionService.new,
);

class WorkoutCompletionResult {
  final WorkoutModel workout;
  final int xpAwarded;
  final Set<String> achievementsUnlocked;

  const WorkoutCompletionResult({
    required this.workout,
    required this.xpAwarded,
    required this.achievementsUnlocked,
  });
}

class WorkoutCompletionService {
  final Ref _ref;
  final Set<String> _inFlight = {};

  WorkoutCompletionService(this._ref);

  Future<WorkoutCompletionResult> complete(WorkoutModel workout) async {
    if (!_inFlight.add(workout.eventId)) {
      throw StateError('This workout is already being completed.');
    }
    try {
      final actualCompletionRate = workout.plannedSetCount <= 0
          ? 0.0
          : workout.validSetCount / workout.plannedSetCount;
      if (workout.validSetCount <= 0 ||
          actualCompletionRate < WorkoutRewardService.minimumCompletionRate) {
        throw StateError('At least 50% of planned sets must be valid.');
      }

      final repository = _ref.read(workoutRepositoryProvider);
      final pending = workout.copyWith(
        completed: false,
        processingStateIndex: WorkoutProcessingState.pending.index,
        completionRate: actualCompletionRate,
      );
      await repository.saveWorkout(pending);

      final history = await repository.getAllWorkouts();
      final enriched = _enrich(pending, history);
      await repository.saveWorkout(enriched);

      final plan = _ref.read(weeklyPlanProvider).requireValue;
      final userBefore = _ref.read(userProvider).valueOrNull;
      if (userBefore == null) {
        throw StateError('Create a character before completing a workout.');
      }
      final missed = WeeklyPlanService.missedRequiredDays(
        plan: plan,
        after: userBefore.lastStreakWorkoutAt,
        before: enriched.date,
      );
      final requestedXp = WorkoutRewardService.calculateSessionXp(
        exerciseFamilies: enriched.validExerciseFamilyCount,
        validSets: enriched.validSetCount,
        plannedSets: enriched.plannedSetCount,
        completionRate: enriched.completionRate,
      );
      final progression =
          await _ref.read(userProvider.notifier).completeWorkout(
                eventId: enriched.eventId,
                requestedXp: requestedXp,
                masteryPoints: enriched.masteryPoints,
                personalRecordMovementIds: enriched.personalRecordMovementIds,
                countsForStreak: enriched.countsForStreak,
                missedScheduledDays: missed,
              );

      await _ref.read(questProvider.notifier).applyWorkout(enriched);

      final now = _ref.read(clockProvider).now();
      final provisional = enriched.copyWith(
        completed: true,
        totalXpEarned: progression.xpAwarded,
        processingStateIndex: WorkoutProcessingState.committed.index,
        committedAt: now,
      );
      final evaluation = MilestoneService.evaluate(
        user: progression.user,
        plan: plan,
        workouts: [...history, provisional],
        now: now,
      );
      final unlocked = await _ref.read(achievementProvider.notifier).unlockAll(
            evaluation.eligibleAchievementIds,
          );
      final titles = unlocked
          .map((id) => AchievementCatalog.milestoneTitles[id])
          .whereType<String>();
      await _ref.read(userProvider.notifier).unlockTitles(titles);

      await repository.saveWorkout(provisional);
      return WorkoutCompletionResult(
        workout: provisional,
        xpAwarded: progression.xpAwarded,
        achievementsUnlocked: unlocked,
      );
    } finally {
      _inFlight.remove(workout.eventId);
    }
  }

  Future<int> recoverPending() async {
    final pending =
        await _ref.read(workoutRepositoryProvider).getPendingWorkouts();
    var recovered = 0;
    for (final workout in pending) {
      try {
        await complete(workout);
        recovered++;
      } catch (_) {
        // Keep the item pending. A later startup can safely retry because
        // user and quest mutations are keyed by the same event ID.
      }
    }
    return recovered;
  }

  WorkoutModel _enrich(
    WorkoutModel workout,
    List<WorkoutModel> history,
  ) {
    final benchmarks = <String, double>{};
    final mastery = <String, int>{};
    final personalRecords = <String>[];
    final records = <ExerciseRecord>[];

    for (final exercise in workout.exercises) {
      final score = BenchmarkService.score(exercise);
      benchmarks[exercise.movementId] = score;
      var previousBest = 0.0;
      for (final previous in history) {
        final candidate = previous.benchmarkScores[exercise.movementId] ?? 0;
        if (candidate > previousBest) previousBest = candidate;
      }
      final isRecord = BenchmarkService.isPersonalRecord(
        score: score,
        previousBest: previousBest,
      );
      if (isRecord) personalRecords.add(exercise.movementId);
      final difficulties = exercise.variations
          .where(
            (variation) => variation.validSetCount(exercise.trackingMetric) > 0,
          )
          .map((variation) => variation.difficultyMultiplier)
          .toList();
      final difficulty = difficulties.isEmpty
          ? exercise.exerciseType.difficultyMultiplier
          : difficulties.reduce((a, b) => a + b) / difficulties.length;
      final points = MasteryService.pointsForSession(
        validSets: exercise.validSetCount,
        difficultyMultiplier: difficulty,
        isPersonalRecord: isRecord,
      );
      mastery[exercise.movementId] = points;
      records.add(
        exercise.copyWith(
          masteryEarned: points,
          isPersonalRecord: isRecord,
        ),
      );
    }

    return workout.copyWith(
      exercises: records,
      masteryPoints: mastery,
      benchmarkScores: benchmarks,
      personalRecordMovementIds: personalRecords,
    );
  }
}
