import 'dart:io';

import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/enums/exercise_tracking_metric.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/data/models/workout_plan_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;

  setUpAll(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('fitquest_hive_round_trip_');
    Hive.init(temporaryDirectory.path);
    _registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('user body profile and exact stat doubles survive Hive', () async {
    final box = await Hive.openBox<UserModel>('round_trip_user');
    final now = DateTime(2026, 7, 20);
    final user = UserModel(
      id: 'user',
      name: 'Tester',
      stats: const {0: 12.345, 1: 12.345, 2: 12.345, 3: 12.345, 4: 12.345},
      age: 29,
      height: 181.5,
      weight: 78.25,
      fitnessLevel: 'Intermediate',
      preferredFocusIndex: 2,
      createdAt: now,
      updatedAt: now,
    );

    await box.put('user', user);
    final restored = box.get('user')!;

    expect(restored.age, 29);
    expect(restored.height, 181.5);
    expect(restored.weight, 78.25);
    expect(restored.stats[0], 12.345);
    expect(restored.preferredFocusIndex, 2);
    await box.close();
  });

  test('nested variation and set hierarchy survives Hive', () async {
    final box = await Hive.openBox<WorkoutModel>('round_trip_workout');
    final now = DateTime(2026, 7, 20);
    final workout = WorkoutModel(
      id: 'workout',
      eventId: 'workout:event',
      date: now,
      createdAt: now,
      completed: true,
      processingStateIndex: WorkoutProcessingState.committed.index,
      completionRate: 1,
      masteryPoints: const {'push_up': 24},
      benchmarkScores: const {'push_up': 33.6},
      personalRecordMovementIds: const ['push_up'],
      exercises: [
        ExerciseRecord(
          id: 'exercise',
          exerciseTypeIndex: ExerciseType.pushUp.index,
          movementId: 'push_up',
          displayName: 'Push Up',
          trackingMetricIndex: ExerciseTrackingMetric.repetitions.index,
          variations: [
            VariationRecord(
              id: 'standard',
              name: 'Standard',
              difficultyMultiplier: 1.2,
              sets: [
                WorkoutSetRecord(
                  id: 'set',
                  reps: 10,
                  loadKg: 4,
                  rpe: 8,
                  completed: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await box.put('workout', workout);
    final restored = box.get('workout')!;
    final set = restored.exercises.single.variations.single.sets.single;

    expect(restored.eventId, 'workout:event');
    expect(restored.masteryPoints['push_up'], 24);
    expect(set.reps, 10);
    expect(set.loadKg, 4);
    expect(set.rpe, 8);
    expect(set.completed, isTrue);
    await box.close();
  });

  test('weekly plan and future-editable targets survive Hive', () async {
    final box = await Hive.openBox<WorkoutPlanModel>('round_trip_plan');
    final plan = WorkoutPlanCatalog.create(
      fitnessLevel: 'Intermediate',
      now: DateTime(2026, 7, 20),
    );

    await box.put('plan', plan);
    final restored = box.get('plan')!;

    expect(restored.days, hasLength(7));
    expect(restored.days.first.exercises.first.variations, hasLength(3));
    expect(
      restored.days.first.exercises.first.variations.first.targetValue,
      10,
    );
    await box.close();
  });
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter<UserModel>(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(WorkoutModelAdapter().typeId)) {
    Hive.registerAdapter<WorkoutModel>(WorkoutModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseRecordAdapter().typeId)) {
    Hive.registerAdapter<ExerciseRecord>(ExerciseRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(VariationRecordAdapter().typeId)) {
    Hive.registerAdapter<VariationRecord>(VariationRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(WorkoutSetRecordAdapter().typeId)) {
    Hive.registerAdapter<WorkoutSetRecord>(WorkoutSetRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(WorkoutPlanModelAdapter().typeId)) {
    Hive.registerAdapter<WorkoutPlanModel>(WorkoutPlanModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlannedDayModelAdapter().typeId)) {
    Hive.registerAdapter<PlannedDayModel>(PlannedDayModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlannedExerciseModelAdapter().typeId)) {
    Hive.registerAdapter<PlannedExerciseModel>(
      PlannedExerciseModelAdapter(),
    );
  }
  if (!Hive.isAdapterRegistered(VariationPlanModelAdapter().typeId)) {
    Hive.registerAdapter<VariationPlanModel>(VariationPlanModelAdapter());
  }
}
